From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Fri, 26 Sep 2014 09:23:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1749E380@AcuExch.aculab.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	=?utf-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37722 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753124AbaIZJZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 05:25:30 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10422-06 for <netdev@vger.kernel.org>;
 Fri, 26 Sep 2014 10:25:20 +0100 (BST)
In-Reply-To: <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFdlZCwgMjAxNC0wOS0yNCBhdCAxOToxMiAtMDcwMCwg
RXJpYyBEdW1hemV0IHdyb3RlOg0KLi4uDQo+IEl0IHR1cm5lZCBvdXQgdGhlIHByb2JsZW0gSSBu
b3RpY2VkIHdhcyBjYXVzZWQgYnkgY29tcGlsZXIgdHJ5aW5nIHRvIGJlDQo+IHNtYXJ0LCBidXQg
aW52b2x2aW5nIGEgYmFkIE1FU0kgdHJhbnNhY3Rpb24uDQo+IA0KPiAgIDAuMDUgICBtb3YgICAg
MHhjMCglcmF4KSwlZWRpICAgIC8vIExPQUQgZHFsLT5udW1fcXVldWVkDQo+ICAgMC40OCAgIG1v
diAgICAlZWR4LDB4YzgoJXJheCkgICAgLy8gU1RPUkUgZHFsLT5sYXN0X29ial9jbnQgPSBjb3Vu
dA0KPiAgNTguMjMgICBhZGQgICAgJWVkeCwlZWRpDQo+ICAgMC41OCAgIGNtcCAgICAlZWRpLDB4
YzQoJXJheCkNCj4gICAwLjc2ICAgbW92ICAgICVlZGksMHhjMCglcmF4KSAgICAvLyBTVE9SRSBk
cWwtPm51bV9xdWV1ZWQgKz0gY291bnQNCj4gICAwLjcyICAganMgICAgIGJkOA0KPiANCj4gDQo+
IEkgZ2V0IGFuIGluY3JlZGlibGUgMTAgJSBnYWluIGJ5IG1ha2luZyBzdXJlIGNwdSB3b250IGdl
dCB0aGUgY2FjaGUgbGluZQ0KPiBpbiBTaGFyZWQgbW9kZS4NCg0KVGhhdCBpcyBhIHN0dW5uaW5n
IGRpZmZlcmVuY2UgYmV0d2VlbiByZXF1ZXN0aW5nICdleGNsdXNpdmUnIGFjY2Vzcw0KYW5kIHVw
Z3JhZGluZyAnc2hhcmVkJyB0byBleGNsdXNpdmUuDQpTdGlua3Mgb2YgYSBjcHUgYnVnPw0KDQpP
ciBpcyB0aGUgcmVwb3J0ZWQgc3RhbGwgYSBzaWRlIGVmZmVjdCBvZiB3YWl0aW5nIGZvciB0aGUg
ZWFybGllcg0KJ2NhY2hlIGxpbmUgcmVhZCcgdG8gY29tcGxldGUgaW4gb3JkZXIgdG8gaXNzdWUg
dGhlICd1cGdyYWRlIHRvIGV4Y2x1c2l2ZScuDQpJbiB3aGljaCBjYXNlIGdjYydzIGluc3RydWN0
aW9uIHNjaGVkdWxlciBwcm9iYWJseSBuZWVkcyB0byBiZSB0YXVnaHQNCnRvIHNjaGVkdWxlIHdy
aXRlcyBiZWZvcmUgcmVhZHMuDQoNCj4gKEkgYWxzbyB0cmllZCBhIGJhcnJpZXIoKSBpbiBuZXRk
ZXZfdHhfc2VudF9xdWV1ZSgpIGJldHdlZW4gdGhlDQo+IA0KPiAJZHFsX3F1ZXVlZCgmZGV2X3F1
ZXVlLT5kcWwsIGJ5dGVzKTsNCj4gLQ0KPiArCWJhcnJpZXIoKTsNCj4gIAlpZiAobGlrZWx5KGRx
bF9hdmFpbCgmZGV2X3F1ZXVlLT5kcWwpID49IDApKQ0KPiANCj4gQnV0IGZvbGxvd2luZyBwYXRj
aCBzZWVtcyBjbGVhbmVyDQo+IA0KPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9keW5hbWlj
X3F1ZXVlX2xpbWl0cy5oIGIvaW5jbHVkZS9saW51eC9keW5hbWljX3F1ZXVlX2xpbWl0cy5oDQo+
IGluZGV4IDU2MjE1NDdkNjMxYi4uOTc4ZmJlMzMyMDkwIDEwMDY0NA0KPiAtLS0gYS9pbmNsdWRl
L2xpbnV4L2R5bmFtaWNfcXVldWVfbGltaXRzLmgNCj4gKysrIGIvaW5jbHVkZS9saW51eC9keW5h
bWljX3F1ZXVlX2xpbWl0cy5oDQo+IEBAIC04MCw3ICs4MCw3IEBAIHN0YXRpYyBpbmxpbmUgdm9p
ZCBkcWxfcXVldWVkKHN0cnVjdCBkcWwgKmRxbCwgdW5zaWduZWQgaW50IGNvdW50KQ0KPiAgLyog
UmV0dXJucyBob3cgbWFueSBvYmplY3RzIGNhbiBiZSBxdWV1ZWQsIDwgMCBpbmRpY2F0ZXMgb3Zl
ciBsaW1pdC4gKi8NCj4gIHN0YXRpYyBpbmxpbmUgaW50IGRxbF9hdmFpbChjb25zdCBzdHJ1Y3Qg
ZHFsICpkcWwpDQo+ICB7DQo+IC0JcmV0dXJuIGRxbC0+YWRqX2xpbWl0IC0gZHFsLT5udW1fcXVl
dWVkOw0KPiArCXJldHVybiBBQ0NFU1NfT05DRShkcWwtPmFkal9saW1pdCkgLSBBQ0NFU1NfT05D
RShkcWwtPm51bV9xdWV1ZWQpOw0KDQpEdW5ubywgdGhhdCBjb3VsZCBoYXZlIGFuIGltcGFjdCBv
biBvdGhlciBjYWxscyB3aGVyZSB0aGUgdmFsdWVzDQphcmUgYWxyZWFkeSBpbiByZWdpc3RlcnMg
LSBJIHN1c3BlY3QgQUNDRVNTX09OQ0UoKSBmb3JjZXMgYW4gYWNjZXNzLg0KDQoJRGF2aWQNCg0K
