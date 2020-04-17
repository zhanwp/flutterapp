import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/country.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '号码生成器'),

      //国际化
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FocusNode _focusNode = new FocusNode();
  FocusNode _focusNode1 = new FocusNode();
  TextEditingController _phoneNo = new TextEditingController();
  TextEditingController _count = new TextEditingController();
  String _code;
  int _progress;

  @override
  void initState() {
    _code = "86";
  }

  Future<void> _generatePhoneNumber() async {
    var phone = int.parse(_phoneNo.text);
    for(var i = 0; i<int.parse(_count.text);i++) {
      var result = await ContactsService.addContact(new Contact(
              familyName: "张三",
              phones: [new Item(label: "工作", value: "$_code${phone+i}")],
              givenName: "${i+1}"));

      setState(() {
        print(result);
        _progress = i;
      });
    }
  }

  Future<void> _showProgress() async {
    var result = await showDialog(context: context,builder: (_) => CupertinoAlertDialog(
      content: Card(
        elevation: 0,
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.white10,
            filled: true,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none
              ),
            )
          ),
        ),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text("confirm"),
          onPressed: ()=>Navigator.pop(context,"confirm"),
        ),
      ],
    ));
    Fluttertoast.showToast(
      msg: result,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
        ),
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                child: TextField(
                  focusNode: _focusNode1,
                  controller: _count,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "请输入生成数量",
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0)),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        items: Country.map
                            .map((map) => DropdownMenuItem(
                                  child:
                                      Text("${map["name"]}(+${map["code"]})"),
                                  value: map["code"],
                                ))
                            .toList(),
                        onChanged: (String value) {
                          setState(() {
                            _code = value;
                          });
                        },
                        value: "$_code",
                        selectedItemBuilder: (BuildContext context) =>
                            Country.map
                                .map(
                                  (map) => Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "+${map["code"]}",
                                      )),
                                )
                                .toList(),
                        style: new TextStyle(
                          color: Colors.black,
                        ),
                        isExpanded: true,
                      )),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Card(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _phoneNo,
                        decoration: InputDecoration(
                            hintText: "首个手机号码",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0)),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.all(15),
                          child: Text("生成"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            _focusNode.unfocus();
                            _focusNode1.unfocus();
                            _showProgress();
//                            _generatePhoneNumber();
                          },
                        ),
                      )
                    ],
                  ))
            ],
          ),
        )));
  }
}
