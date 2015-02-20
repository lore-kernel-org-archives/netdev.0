From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/3] rhashtable: better high order allocation
 attempts
Date: Fri, 20 Feb 2015 14:27:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
	 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
 <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:58241 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbbBTO2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:28:45 -0500
In-Reply-To: <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIEZyaSwgMjAxNS0wMi0yMCBhdCAxMDoxMSArMDAwMCwg
RGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiA+IEZyb206IERhbmllbCBCb3JrbWFubg0KPiA+ID4gV2hl
biB0cnlpbmcgdG8gYWxsb2NhdGUgZnV0dXJlIHRhYmxlcyB2aWEgYnVja2V0X3RhYmxlX2FsbG9j
KCksIGl0IHNlZW1zDQo+ID4gPiBvdmVya2lsbCBvbiBsYXJnZSB0YWJsZSBzaGlmdHMgdGhhdCB3
ZSBwcm9iZSBmb3Iga3phbGxvYygpIHVuY29uZGl0aW9uYWxseQ0KPiA+ID4gZmlyc3QsIGFzIGl0
J3MgbGlrZWx5IHRvIGZhaWwuDQo+ID4NCj4gPiBIb3cgYWJvdXQgYSB0d28tbGV2ZWwgYXJyYXkg
Zm9yIGxhcmdlIHRhYmxlcz8NCj4gPiBUaGVuIHlvdSBkb24ndCBuZWVkIHRvIGFsbG9jYXRlIG1v
cmUgdGhhbiAxIHBhZ2UgYXQgYSB0aW1lPw0KPiANCj4gVGhpcyBpcyBjYWxsZWQgdm1hbGxvYygp
IGluIGxpbnV4IGtlcm5lbC4NCg0Kdm1hbGxvYygpIHN0aWxsIHJlcXVpcmVzIGNvbnRpZ3VvdXMg
S1ZBLCBqdXN0IG5vdCBjb250aWd1b3VzIHBoeXNpY2FsIG1lbW9yeS4NCkkgYWxzbyBiZWxpZXZl
IHRoYXQgKG9uIHNvbWUgc3lzdGVtcyBhdCBsZWFzdCkgdGhlIGFkZHJlc3Mgc3BhY2UgZm9yDQp2
bWFsbG9jKCkgaXMgbXVjaCBzbWFsbGVyIHRoYW4gdGhhdCBmb3Iga2FsbG9jKCkuDQoNCklJUkMg
QXQgbGVhc3Qgb25lIHBpZWNlIG9mIGhpc3RvcmljIGRvY3VtZW50YXRpb24gc2F5cyB0aGF0IHZt
YWxsb2MoKSBzaG91bGQNCm9ubHkgYmUgdXNlZCBmb3Igc2hvcnQgdGVybSBhbGxvY2F0aW9ucy4N
Cg0KSSBwcmVzdW1lIHRoaXMgY29kZSBpcyBhbGxvY2F0aW5nIHZlcnkgbGFyZ2UgYXJyYXlzIGZv
ciB0aGUgYmFzZSBvZiB0aGUgaGFzaCBsaXN0cy4NClNpbmNlIHRoZXJlIGlzIG5vIGFic29sdXRl
IHJlcXVpcmVtZW50IGZvciBjb250aWd1b3VzIEtWQSAobm90aGluZw0Kc2VxdWVudGlhbGx5IGFj
Y2Vzc2VzIHRoZSBlbnRpcmUgYXJyYXkpIGl0IGNhbiBiZSBjb2RlZCBkaWZmZXJlbnRseS4NCg0K
SSByZWFsaXplIHRoYXQgdGhpcyB3b3VsZCBpbnZvbHZlIGFuIGV4dHJhIGRhdGEgY2FjaGUgbGlu
ZSBhY2Nlc3MuDQpTbyB5b3UnZCB3YW50IHRvIGF2b2lkIGl0IGZvciBzbWFsbCB0YWJsZXMuDQoo
SSBleHBlY3RlZCB0aGlzIHRvIGJlIHlvdXIgb2JqZWN0aW9uKQ0KDQoJRGF2aWQNCg0K
