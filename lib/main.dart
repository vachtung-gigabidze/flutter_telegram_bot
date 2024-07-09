import 'package:flutter/material.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';

void main() {
  runApp(MyApp());
}

const token = 'TOKEN API';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Flutter Telegram Bot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title}) : super();

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //TODO Secret API Key
  final telegram = Telegram(token);
  late TeleDart teleDart;
  String botName = 'gigabidzeBot';
  var msgId = 0;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _msgs = [];

  @override
  void initState() {
    super.initState();
    _startBot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
        // actions: [
        //   IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _startBot())
        // ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
              0.1,
              0.4,
              0.6,
              0.9
            ],
                colors: [
              Colors.blue,
              Colors.purple,
              Colors.indigo,
              Colors.black
            ])),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: ListView.builder(
                  itemCount: _msgs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: _getAligment(index),
                      children: [
                        Flexible(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${_msgs.isNotEmpty ? _msgs[index] : ''}',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        )
                      ],
                    );
                  }),
            ),
            SizedBox(
              height: 20.0,
            ),
            Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'input text',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      )),
                  controller: _controller,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter text';
                    }
                    return null;
                  },
                )),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    botSendMessage(_controller.text);
                    _controller.text = '';
                  }
                })
          ],
        ),
      ),
    );
  }

  _getAligment(index) {
    if (_msgs[index].keys.toList()[0] == botName) {
      return MainAxisAlignment.end;
    }
    return MainAxisAlignment.start;
  }

  _startBot() async {
    final username = (await Telegram(token).getMe()).username;
    teleDart = TeleDart(token, Event(username!));
    teleDart.start();

    // teleDart.onCommand().listen((message) {
    //   if (message.text == '/name') {
    //     message.reply('GigabidzeBot');
    //   }
    // });

    teleDart
        .onMessage(keyword: 'dart')
        // .where((message) => message.text?.contains('telegram') ?? false)
        .listen((message) {
      message.replyPhoto(
          //  io.File('example/dash_paper_plane.png'),
          'https://raw.githubusercontent.com/DinoLeung/TeleDart/master/example/dash_paper_plane.png',
          caption: 'This is how Dash found the paper plane');
    });

    teleDart
        .onMessage(entityType: 'bot_command', keyword: 'start')
        .listen((message) {
      msgId = message.chat.id;
      teleDart.sendMessage(msgId, 'Hello I am Flutter bot');
    });

    teleDart.onMessage().listen((message) {
      // message.reply('${message.from.first_name} say ${message.text}');
      if (message.text == 'name') {
        message.reply('GigabidzeBot');
      }
      // message.reply('GigabidzeBot');
      msgId = message.chat.id;
      setState(() {
        _msgs.add({message.chat.username.toString(): message.text ?? ""});
      });
    });
  }

  botSendMessage(String msg) {
    teleDart.sendMessage(msgId, msg);
    setState(() {
      _msgs.add({botName: msg});
    });
  }

  @override
  void dispose() {
    teleDart.stop();
    super.dispose();
  }
}
