From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 16:16:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F1F9F@AcuExch.aculab.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
 <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "'Nelson, Shannon'" <shannon.nelson@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52197 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751971AbaKQQQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 11:16:46 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09784-08 for <netdev@vger.kernel.org>;
 Mon, 17 Nov 2014 16:16:37 +0000 (GMT)
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTmVsc29uLCBTaGFubm9uDQo+ID4gRnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86ZXJp
Yy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gPiBTZW50OiBTYXR1cmRheSwgTm92ZW1iZXIgMTUsIDIw
MTQgMTA6MjIgQU0NCj4gPg0KPiA+IE9uIEZyaSwgMjAxNC0xMS0xNCBhdCAyMjowOCAtMDgwMCwg
SmVmZiBLaXJzaGVyIHdyb3RlOg0KPiA+ID4gRnJvbTogU2VyZXkgS29uZyA8c2VyZXkua29uZ0Bp
bnRlbC5jb20+DQo+ID4gPg0KPiA+ID4gVGhpcyBoYW5kbGVzIHRoZSBjYXNlIHdoZXJlIGEgc2lu
Z2xlIHBhY2tldCB3aXRoIG1vcmUgdGhhbiA4IGRhdGENCj4gPiA+IGRlc2NyaXB0b3JzIHRyaWdn
ZXJzIGEgTWFsaWNpb3VzIERyaXZlciBEZXRlY3QgZXZlbnQgaW4gdGhlIGRldmljZS4NCj4gPiA+
DQo+IA0KPiBbLi4uXQ0KPiANCj4gPiA+IC0JaWYgKHR4X2ZsYWdzICYgKEk0MEVfVFhfRkxBR1Nf
VFNPIHwgSTQwRV9UWF9GTEFHU19GU08pKQ0KPiA+ID4gKwlpZiAodHhfZmxhZ3MgJiAoSTQwRV9U
WF9GTEFHU19UU08gfCBJNDBFX1RYX0ZMQUdTX0ZTTykpIHsNCj4gPiA+ICAJCWdzb19zZWdzID0g
c2tiX3NoaW5mbyhza2IpLT5nc29fc2VnczsNCj4gPiA+IC0JZWxzZQ0KPiA+ID4gKwl9IGVsc2Ug
ew0KPiA+ID4gIAkJZ3NvX3NlZ3MgPSAxOw0KPiA+ID4gKwkJaWYgKHNrYl9zaGluZm8oc2tiKS0+
bnJfZnJhZ3MgPj0gSTQwRV9NQVhfQlVGRkVSX1RYRCkNCj4gPiA+ICsJCQlza2JfbGluZWFyaXpl
KHNrYik7DQo+ID4NCj4gPiBXaGF0IGV4YWN0bHkgaGFwcGVucyBpZiBza2JfbGluZWFyaXplKCkg
ZmFpbHMgPw0KPiA+DQo+ID4gSXMgdGhpcyAiTWFsaWNpb3VzIERyaXZlciBEZXRlY3QgZXZlbnQi
IGZhdGFsIG9yIHNpbXBseSBwYWNrZXQgaXMNCj4gPiBkcm9wcGVkIHdpdGhvdXQgYWRkaXRpb25h
bCBoYXJtID8NCj4gDQo+IFRoaXMgdHlwaWNhbGx5IGhpdHMgd2hlbiB0aGVyZSBhcmUgbWFueSBs
aXR0bGUgVFNPIHBhY2tldHMgaW4gYSBzaW5nbGUgTVRVIHNpemUgZnJhbWUuICBUaGUgaGFyZHdh
cmUNCj4gZG9lc24ndCBsaWtlIGRlYWxpbmcgd2l0aCBtb3JlIHRoYW4gOCBzZXBhcmF0ZSBidWZm
ZXJzLg0KDQpFeGNlcHQgdGhhdCBhIFRTTyBwYWNrZXQgaXMgbGlrZWx5IHRvIGJlIGp1c3QgdW5k
ZXIgNjRrIGFuZCBjb21wcmlzZSBvZg0KYSBzbWFsbCBoZWFkZXIgYW5kIDE2IG90aGVyIGZyYWdt
ZW50cyAtIG1vc3Qgb2Ygd2hpY2ggd2lsbCBiZSBhIGNvbXBsZXRlIDRrIHBhZ2UuDQoNCklmIHRo
ZSBoYXJkd2FyZSBjYW4ndCBoYW5kbGUgc3VjaCBwYWNrZXRzIHRoZW4gSSBzdXNwZWN0IHlvdSBj
YW4ndCBhY3R1YWxseQ0KdXNlIFRTTyAtIHdoaWNoIG1ha2VzIHRoZSBkZXZpY2UgcHJldHR5IHVz
ZWxlc3MuDQoNCklmIHRoZSBwcm9ibGVtIGlzIGp1c3QgdG9vIG1hbnkgZnJhZ21lbnQgYm91bmRh
cmllcyB3aXRoaW4gYSBzbWFsbCBudW1iZXINCm9mIGJ5dGVzIHRoZW4geW91IG5lZWQgdG8gZGV0
ZWN0IHRoYXQgc3BlY2lmaWMgcHJvYmxlbSAtIHByb2JhYmx5IG1lcmdpbmcNCnRoZSBhZGphY2Vu
dCBzbWFsbCBmcmFnbWVudHMgaW50byBvbmUgdGhhdCBpcyBsYXJnZSBlbm91Z2guDQoNCglEYXZp
ZA0KDQo=
