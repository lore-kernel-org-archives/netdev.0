From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] bnx2x: avoid soft lockup in bnx2x_poll()
Date: Wed, 9 Dec 2015 10:41:08 +0000
Message-ID: <CO2PR11MB0088284CEFC5C6FEC40AD67397E80@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CO2PR11MB00881A410C4E35D3859CB84C97080@CO2PR11MB0088.namprd11.prod.outlook.com>
 <1449597817.6639.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0105.outbound.protection.outlook.com ([207.46.100.105]:20396
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752507AbbLIKlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 05:41:12 -0500
In-Reply-To: <1449597817.6639.4.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gVW5kZXIgaGVhdnkgVFggbG9hZCwgYm54MnhfcG9sbCgpIGNhbiBsb29wIGZvcmV2ZXIg
YW5kIHRyaWdnZXIgc29mdCBsb2NrdXANCj4gYnVncy4NCj4gPiA+DQo+ID4gPiBBIG5hcGkgcG9s
bCBoYW5kbGVyIG11c3QgeWllbGQgYWZ0ZXIgb25lIFRYIGNvbXBsZXRpb24gcm91bmQsIHJpc2sN
Cj4gPiA+IG9mIGxpdmVsb2NrIGlzIHRvbyBoaWdoIG90aGVyd2lzZS4NCj4gPiA+DQo+ID4gPiBC
dWcgaXMgdmVyeSBlYXN5IHRvIHRyaWdnZXIgdXNpbmcgYSBkZWJ1ZyBidWlsZCwgYW5kIHVkcCBm
bG9vZCwNCj4gPiA+IGJlY2F1c2Ugb2YgYWRkZWQgY3B1IGN5Y2xlcyBpbiBUWCBjb21wbGV0aW9u
LCBhbmQgd2UgZG8gbm90IHJlY2VpdmUNCj4gPiA+IGVub3VnaCBwYWNrZXRzIHRvIGJyZWFrIHRo
ZSBsb29wLg0KPiA+DQo+ID4gRXJpYyAtIEkgdW5kZXJzdGFuZCB3aGF0IHlvdSdyZSBkb2luZyBh
bmQgaXQgbG9va3MgZmluZSBbdG8gbWUsIGF0IGxlYXN0XS4NCj4gPiBPdXQgb2YgY3VyaW9zaXR5
LCBkbyB5b3Uga25vdyB3aGV0aGVyIHJlbW92aW5nIHRoZSBsb29wIGRhbWFnZXMgYW55DQo+ID4g
b3RoZXIgZmxvdywgaS5lLiwgYnkgc2xvd2luZyB0cmFuc21pdHRlciBhcyB0cmFuc21pc3Npb24g
cmluZ3MgZ2V0cw0KPiA+IGZpbGxlZCBjb21wbGV0ZWx5IGJldHdlZW4gY29uc2VjdXRpdmUgTkFQ
SSBydW5zPw0KPiANCj4gSSBzYXcgbm8gZG93bnNpZGVzIHlldC4gTW9zdCBvZiB0aGUgdGltZSBU
WCBhcmUgYmxvY2tlZCBieSBCUUwgdGhlc2UgZGF5cywNCj4gYmVmb3JlIGNvbXBsZXRlIFRYIHJp
bmcgZmlsbGluZy4NCj4gDQo+IEkgYWRkZWQgc29tZSBpbnN0cnVtZW50YXRpb24sIGFuZCBldmVu
IGFmdGVyIHRoZSBwYXRjaCBhbmQgYSBub24tZGVidWcga2VybmVsDQo+IHdlIGNhbiBzZWUgOg0K
PiANCj4gYm54Mng6IGJueDJ4X3BvbGwoKSB0b29rIDQ1NTAzNiBuc2VjDQo+IA0KPiA0NTUgdXNl
YyBvbiBvbmUgYm54MnhfcG9sbCgpIGlzIGFscmVhZHkgcXVpdGUgYmlnLCBidXQgb25lIGNhbiB0
d2VhayBUWCByaW5nDQo+IChldGh0b29sIC1HIGV0aDEgdHggLi4uLikgaWYgbGF0ZW5jaWVzIGFy
ZSBhIHNlcmlvdXMgY29uY2Vybi4NCj4gDQo+IE5vdGUgdGhhdCBteSBwYXRjaCBzaG91bGQgbm90
IHNsb3cgdHJhbnNtaXR0ZXJzLCBvbmx5IGdpdmUgYSBjaGFuY2UgZm9yIG90aGVyDQo+IHNvZnRp
cnFzIGJlaW5nIHNlcnZpY2VkLCBhbmQgZXZlbnR1YWxseSBnaXZlIGNvbnRyb2wgdG8ga3NvZnRp
cnFkIHVuZGVyIHN0cmVzcy4NCj4gDQoNCkNvb2wuIFRoYW5rcyBFcmljLg0KDQpBY2tlZC1ieTog
WXV2YWwgTWludHogPFl1dmFsLk1pbnR6QHFsb2dpYy5jb20+DQo=
