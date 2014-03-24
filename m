From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: optimize csum_replace2()
Date: Mon, 24 Mar 2014 15:52:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E7A13@AcuExch.aculab.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.140730.1007660405690890605.davem@davemloft.net>
	 <1395629496.9117.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E778C@AcuExch.aculab.com>
	 <1395667527.12610.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E7939@AcuExch.aculab.com>
 <1395674087.12610.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"hkchu@google.com" <hkchu@google.com>,
	"mwdalton@google.com" <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35286 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750909AbaCXPw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 11:52:57 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19293-09 for <netdev@vger.kernel.org>;
 Mon, 24 Mar 2014 15:52:54 +0000 (GMT)
In-Reply-To: <1395674087.12610.44.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQouLi4NCj4gQ29kZSBJIHByb3ZpZGVkIHVzZXMgbm8gY29uZGl0
aW9uYWwgYnJhbmNoIG9uIHg4Ni4NCg0KQWxsIHRoZSB3b3JsZCBpc24ndCB4ODYuLi4NClRoZSBz
cGFyYywgcHBjIGFuZCBhcm0gcGVvcGxlIG1pZ2h0IHdhbnQgdG8gY29uc2lkZXIgb3B0aW1pc2lu
Zw0KdGhpcyBjb2RlIGZ1cnRoZXIuDQoNCj4gSXQgc291bmRzIHlvdSBjb3VsZCBwcm92aWRlIGhl
bHBlciB0byBhcm0sIGlmIHlvdSByZWFsbHkgY2FyZSBvZiB0aGlzDQo+IHBhdGguIEkgZmluZCBz
dXJwcmlzaW5nIHlvdSBkaWQgbm90IGNvbW1lbnQgb24gbXkgcHJpb3IgbWFpbHMgb24gdGhpcw0K
PiBzdWJqZWN0IGFuZCB5b3Ugc3VkZGVubHkgc2VlbSB0byBjYXJlIG5vdyB0aGUgcGF0Y2ggaXMg
bWVyZ2VkLg0KDQpJIGRvbid0IHJlbWVtYmVyIHNlZWluZyB0aGlzIHBhcnRpY3VsYXIgcGF0Y2gg
YmVmb3JlIHRvZGF5Lg0KTGFzdCB3ZWVrIHlvdSB3ZXJlIHN0aWxsIHNvcnRpbmcgb3V0IHRoZSBz
dGFsbCBjYXVzZWQgYnkNCnRoZSAxNmJpdCB3cml0ZSAtPiAzMmJpdCBsb2FkIGluIHRoZSBleGlz
dGluZyBjb2RlLg0KDQpJbiBhbnkgY2FzZSB5b3VyIGNoYW5nZSBpcyBjbGVhcmx5IGEgc2lnbmlm
aWNhbnQgaW1wcm92ZW1lbnQgb24NCndoYXQgd2FzIHRoZXJlIGJlZm9yZS4NCg0KPiBXZSBmb3Ig
ZXhhbXBsZSBoYXZlIHRoZSBmb2xsb3dpbmcgaGVscGVyIGluIHg4NiA6DQo+IA0KPiBzdGF0aWMg
aW5saW5lIHVuc2lnbmVkIGFkZDMyX3dpdGhfY2FycnkodW5zaWduZWQgYSwgdW5zaWduZWQgYikN
Cj4gew0KPiAgICAgICAgIGFzbSgiYWRkbCAlMiwlMFxuXHQiDQo+ICAgICAgICAgICAgICJhZGNs
ICQwLCUwIg0KPiAgICAgICAgICAgICA6ICI9ciIgKGEpDQo+ICAgICAgICAgICAgIDogIjAiIChh
KSwgInIiIChiKSk7DQo+ICAgICAgICAgcmV0dXJuIGE7DQo+IH0NCj4gDQo+IEJ1dCB0aGVzZSBk
YXlzLCBnY2Mgc2VlbXMgdG8gZG8gYSBwcmV0dHkgZ29vZCBqb2Igd2l0aG91dCB0aGVzZSBoZWxw
ZXJzLg0KDQpJbmRlZWQuDQoNCldoaWxlIHg4NiBjYW4gZG8gMTZiaXQgbWF0aHMsIG1vc3QgY3B1
cyBjYW4ndCAtIHNvIHRoZSBnZW5lcmF0ZWQNCmNvZGUgZm9yICdzaG9ydCcgKGFuZCAnY2hhcicp
IG1hdGhzIG11c3QgbWFzayB3aXRoIDB4ZmZmZiAob3IgMHhmZikNCmV2ZXJ5IHRpbWUgYSB2YWx1
ZSBpcyB3cml0dGVuIHRvIGEgbG9jYWwgKGllIHJlZ2lzdGVyKSB2YXJpYWJsZS4NCkluIGdlbmVy
YWwgeW91IGdldCBiZXR0ZXIgY29kZSBieSB1c2luZyBsb2NhbCB2YXJpYWJsZXMgdGhhdA0KYXJl
IHRoZSBzYW1lIHNpemUgYXMgbWFjaGluZSByZWdpc3RlcnMuDQpUaGlzIGFsc28gYXBwbGllcyB0
byBmdW5jdGlvbiBhcmd1bWVudHMgYW5kIHJldHVybiB0eXBlcy4NCg0KSSdtIG5vdCBzdXJlIGhv
dyBtdWNoIGRpZmZlcmVuY2UgaXQgd291bGQgbWFrZSBvdmVyYWxsLg0KSXQgcmF0aGVyIGRlcGVu
ZHMgb24gd2hldGhlciBhbnl0aGluZyBhcHBlYXJzIGluIGEgdmVyeQ0KaG90IHBhdGguIE9UT0gg
YSBsb3Qgb2YgbWFsbCBjaGFuZ2VzIGNhbiBhZGQgdG9nZXRoZXIuDQoNCglEYXZpZA0KDQo=
