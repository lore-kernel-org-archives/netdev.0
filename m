From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Mon, 24 Feb 2014 06:43:19 +0000
Message-ID: <9c030828-b9eb-4c55-a31a-c3b0963ee054@CMEXHTCAS1.ad.emulex.com>
References: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
	 <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
 <1393033796.15717.90.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"wang.liang82@zte.com.cn" <wang.liang82@zte.com.cn>,
	"cai.qu@zte.com.cn" <cai.qu@zte.com.cn>,
	"li.fengmao@zte.com.cn" <li.fengmao@zte.com.cn>,
	"long.chun@zte.com.cn" <long.chun@zte.com.cn>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8357 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbaBXGnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 01:43:25 -0500
In-Reply-To: <1393033796.15717.90.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWls
dG86YmVuQGRlY2FkZW50Lm9yZy51a10NCj4gDQo+IE9uIFRodSwgMjAxNC0wMi0yMCBhdCAwOToz
OSArMDAwMCwgU2F0aHlhIFBlcmxhIHdyb3RlOg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdl
LS0tLS0NCj4gPiA+IEZyb206IGppYW5nLmJpYW8yQHp0ZS5jb20uY24gW21haWx0bzpqaWFuZy5i
aWFvMkB6dGUuY29tLmNuXQ0KPiA+ID4NCj4gPiA+DQo+ID4gPiBGcm9tOiBMaSBGZW5nbWFvIDxs
aS5mZW5nbWFvQHp0ZS5jb20uY24+DQo+ID4gPg0KPiA+ID4gVGhlcmUgd2lsbCBiZSBwYWNrZXQg
ZHJvcCB3aXRoIGtlcm5lbCBwYXJhbSAic3dpb3RsYiA9IGZvcmNlIiBvbg0KPiA+ID4gRW11bGV4
IDEwR2IgTklDIHVzaW5nIGJlMm5ldCBkcml2ZXIuIFRoZSBwcm9ibGVtIGlzIGNhdXNlZCBieQ0K
PiA+ID4gcmVjZWl2aW5nIHNrYiB3aXRob3V0IGNhbGxpbmcgcGNpX3VubWFwX3BhZ2UoKSBpbiBn
ZXRfcnhfcGFnZV9pbmZvKCkuDQo+ID4gPiByeF9wYWdlX2luZm8tPmxhc3RfcGFnZV91c2VyIGlz
IGluaXRpYWxpemVkIHRvIGZhbHNlIGluDQo+ID4gPiBiZV9wb3N0X3J4X2ZyYWdzKCkgd2hlbiBj
dXJyZW50IGZyYWcgYXJlIG1hcHBlZCBpbiB0aGUgZmlyc3QgaGFsZiBvZg0KPiA+ID4gdGhlIHNh
bWUgcGFnZSB3aXRoIGFub3RoZXIgZnJhZy4gQnV0IGluIHRoYXQgY2FzZSB3aXRoDQo+ID4gPiAi
c3dpb3RsYiA9IGZvcmNlIiBwYXJhbSwgZGF0YSBjYW4gbm90IGJlIGNvcGllZCBpbnRvIHRoZSBw
YWdlIG9mDQo+ID4gPiByeF9wYWdlX2luZm8gd2l0aG91dCBjYWxsaW5nIHBjaV91bm1hcF9wYWdl
LCBzbyB0aGUgZGF0YSBmcmFnIG1hcHBlZA0KPiA+ID4gaW4gdGhlIGZpcnN0IGhhbGYgb2YgdGhl
IHBhZ2Ugd2lsbCBiZSBkcm9wcGVkLg0KPiA+ID4NCj4gPiA+IEl0IGNhbiBiZSBzb2x2ZWQgYnkg
Y3JlYXRpbmcgb25seSBhIG1hcHBpbmcgcmVsYXRpb24gYmV0d2VlbiBmcmFnDQo+ID4gPiBhbmQg
cGFnZSwgYW5kIGRlbGV0aW5nIHJ4X3BhZ2VfaW5mby0+bGFzdF9wYWdlX3VzZXIgdG8gZW5zdXJl
DQo+ID4gPiBjYWxsaW5nIHBjaV91bm1hcF9wYWdlIHdoZW4gaGFuZGxpbmcgZWFjaCByZWNlaXZp
bmcgZnJhZy4NCj4gPg0KPiA+IFRoaXMgcGF0Y2ggdXNlcyBhbiBlbnRpcmUgcGFnZSBmb3IgZWFj
aCBSWCBmcmFnICh3aG9zZSBkZWZhdWx0IHNpemUgaXMgMjA0OCkuDQo+ID4gQ29uc2VxdWVudGx5
LCBvbiBwbGF0Zm9ybXMgbGlrZSBwcGM2NCB3aGVyZSB0aGUgZGVmYXVsdCBQQUdFX1NJWkUgaXMg
NjRLLA0KPiA+IG1lbW9yeSB1c2FnZSBiZWNvbWVzIHZlcnkgaW5lZmZpY2llbnQuDQo+ID4NCj4g
PiBJbnN0ZWFkLCBJJ3ZlIHRyaWVkIGEgcGFydGlhbC1wYWdlIG1hcHBpbmcgc2NoZW1lLiBUaGlz
IHJldGFpbnMgdGhlDQo+ID4gcGFnZSBzaGFyaW5nIGxvZ2ljLCBidXQgdW4tbWFwcyBlYWNoIGZy
YWcgc2VwYXJhdGVseSBzbyB0aGF0DQo+ID4gdGhlIGRhdGEgaXMgY29waWVkIGZyb20gdGhlIGJv
dW5jZSBidWZmZXJzLg0KPiBbLi4uXQ0KPiANCj4gWW91IGRvbid0IG5lZWQgdG8gbWFwL3VubWFw
IGVhY2ggZnJhZ21lbnQgc2VwYXJhdGVseTsgeW91IGNhbiBzeW5jIGENCj4gc3ViLXBhZ2UgcmFu
Z2Ugd2l0aCBkbWFfc3luY19zaW5nbGVfZm9yX2NwdSgpLg0KPiANCg0KSGEsIHllcyEgVGhhbmtz
IGZvciB0aGUgdGlwLi4uLg0KLVNhdGh5YQ0K
