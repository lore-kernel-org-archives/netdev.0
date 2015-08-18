From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] inet: fix potential deadlock in reqsk_queue_unlink()
Date: Tue, 18 Aug 2015 13:57:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB7E83F@AcuExch.aculab.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB7E6FA@AcuExch.aculab.com>
 <1439905003.6443.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:57048 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbbHROA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 10:00:27 -0400
In-Reply-To: <1439905003.6443.2.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBTZW50OiAxOCBBdWd1c3QgMjAxNSAxNDozNw0KPiBPbiBU
dWUsIDIwMTUtMDgtMTggYXQgMTE6MDQgKzAwMDAsIERhdmlkIExhaWdodCB3cm90ZToNCj4gPiBG
cm9tOiBFcmljIER1bWF6ZXQNCj4gPiA+IFNlbnQ6IDEzIEF1Z3VzdCAyMDE1IDIzOjQ1DQo+ID4g
PiBXaGVuIHJlcGxhY2luZyBkZWxfdGltZXIoKSB3aXRoIGRlbF90aW1lcl9zeW5jKCksIEkgaW50
cm9kdWNlZA0KPiA+ID4gYSBkZWFkbG9jayBjb25kaXRpb24gOg0KPiA+ID4NCj4gPiA+IHJlcXNr
X3F1ZXVlX3VubGluaygpIGlzIGNhbGxlZCBmcm9tIGluZXRfY3NrX3JlcXNrX3F1ZXVlX2Ryb3Ao
KQ0KPiA+ID4NCj4gPiA+IGluZXRfY3NrX3JlcXNrX3F1ZXVlX2Ryb3AoKSBjYW4gYmUgY2FsbGVk
IGZyb20gbWFueSBjb250ZXh0cywNCj4gPiA+IG9uZSBiZWluZyB0aGUgdGltZXIgaGFuZGxlciBp
dHNlbGYgKHJlcXNrX3RpbWVyX2hhbmRsZXIoKSkuDQo+ID4gPg0KPiA+ID4gSW4gdGhpcyBjYXNl
LCBkZWxfdGltZXJfc3luYygpIGxvb3BzIGZvcmV2ZXIuDQo+ID4gPg0KPiA+ID4gU2ltcGxlIGZp
eCBpcyB0byB0ZXN0IGlmIHRpbWVyIGlzIHBlbmRpbmcuDQo+ID4NCj4gPiBEb2Vzbid0IHRoYXQg
bWVhbiB5b3UgZmFpbCB0byB3YWl0IGZvciB0aGUgdGltZXIgZnVuY3Rpb24NCj4gPiB0byBmaW5p
c2ggaWYgeW91IGFyZSBjYWxsaW5nIGZyb20gYSBkaWZmZXJlbnQgY29udGV4dD8NCj4gDQo+IE5v
LCB0aGlzIGlzIHRoZSBwdXJwb3NlIG9mIGRlbF90aW1lcl9zeW5jKCkNCg0KSSB3YXNuJ3Qgd29y
cmllZCBhYm91dCBkZWxfdGltZXJfc3luYygpLg0KVGhlIHByb2JsZW0gaXMgdGhlIGNhbGwgdG8g
dGltZXJfcGVuZGluZygpLg0KDQpJZiB0aGUgdGltZXIgaGFzIGp1c3QgZXhwaXJlZCwgYW5kIHRo
ZSB0aW1lb3V0IGZ1bmN0aW9uIGlzIHJ1bm5pbmcNCihvbiBhbm90aGVyIGNwdSkgdGhlbiB0aW1l
cl9wZW5kaW5nKCkgd2lsbCByZXR1cm4gZmFsc2UuDQpTbyBhbnkgdGlkeXVwIHBhdGggKGFwYXJ0
IGZyb20gdGhhdCBjYWxsZWQgYnkgdGhlIHRpbWVvdXQgZnVuY3Rpb24gaXRzZWxmKQ0Kd2lsbCBm
YWlsIHRvIHdhaXQgZm9yIHRoZSBmdW5jdGlvbiB0byBmaW5pc2guDQoNClNvLCBpbiBlZmZlY3Qs
IHlvdSd2ZSBjb252ZXJ0ZWQgdGhlIGNvZGUgYmFjayBpbnRvIGEgY2FsbCB0byBkZWxfdGltZXIo
KS4NCg0KdGltZXJfcGVuZGluZygpIHNob3VsZCBwcm9iYWJseSBuZXZlciBiZSBjYWxsZWQgd2l0
aG91dCB0aGUgcmVsZXZhbnQNCnRpbWVyIGxvY2sgaGVscCAtIGJlY2F1c2UgdGhlIHJlc3VsdCBp
cyBzdGFsZS4NCg0KCURhdmlkDQoNCg==
