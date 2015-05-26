From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Tue, 26 May 2015 15:13:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB3ECB8@AcuExch.aculab.com>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
 <1432650922.4060.236.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:56138 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbbEZPPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 11:15:10 -0400
In-Reply-To: <1432650922.4060.236.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI2IE1heSAyMDE1IDE1OjM1DQo+IE9uIFR1ZSwg
MjAxNS0wNS0yNiBhdCAxMzo0MCArMDAwMCwgRGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiANCj4gPiBJ
ZiB0aGUgSklUIGNvbXBpbGVyIGlzIG9ubHkgY2hhbmdpbmcgdGhlIGVuY29kaW5nIG9mIHRoZSBj
b25zdGFudHMNCj4gPiBpbiB0aGUgeDg2IGluc3RydWN0aW9ucyAocmF0aGVyIHRoYW4gY2hhbmdp
bmcgdGhlIGluc3RydWN0aW9ucyB0aGVtc2VsdmVzKQ0KPiA+IHRoZW4gdGhlcmUgaXMgbGlrZWx5
IHRvIG1lIGFuIHVubWVhc3VyYWJsZSBjaGFuZ2UgaW4gdGhlIGV4ZWN1dGlvbiB0aW1lLg0KPiA+
IEZvciBpbnN0YW5jZSBJIGRvbid0IHJlbWVtYmVyIHRoZXJlIGJlaW5nIGEgZGlmZmVyZW5jZSBp
biBleGVjdXRpb24gdGltZQ0KPiA+IGJldHdlZW4gbG9uZyBhbmQgc2hvcnQgYnJhbmNoZXMgLSB0
aGUgb25seSBkaWZmZXJlbmNlIGlzIHRoZSBhbW91bnQgb2YNCj4gPiBjYWNoZSB0aGV5IHVzZS4N
Cj4gDQo+IGljYWNoZSBpcyBwcmVjaXNlbHkgdGhlIG1hdHRlciBoZXJlLiBJbiB0aGUgZW5kLCBp
dCBtYWtlcyBhIGRpZmZlcmVuY2UuDQo+IA0KPiBZb3UgY291bGQgY2hlY2sgdGhpcyBpbnRlcmVz
dGluZyBzdHVkeSBJbmdvIGRpZCByZWNlbnRseSA6DQo+IA0KPiBodHRwczovL2xrbWwub3JnL2xr
bWwvMjAxNS81LzE5LzEwMDkNCg0KWWVzLCBpbnRlcmVzdGluZywgYSBiZW5jaG1hcmsgdGhhdCBt
YW5hZ2VzIHRvIHJ1biBhIGxvdCBvZiBjb2RlICdjb2xkIGNhY2hlJy4NClBvc3NpYmx5IGRvbWlu
YXRlZCBieSBoYXZpbmcgYSBmdWxsIGNhY2hlIGxpbmUgb2YgY29kZSB0byBleGVjdXRlIGF0IHRo
ZQ0KYmVnaW5uaW5nIG9mIGVhY2ggZnVuY3Rpb24uDQoNCk15IGd1ZXNzIGlzIHRoYXQgYWxpZ25p
bmcgZnVuY3Rpb24gYm9kaWVzIGhlbHBzLCBhbGlnbmluZyBicmFuY2ggdGFyZ2V0cw0KKGFzIHNv
bWUgb2xkIHZlcnNpb25zIG9mIGdjYyB1c2VkIHRvIGRvIGFnZ3Jlc3NpdmVseSkgaXMgbW9yZSBs
aWtlbHkgdG8NCmhhdmUgYSBuZWdhdGl2ZSBlZmZlY3QgKGluY3JlYXNlcyB0aGUgaWNhY2hlIGZv
b3RwcmludCB0b28gbXVjaCkuDQpVbnJvbGxpbmcgbG9vcHMgZnVydGhlciB0aGFuIG5lZWRlZCB0
byBhdm9pZCBkYXRhIHN0YWxscyBuZWVkcyB2ZXJ5DQpjYXJlZnVsIHN0dWR5Lg0KDQpGb3IgSklU
LCBvbmNlIHRoZSBvYnZpb3VzbHkgc2hvcnQgYnJhbmNoZXMgaGF2ZSBiZWVuIHJlZHVjZWQsIGZ1
cnRoZXIgY29kZQ0Kc2l6ZSByZWR1Y3Rpb24gbWlnaHQgbm90IGJlIHdvcnRoIHdoaWxlLg0KDQoJ
RGF2aWQNCg0K
