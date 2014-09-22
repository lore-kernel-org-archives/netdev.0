From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Mon, 22 Sep 2014 11:13:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174973C3@AcuExch.aculab.com>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
 <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49745 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751070AbaIVLPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 07:15:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14942-04 for <netdev@vger.kernel.org>;
 Mon, 22 Sep 2014 12:14:58 +0100 (BST)
In-Reply-To: <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFNhdCwgMjAxNC0wOS0yMCBhdCAxMjo0NiAtMDcwMCwg
WXVjaHVuZyBDaGVuZyB3cm90ZToNCj4gPiBPbiBTYXQsIFNlcCAyMCwgMjAxNCBhdCAxMTowMSBB
TSwgSm9lIFBlcmNoZXMgPGpvZUBwZXJjaGVzLmNvbT4gd3JvdGU6DQo+ID4gPiBPbiBTYXQsIDIw
MTQtMDktMjAgYXQgMTA6MTkgLTA3MDAsIEVyaWMgRHVtYXpldCB3cm90ZToNCj4gPiA+PiBGcm9t
OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+DQo+ID4gPj4NCj4gPiA+PiBpY3Nr
X3J0byBpcyBhbiAzMmJpdCBmaWVsZCwgYW5kIGljc2tfYmFja29mZiBjYW4gcmVhY2ggMTUgYnkg
ZGVmYXVsdCwNCj4gPiA+PiBvciBtb3JlIGlmIHNvbWUgc3lzY3RsIChlZyB0Y3BfcmV0cmllczIp
IGFyZSBjaGFuZ2VkLg0KPiA+ID4+DQo+ID4gPj4gQmV0dGVyIHVzZSA2NGJpdCB0byBwZXJmb3Jt
IGljc2tfcnRvIDw8IGljc2tfYmFja29mZiBvcGVyYXRpb25zDQo+ID4gPg0KPiA+ID4gTWF5YmUg
YmV0dGVyIHRvIHVzZSBhIGhlbHBlciBmdW5jdGlvbiBmb3IgdGhpcz8NCj4gPiA+DQo+ID4gPiBz
b21ldGhpbmcgbGlrZToNCj4gPiA+DQo+ID4gPiBzdGF0aWMgaW5saW5lIHU2NCBpY3NrX3J0b19i
YWNrb2ZmKGNvbnN0IHN0cnVjdCBpbmV0X2Nvbm5lY3Rpb25fc29jayAqaWNzaykNCj4gPiA+IHsN
Cj4gPiA+ICAgICAgICAgdTY0IHdoZW4gPSAodTY0KWljc2stPmljc2tfcnRvOw0KPiA+ID4NCj4g
PiA+ICAgICAgICAgcmV0dXJuIHdoZW4gPDwgaWNzay0+aWNza19iYWNrb2ZmOw0KPiA+ID4gfQ0K
PiA+IFRoYW5rcyBmb3IgdGhlIGZpeCBFcmljLiBJIHNlY29uZCBKb2UncyBpZGVhIHRvIHVzZSBh
IGhlbHBlciBmdW5jdGlvbi4NCj4gPg0KPiANCj4gWWVwLg0KPiANCj4gR2l2ZW4gdGhlIHRpbWVv
dXQgZnVuY3Rpb25zIGluIHRoZSBrZXJuZWwgdXNlICd1bnNpZ25lZCBsb25nJywgSSBwcmVmZXIN
Cj4gdG8ga2VlcCB0aGUgdTY0IG1hZ2ljIHByaXZhdGUgdG8gdGhpcyBoZWxwZXIuDQo+IA0KPiBJ
IHdpbGwgcHJvYmFibHkgdXNlDQo+IA0KPiBzdGF0aWMgaW5saW5lIHVuc2lnbmVkIGxvbmcgaWNz
a19ydG9fYmFja29mZihjb25zdCBzdHJ1Y3QgaW5ldF9jb25uZWN0aW9uX3NvY2sgKmljc2spDQo+
IHsNCj4gCXU2NCB3aGVuID0gKHU2NClpY3NrLT5pY3NrX3J0byA8PCBpY3NrLT5pY3NrX2JhY2tv
ZmY7DQo+IA0KPiAJcmV0dXJuIG1pbl90KHU2NCwgd2hlbiwgfjBVTCk7DQo+IH0NCj4gDQo+IE9u
IDY0Yml0IGFyY2hlcywgdGhlIG1pbl90KCkgc2hvdWxkIGJlIGEgbm9wLg0KDQpJc24ndCBpdCBs
aWtlbHkgdG8gZ2VuZXJhdGUgYSAnY29uZGl0aW9uIGlzIGFsd2F5cyB0cnVlL2ZhbHNlJyB3YXJu
aW5nPw0KKHRoYXQgbWF5IGRlcGVuZCBvbiB3aGV0aGVyIG1pbl90IGNvbnRhaW5zIDwgb3IgPD0p
DQoNCglEYXZpZA0KDQo=
