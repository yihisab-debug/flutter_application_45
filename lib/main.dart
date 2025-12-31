import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final String id;
  final String name;
  final String teacher;
  final String text;
  final String price;

  User({
    required this.id,
    required this.name,
    required this.teacher,
    required this.text,
    required this.price,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      teacher: json['teacher'],
      text: json['text'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': teacher,
      'text': text,
      'price': price,
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock API Users',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  List<User> favorites = [];
  bool isLoading = false;
  bool isAddingUser = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'),
      );
      if (response.statusCode == 200) {
        setState(() {
          users = (json.decode(response.body) as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        showErrorSnackBar("Ошибка при загрузке данных!");
      }
    } catch (e) {
      print("Ошибка загрузки: $e");
      showErrorSnackBar("Не удалось загрузить данные.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addUser() async {

    setState(() {
      isAddingUser = true;
    });

    final newUser = User(
      id: '',
      name: _nameController.text,
      teacher: _teacherController.text,
      text: _textController.text,
      price: _priceController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newUser.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          users.add(User.fromJson(json.decode(response.body)));
        });
      }
    } catch (e) {
      print("Ошибка добавления пользователя: $e");
      showErrorSnackBar("Ошибка при добавлении пользователя.");
    } finally {
      setState(() {
        isAddingUser = false;
      });
    }
  }

  Future<void> deleteUser(id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://6939834cc8d59937aa082275.mockapi.io/project/$id'),
      );
      if (response.statusCode == 200) {
        fetchUsers();
      }
    } catch (e) {
      print("Ошибка удаления пользователя: $e");
      showErrorSnackBar("Ошибка при удалении пользователя.");
    }
  }

  void addToFavorites(User user) {
    setState(() {
      if (!favorites.any((fav) => fav.id == user.id)) {
        favorites.add(user);
      }     });
  }

  void removeFromFavorites(String id) {
    setState(() {
      favorites.removeWhere((fav) => fav.id == id);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Рецепт блюд')),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Название'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _teacherController,
                decoration: InputDecoration(labelText: 'Категория'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Приём пищи'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Цена'),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: isAddingUser ? null : addUser,
              child: isAddingUser
                  ? CircularProgressIndicator()
                  : Text('Добавить пользователя'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage(users: users, onDelete: deleteUser)),
                );
              },
              child: Text('2 стр.'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage(users: users)),
                );
              },
              child: Text('3 стр.'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(favorites: favorites, onRemove: removeFromFavorites)),
                );
              },
              child: Text('Избранное'),
            ),

            SizedBox(height: 20),

              Container(
                height: 400,
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        user.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        user.teacher,
                                        style: const TextStyle(fontSize: 14, height: 1.4),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text(
                                            'Баллы: ${user.price}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.favorite_border,
                                                ),
                                                onPressed: () {
                                                  addToFavorites(user);
                                                },
                                              ),

                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () {
                                                  deleteUser(user.id);
                                                },
                                              ),

                                            ],
                                          ),

                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              )
        
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUsers,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  final List<User> users;

  const ThirdPage({required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Третья страница')),
      body: users.isEmpty
          ? Center(child: Text('Нету'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          user.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          '\${user.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final List<User> users;
  final Function(String) onDelete;

  const SecondPage({required this.users, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вторая страница')),
      body: users.isEmpty
          ? Center(child: Text('Нету'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          user.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          user.teacher,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              'Баллы: ${user.price}',
                              style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: () {
                                onDelete(user.id);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<User> favorites;
  final Function(String) onRemove;

  const FavoritesPage({required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Избранное')),
      body: favorites.isEmpty
          ? Center(child: Text('Нет избранных рецептов'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final user = favorites[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          user.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          user.teacher,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              'Баллы: ${user.price}',
                              style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: () {
                                onRemove(user.id);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritesPage(
                                      favorites: favorites,
                                      onRemove: onRemove,
                                    ),
                                  ),
                                );
                              },
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}