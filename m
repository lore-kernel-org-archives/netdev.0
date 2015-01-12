From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Mon, 12 Jan 2015 11:52:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC5844@AcuExch.aculab.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <54AEA498.5030202@uclouvain.be>
 <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
 <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Neal Cardwell <ncardwell@google.com>,
	=?utf-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	"Nandita Dukkipati" <nanditad@google.com>
To: 'Yuchung Cheng' <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:60591 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbbALLyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 06:54:08 -0500
In-Reply-To: <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWXVjaHVuZyBDaGVuZw0KPiBTZW50OiAwOSBKYW51YXJ5IDIwMTUgMTk6NDQNCi4uLg0K
PiBTZWJhc3RpZW46IEkgc3VnZ2VzdCBicmVha2luZyBkb3duIGJ5IEFDSyB0eXBlcyBmb3IgcmVh
ZGFiaWxpdHkuIGUuZy4sDQo+IA0KPiAvKiBUaGlzIHJvdXRpbmUgZGVhbHMgd2l0aCBhY2tzIGR1
cmluZyBhIFRMUCBlcGlzb2RlLg0KPiAgKiBXZSBtYXJrIHRoZSBlbmQgb2YgYSBUTFAgZXBpc29k
ZSBvbiByZWNlaXZpbmcgVExQIGR1cGFjayBvciB3aGVuDQo+ICAqIGFjayBpcyBhZnRlciB0bHBf
aGlnaF9zZXEuDQo+ICAqIFJlZjogbG9zcyBkZXRlY3Rpb24gYWxnb3JpdGhtIGluIGRyYWZ0LWR1
a2tpcGF0aS10Y3BtLXRjcC1sb3NzLXByb2JlLg0KPiAgKi8NCj4gc3RhdGljIHZvaWQgdGNwX3By
b2Nlc3NfdGxwX2FjayhzdHJ1Y3Qgc29jayAqc2ssIHUzMiBhY2ssIGludCBmbGFnKQ0KPiB7DQo+
ICAgICAgICAgc3RydWN0IHRjcF9zb2NrICp0cCA9IHRjcF9zayhzayk7DQo+IA0KPiAgICAgICAg
IGlmIChiZWZvcmUoYWNrLCB0cC0+dGxwX2hpZ2hfc2VxKSkNCj4gICAgICAgICAgICAgICAgIHJl
dHVybjsNCj4gDQo+ICAgICAgICAgaWYgKGZsYWcgJiBGTEFHX0RTQUNLSU5HX0FDSykgew0KPiAg
ICAgICAgICAgICAgICAgLyogVGhpcyBEU0FDSyBtZWFucyBvcmlnaW5hbCBhbmQgVExQIHByb2Jl
IGFycml2ZWQ7IG5vIGxvc3MgKi8NCj4gICAgICAgICAgICAgICAgIHRwLT50bHBfaGlnaF9zZXEg
PSAwOw0KDQpJIHRoaW5rIEknZCBhZGQgYSAncmV0dXJuJyBoZXJlLg0KDQo+ICAgICAgICAgfSBl
bHNlIGlmIChhZnRlcihhY2ssIHRwLT50bHBfaGlnaF9zZXEpKSB7DQo+ICAgICAgICAgICAgICAg
ICAvKiBBQ0sgYWR2YW5jZXM6IHRoZXJlIHdhcyBhIGxvc3MsIHNvIHJlZHVjZSBjd25kLiBSZXNl
dA0KPiAgICAgICAgICAgICAgICAgICogdGxwX2hpZ2hfc2VxIGluIHRjcF9pbml0X2N3bmRfcmVk
dWN0aW9uKCkNCj4gICAgICAgICAgICAgICAgICAqLw0KPiAgICAgICAgICAgICAgICAgdGNwX2lu
aXRfY3duZF9yZWR1Y3Rpb24oc2spOw0KPiAgICAgICAgICAgICAgICAgdGNwX3NldF9jYV9zdGF0
ZShzaywgVENQX0NBX0NXUik7DQo+ICAgICAgICAgICAgICAgICB0Y3BfZW5kX2N3bmRfcmVkdWN0
aW9uKHNrKTsNCj4gICAgICAgICAgICAgICAgIHRjcF90cnlfa2VlcF9vcGVuKHNrKTsNCj4gICAg
ICAgICAgICAgICAgIE5FVF9JTkNfU1RBVFNfQkgoc29ja19uZXQoc2spLA0KPiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICBMSU5VWF9NSUJfVENQTE9TU1BST0JFUkVDT1ZFUlkpOw0K
DQphbmQgaGVyZQ0KDQo+ICAgICAgICAgfSBlbHNlIGlmICghKGZsYWcgJiAoRkxBR19TTkRfVU5B
X0FEVkFOQ0VEIHwNCj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICBGTEFHX05PVF9EVVAg
fCBGTEFHX0RBVEFfU0FDS0VEKSkpIHsNCj4gICAgICAgICAgICAgICAgIC8qIFB1cmUgZHVwYWNr
OiBvcmlnaW5hbCBhbmQgVExQIHByb2JlIGFycml2ZWQ7IG5vIGxvc3MgKi8NCj4gICAgICAgICAg
ICAgICAgIHRwLT50bHBfaGlnaF9zZXEgPSAwOw0KPiAgICAgICAgIH0NCj4gfQ0KDQoJRGF2aWQN
Cg==
