From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Thu, 10 Dec 2015 12:26:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBEA7A3@AcuExch.aculab.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
 <20151209145917.GA3884@mrl.redhat.com>
 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
 <1449676782.9768.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE9B1C@AcuExch.aculab.com>
 <566860BC.4040604@gmail.com> <56687EBB.5040108@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	"Alexander Potapenko" <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56687EBB.5040108@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRGFuaWVsIEJvcmttYW5uDQo+IFNlbnQ6IDA5IERlY2VtYmVyIDIwMTUgMTk6MTkNCj4g
T24gMTIvMDkvMjAxNSAwNjoxMSBQTSwgTWFyY2VsbyBSaWNhcmRvIExlaXRuZXIgd3JvdGU6DQo+
ID4gRW0gMDktMTItMjAxNSAxNDozMSwgRGF2aWQgTGFpZ2h0IGVzY3JldmV1Og0KPiA+PiBGcm9t
OiBFcmljIER1bWF6ZXQgW21haWx0bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiA+Pj4gU2Vu
dDogMDkgRGVjZW1iZXIgMjAxNSAxNjowMA0KPiA+Pj4gT24gV2VkLCAyMDE1LTEyLTA5IGF0IDE1
OjQ5ICswMDAwLCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4+Pj4+IFNDVFAgaXMgbGFja2luZyBw
cm9wZXIgbnAtPm9wdCBjbG9uaW5nIGF0IGFjY2VwdCgpIHRpbWUuDQo+ID4+Pj4+DQo+ID4+Pj4+
IFRDUCBhbmQgRENDUCB1c2UgaXB2Nl9kdXBfb3B0aW9ucygpIGhlbHBlciwgZG8gdGhlIHNhbWUg
aW4gU0NUUC4NCj4gPj4+Pj4NCj4gPj4+Pj4gV2UgbWlnaHQgbGF0ZXIgZmFjdG9yaXplIHRoaXMg
Y29kZSBpbiBhIGNvbW1vbiBoZWxwZXIgdG8gYXZvaWQNCj4gPj4+Pj4gZnV0dXJlIG1pc3Rha2Vz
Lg0KPiA+Pj4+DQo+ID4+Pj4gSSdtIHdvbmRlcmluZyB3aGF0IHRoZSByZWFsIGltcGFjdCBvZiB0
aGlzIGFuZCB0aGUgb3RoZXIgcmVjZW50DQo+ID4+Pj4gU0NUUCBidWdzL3BhdGNoZXMgaXMgb24g
cmVhbCB3b3JrbG9hZHM/DQo+ID4+Pj4gV2UgaGF2ZSBlbm91Z2ggdHJvdWJsZSBnZXR0aW5nIG91
ciBjdXN0b21lcnMgdG8gdXNlIGtlcm5lbHMNCj4gPj4+PiBsYXRlciB0aGF0IHRoZSAyLjYuMTgg
YmFzZWQgUkhFTDUgLSB3aXRob3V0IGhhdmluZyB0byBwZXJzdWFkZQ0KPiA+Pj4+IHRoZW0gdG8g
dXNlIGtlcm5lbHMgdGhhdCBjb250YWluIHZlcnkgcmVjZW50IGZpeGVzLg0KPiA+Pj4NCj4gPj4+
IEl0IGFsbCBkZXBlbmRzIGlmIHlvdXIgY3VzdG9tZXJzIGxldCAoaG9zdGlsZSA/KSBwZW9wbGUg
cnVuIHByb2dyYW1zIG9uDQo+ID4+PiB0aGUgYm94ZXMuDQo+ID4+DQo+ID4+IElmIHRoZXkgcmVx
dWlyZSBob3N0aWxlIHByb2dyYW1zIEknbSBub3Qgd29ycmllZC4NCj4gPg0KPiA+IE5vdCByZWFs
bHkgInJlcXVpcmUiLCBidXQgImFsbG93IiwgYXMgaW46IGFsbG93aW5nIHRoaXJkLXBhcnR5IGFw
cGxpY2F0aW9ucyB0byBydW4gb24gaXQuDQo+IA0KPiBZZWFoIDovIGdpdmVuIGRpc3Ryb3MgZW5h
YmxlIGFsbW9zdCBldmVyeXRoaW5nIGFueXdheSwgdGhlIGZpcnN0IHVucHJpdidlZA0KPiBzb2Nr
ZXQoLi4uLCBJUFBST1RPX1NDVFApIGNhbGwgYXV0by1sb2FkcyBTQ1RQIG1vZHVsZS4gQnV0IHRv
IGJlIGhvbmVzdCwgSSdkDQo+IGJlIHN1cnByaXNlZCBpZiBDbG91ZCBwcm92aWRlcnMgYWxsb3cg
Zm9yIHRoaXMuIE1vc3Qgb2YgdGhpcyBtaWdodCBvbmx5IHJ1bg0KPiBvbiBkZWRpY2F0ZWQgYm94
ZXMgd2l0aCB0ZWxjbyBhcHBsaWFuY2VzLg0KDQpZZXMsIEknbSB3b3JyaWVkIGFib3V0IHdoZXRo
ZXIgb3VyIE0zVUEgY29kZSBpcyBsaWtlbHkgdG8gY3Jhc2ggY3VzdG9tZXINCnN5c3RlbXMsIG5v
dCB3aGV0aGVyIGhvc3RpbGUgYXBwbGljYXRpb25zIGNhbiBjcmFzaCBpdC4NClRoZXNlIGJveGVz
IG91Z2h0IHRvIGJlIG9uIHByaXZhdGUgbmV0d29ya3Mgc2luY2UgdGhlIHNpZ3RyYW4gcHJvdG9j
b2xzDQp0aGVtc2VsdmVzIGhhdmUgbm90aGluZyB0aGF0IGV2ZW4gZ2l2ZXMgYSBoaW50IG9mIHNl
Y3VyaXR5Lg0KDQoJRGF2aWQNCg==
