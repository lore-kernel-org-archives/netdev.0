From: Tomas Hozza <thozza@redhat.com>
Subject: SOCK_STREAM TCP: send() returns success even when other side
 responded with RST packet
Date: Tue, 19 Feb 2013 02:02:12 -0500 (EST)
Message-ID: <20690238.1777611.1361257332454.JavaMail.root@redhat.com>
References: <79866921.1777178.1361257053436.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1777608_1211424834.1361257332451"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:41265 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073Ab3BSHCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 02:02:12 -0500
Received: from zmail19.collab.prod.int.phx2.redhat.com (zmail19.collab.prod.int.phx2.redhat.com [10.5.83.22])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r1J72C8w031471
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 02:02:12 -0500
In-Reply-To: <79866921.1777178.1361257053436.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_1777608_1211424834.1361257332451
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi.

I was advised to forward my networking Kernel related Bug here
so it can get fixed much faster. Here is the Bug description
copied from Red Hat Bugzilla (https://bugzilla.redhat.com/show_bug.cgi?id=912382):

Description of problem:
I'm using SOCK_STREAM TCP sockets. Imagine server-client application.
- Server will accept connection from client.
- Client sends some data to server -> server receives data.
- Client then half-closes the TCP connection using shutdown(fd, SHUT_WR).
- Client waits for some data from the server.
- Server sends some data to client -> client receives data.
- Client exits and closes the socket.
- After some time server tries to send some data to the client.
- The first send() call returns success even the Client's response is RST.


Version-Release number of selected component (if applicable):
3.7.7-201.fc18.x86_64
3.7.8-202.fc18.x86_64


How reproducible:
always


Steps to Reproduce:
1. download attached client/server sources.
2. compile server: # gcc tcp_server.c -o server
3. compile client: # gcc tcp_client.c -o client
4. run the server: # ./server
5. run the client: # ./client


Actual results:
Server started...
Created SOCK_STREAM socket
Bound to localhost:6666
waiting for connection...
Client connected!
Waiting for some data from client
Received: "MSG from client"
Received EOF
Sending msg to client: "MSG from server"
sleep(5)
Sending 1 msg to client: "MSG from server"
try #1 send() result: (0) Success
Sending 2 msg to client: "MSG from server"
try #2 send() result: (32) Broken pipe
Server exiting...


Expected results:
Server should fail to send() data right after sleep().

Server started...
Created SOCK_STREAM socket
Bound to localhost:6666
waiting for connection...
Client connected!
Waiting for some data from client
Received: "MSG from client"
Received EOF
Sending msg to client: "MSG from server"
sleep(5)
Sending 1 msg to client: "MSG from server"
try #1 send() result: (32) Broken pipe
Server exiting...


Additional info:
RST answer means that data were NOT delivered. Therefore the very
first send() call after server sleep() should fail!


Regards,

Tomas Hozza
------=_Part_1777608_1211424834.1361257332451
Content-Type: text/x-csrc; name=tcp_server.c
Content-Disposition: attachment; filename=tcp_server.c
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5jbHVkZSA8
bmV0aW5ldC9pbi5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5j
bHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPGVycm5vLmg+CiNp
bmNsdWRlIDxzaWduYWwuaD4KCmludCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJndikKewogICAg
aW50IHNzb2NrLCBjc29jaywgaTsKICAgIHN0YXRpYyBjaGFyIGJ1ZmZbMjU2XTsKICAgIHNzaXpl
X3QgbmJ5dGVzOwogICAgc3RydWN0IHNvY2thZGRyX2luIHNhZGRyOwoKICAgIG1lbXNldCgmc2Fk
ZHIsIDAsIHNpemVvZihzYWRkcikpOwogICAgc2FkZHIuc2luX2ZhbWlseSA9IEFGX0lORVQ7CiAg
ICBzYWRkci5zaW5fcG9ydCA9IGh0b25zKDY2NjYpOwoKICAgIHNpZ25hbChTSUdQSVBFLCBTSUdf
SUdOKTsKCiAgICBwcmludGYoIlNlcnZlciBzdGFydGVkLi4uXG4iKTsKCiAgICBpZiAoKHNzb2Nr
ID0gc29ja2V0KEFGX0lORVQsIFNPQ0tfU1RSRUFNLCAwKSkgPCAwKSB7CiAgICAgICAgcHJpbnRm
KCJzb2NrZXQoKSBlcnJvci4gKCVkKSAlc1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAg
ICAgICAgZXhpdCgxKTsKICAgIH0KICAgIHByaW50ZigiQ3JlYXRlZCBTT0NLX1NUUkVBTSBzb2Nr
ZXRcbiIpOwoKICAgIGlmIChiaW5kKHNzb2NrLCAoc3RydWN0IHNvY2thZGRyKikmc2FkZHIsIHNp
emVvZihzYWRkcikpID09IC0xKSB7CiAgICAgICAgcHJpbnRmKCJiaW5kKCkgZXJyb3IuICglZCkg
JXNcbiIsIGVycm5vLCBzdHJlcnJvcihlcnJubykpOwogICAgICAgIGNsb3NlKHNzb2NrKTsKICAg
ICAgICBleGl0KDEpOwogICAgfQogICAgcHJpbnRmKCJCb3VuZCB0byBsb2NhbGhvc3Q6NjY2Nlxu
Iik7CgogICAgaWYgKGxpc3Rlbihzc29jaywgMSkgPT0gLTEpIHsKICAgICAgICBwcmludGYoImxp
c3RlbigpIGVycm9yLiAoJWQpICVzXG4iLCBlcnJubywgc3RyZXJyb3IoZXJybm8pKTsKICAgICAg
ICBjbG9zZShzc29jayk7CiAgICAgICAgZXhpdCgxKTsKICAgIH0KCiAgICBwcmludGYoIndhaXRp
bmcgZm9yIGNvbm5lY3Rpb24uLi5cbiIpOwogICAgY3NvY2sgPSBhY2NlcHQoc3NvY2ssIE5VTEws
IE5VTEwpOwoKICAgIGlmIChjc29jayA9PSAtMSkgewogICAgICAgIHByaW50ZigiYWNjZXB0KCkg
ZXJyb3IuICglZCkgJXNcbiIsIGVycm5vLCBzdHJlcnJvcihlcnJubykpOwogICAgICAgIGNsb3Nl
KHNzb2NrKTsKICAgICAgICBleGl0KDEpOwogICAgfQogICAgcHJpbnRmKCJDbGllbnQgY29ubmVj
dGVkIVxuIik7CiAgICBwcmludGYoIldhaXRpbmcgZm9yIHNvbWUgZGF0YSBmcm9tIGNsaWVudFxu
Iik7CgogICAgd2hpbGUgKChuYnl0ZXMgPSByZWN2KGNzb2NrLCBidWZmLCBzaXplb2YoYnVmZiks
IDApKSA+IDApIHsKICAgICAgICAgICAgcHJpbnRmKCJSZWNlaXZlZDogXCIlc1wiXG4iLCBidWZm
KTsKICAgIH0KCiAgICBpZiAobmJ5dGVzIDwgMCkgewogICAgICAgIHByaW50ZigicmVjdigpIGVy
cm9yLiAoJWQpICVzXG4iLCBlcnJubywgc3RyZXJyb3IoZXJybm8pKTsKICAgICAgICBjbG9zZShz
c29jayk7CiAgICAgICAgY2xvc2UoY3NvY2spOwogICAgICAgIGV4aXQoMSk7CiAgICB9IGVsc2Ug
aWYgKG5ieXRlcyA9PSAwKSB7CiAgICAgICAgcHJpbnRmKCJSZWNlaXZlZCBFT0ZcbiIpOwogICAg
ICAgIHByaW50ZigiU2VuZGluZyBtc2cgdG8gY2xpZW50OiBcIk1TRyBmcm9tIHNlcnZlclwiXG4i
KTsKICAgICAgICBpZiAoKG5ieXRlcyA9IHNlbmQoY3NvY2ssICJNU0cgZnJvbSBzZXJ2ZXIiLCBz
aXplb2YoIk1TRyBmcm9tIHNlcnZlciIpLCAwKSkgPD0gMCkgewogICAgICAgICAgICBwcmludGYo
InNlbmQoKSBlcnJvci4gKCVkKSAlc1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICAg
ICAgICAgIGNsb3NlKHNzb2NrKTsKICAgICAgICAgICAgY2xvc2UoY3NvY2spOwogICAgICAgICAg
ICBleGl0KDEpOwogICAgICAgIH0KICAgIH0KCiAgICBwcmludGYoInNsZWVwKDUpXG4iKTsKICAg
IHNsZWVwKDUpOwogICAgCiAgICBpID0gMTsKICAgIHdoaWxlICgxKSB7IAogICAgICAgIHByaW50
ZigiU2VuZGluZyAlZCBtc2cgdG8gY2xpZW50OiBcIk1TRyBmcm9tIHNlcnZlclwiXG4iLCBpKTsK
ICAgICAgICBuYnl0ZXMgPSBzZW5kKGNzb2NrLCAiTVNHIGZyb20gc2VydmVyIiwgc2l6ZW9mKCJN
U0cgZnJvbSBzZXJ2ZXIiKSwgMCk7CiAgICAgICAgcHJpbnRmKCJ0cnkgIyVkIHNlbmQoKSByZXN1
bHQ6ICglZCkgJXNcbiIsaSAsZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICAgICAgaWYgKG5i
eXRlcyA8PSAwKQogICAgICAgICAgICBicmVhazsKICAgICAgICArK2k7CiAgICB9CgogICAgcHJp
bnRmKCJTZXJ2ZXIgZXhpdGluZy4uLlxuIik7CiAgICBjbG9zZShzc29jayk7CiAgICBjbG9zZShj
c29jayk7CiAgICByZXR1cm4gMDsKfQo=
------=_Part_1777608_1211424834.1361257332451
Content-Type: text/x-csrc; name=tcp_client.c
Content-Disposition: attachment; filename=tcp_client.c
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5jbHVkZSA8
bmV0aW5ldC9pbi5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5j
bHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPGVycm5vLmg+Cgpp
bnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpCnsKICAgIGludCBzc29jaywgaTsKICAgIHN0
YXRpYyBjaGFyIGJ1ZmZbMjU2XTsKICAgIHNzaXplX3QgbmJ5dGVzOwogICAgc3RydWN0IHNvY2th
ZGRyX2luIHNhZGRyOwoKICAgIG1lbXNldCgmc2FkZHIsIDAsIHNpemVvZihzYWRkcikpOwogICAg
c2FkZHIuc2luX2ZhbWlseSA9IEFGX0lORVQ7CiAgICBzYWRkci5zaW5fcG9ydCA9IGh0b25zKDY2
NjYpOwoKICAgIHByaW50ZigiQ2xpZW50IHN0YXJ0ZWQuLi5cbiIpOwoKICAgIGlmICgoc3NvY2sg
PSBzb2NrZXQoQUZfSU5FVCwgU09DS19TVFJFQU0sIDApKSA8IDApIHsKICAgICAgICBwcmludGYo
InNvY2tldCgpIGVycm9yLiAoJWQpICVzXG4iLCBlcnJubywgc3RyZXJyb3IoZXJybm8pKTsKICAg
ICAgICBleGl0KDEpOwogICAgfQoKICAgIHByaW50ZigiQ3JlYXRlZCBTT0NLX1NUUkVBTSBzb2Nr
ZXRcbiIpOwoKICAgIGlmIChjb25uZWN0KHNzb2NrLCAoc3RydWN0IHNvY2thZGRyICopJnNhZGRy
LCBzaXplb2Yoc2FkZHIpKSA9PSAtMSkgewogICAgICAgIHByaW50ZigiY29ubmVjdCgpIGVycm9y
LiAoJWQpICVzXG4iLCBlcnJubywgc3RyZXJyb3IoZXJybm8pKTsKICAgICAgICBjbG9zZShzc29j
ayk7CiAgICAgICAgZXhpdCgxKTsKICAgIH0KCiAgICBwcmludGYoIkNvbm5lY3RlZCB0byB0aGUg
c2VydmVyIVxuIik7CiAgICBwcmludGYoIlNlbmRpbmcgc29tZSBkYXRhIHRvIHNlcnZlclxuIik7
CgogICAgaWYgKChuYnl0ZXMgPSBzZW5kKHNzb2NrLCAiTVNHIGZyb20gY2xpZW50Iiwgc2l6ZW9m
KCJNU0cgZnJvbSBjbGllbnQiKSwgMCkpIDw9IDApIHsKICAgICAgICBwcmludGYoInNlbmQoKSBl
cnJvci4gKCVkKSAlc1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICAgICAgY2xvc2Uo
c3NvY2spOwogICAgICAgIGV4aXQoMSk7CiAgICB9CgogICAgcHJpbnRmKCJIYWxmLWNsb3Npbmcg
Y29ubmVjdGlvbiB3aXRoIHNodXRkb3duKHNzb2NrLCBTSFVUX1dSKVxuIik7CgogICAgaWYgKHNo
dXRkb3duKHNzb2NrLCBTSFVUX1dSKSA9PSAtMSkgewogICAgICAgIHByaW50Zigic2h1dGRvd24o
KSBlcnJvci4gKCVkKSAlc1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICAgICAgY2xv
c2Uoc3NvY2spOwogICAgICAgIGV4aXQoMSk7CiAgICB9CgogICAgcHJpbnRmKCJSZWNlaXZpbmcg
ZGF0YSBmcm9tIHNlcnZlclxuIik7CiAgICBpZiAoKG5ieXRlcyA9IHJlY3Yoc3NvY2ssIGJ1ZmYs
IHNpemVvZihidWZmKSwgMCkpID4gMCkgewogICAgICAgICAgICBwcmludGYoIlJlY2VpdmVkOiBc
IiVzXCJcbiIsIGJ1ZmYpOwogICAgfSBlbHNlIHsKICAgICAgICBwcmludGYoInJlY3YoKSBlcnJv
ci4gKCVkKSAlc1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICAgICAgY2xvc2Uoc3Nv
Y2spOwogICAgICAgIGV4aXQoMSk7CiAgICB9CgogICAgcHJpbnRmKCJDbGllbnQgZXhpdGluZy4u
LlxuIik7CiAgICBjbG9zZShzc29jayk7CiAgICByZXR1cm4gMDsKfQo=
------=_Part_1777608_1211424834.1361257332451--
