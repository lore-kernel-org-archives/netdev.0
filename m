From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] r6040: use ETH_ZLEN instead of MISR for
 SKB length checking
Date: Thu, 16 Jan 2014 09:10:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45D812@AcuExch.aculab.com>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
	 <1389819866-32142-3-git-send-email-florian@openwrt.org>
 <1389857001.19462.33.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Ben Hutchings' <ben@decadent.org.uk>,
	Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47839 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751325AbaAPJMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 04:12:31 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23017-03 for <netdev@vger.kernel.org>;
 Thu, 16 Jan 2014 09:12:26 +0000 (GMT)
In-Reply-To: <1389857001.19462.33.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmVuIEh1dGNoaW5ncw0KPiBPbiBXZWQsIDIwMTQtMDEtMTUgYXQgMTM6MDQgLTA4MDAs
IEZsb3JpYW4gRmFpbmVsbGkgd3JvdGU6DQo+ID4gRXZlciBzaW5jZSB0aGlzIGRyaXZlciB3YXMg
bWVyZ2VkIHRoZSBmb2xsb3dpbmcgY29kZSB3YXMgaW5jbHVkZWQ6DQouLi4NCj4gPiAtCWlmIChz
a2ItPmxlbiA8IE1JU1IpDQo+ID4gLQkJZGVzY3B0ci0+bGVuID0gTUlTUjsNCj4gPiArCWlmIChz
a2ItPmxlbiA8IEVUSF9aTEVOKQ0KPiA+ICsJCWRlc2NwdHItPmxlbiA9IEVUSF9aTEVOOw0KPiAN
Cj4gSXQgbG9va3MgbGlrZSB0aGlzIGlzIGp1c3QgaW5jcmVhc2luZyB0aGUgVFggZGVzY3JpcHRv
ciBsZW5ndGggc28gdGhlDQo+IHBhY2tldCBpcyB0YWlsLXBhZGRlZCB3aXRoIHdoYXRldmVyIGhh
cHBlbnMgdG8gY29tZSBuZXh0IGluIHRoZSBza2IuDQo+IFRoaXMgaXMgYWJzb2x1dGVseSBpbmNv
cnJlY3QgYmVoYXZpb3VyIGFuZCBtYXkgbGVhayBzZW5zaXRpdmUNCj4gaW5mb3JtYXRpb24uDQoN
CkFuZCBwb3NzaWJseSBwYWdlIGZhdWx0IGlmIHRoZSBkYXRhIGlzIHJpZ2h0IGF0IHRoZSBlbmQg
b2YgYSBwYWdlLg0KDQo+IFByZXN1bWFibHkgaXQgaXMgbmVjZXNzYXJ5IHRvIHBhZCB0aGUgZnJh
bWUgYmVjYXVzZSB0aGUgTUFDIGlzIHRvbyBsYW1lDQo+IHRvIGRvIGl0LCBhbmQgdGhlIGNvcnJl
Y3Qgd2F5IHRvIGRvIHRoYXQgaXMgdXNpbmcgc2tiX3BhZHRvKHNrYiwNCj4gRVRIX1pMRU4pLiAg
QnV0IHRoaXMgbWF5IGZhaWwgYXMgaXQgbWlnaHQgaGF2ZSB0byBhbGxvY2F0ZSBtZW1vcnkNCg0K
QWx0ZXJuYXRpdmVseSB1c2UgdHdvIHJpbmcgZW50cmllcyB3aXRoIHRoZSAnbW9yZScgYml0IHNl
dCBvbg0KdGhlIGZpcnN0IG9uZSBhbmQgdHJhbnNtaXQgdGhlIHBhZGRpbmcgZnJvbSBhIHBlcm1h
bmVudGx5IGFsbG9jYXRlZA0KYW5kIGRtYS1tYXBwZWQgYmxvY2sgb2YgemVyb3MuDQpBc3N1bWlu
ZyB0aGUgaGFyZHdhcmUgc3VwcG9ydCBTRyB0cmFuc21pdCBhbmQgZG9lc24ndCBoYXZlIGENCmNv
bnN0cmFpbnQgb24gdGhlIGxlbmd0aCBvZiB0aGUgZmlyc3QgZnJhZ21lbnQuDQoNCk9yIGhhdmUg
YSBwcmUtYWxsb2NhdGVkIGFuIGRtYS1tYXBwZWQgYXJyYXkgb2Ygc2hvcnQgYnVmZmVycyAob25l
DQpmb3IgZWFjaCByaW5nIHNsb3QpIGFuZCBjb3B5IHNob3J0IHBhY2tldHMgaW50byB0aGUgYXJy
YXkgaW5zdGVhZA0Kb2YgZG1hLW1hcHBpbmcgdGhlIHNrYiBkYXRhLg0KDQoJRGF2aWQNCg0K
