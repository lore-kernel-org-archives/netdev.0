From: "Asano, Yasushi" <yasushi.asano@jp.fujitsu.com>
Subject: RE: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing
 behavior while valid_lft is infinity
Date: Sun, 29 Dec 2013 05:57:18 +0000
Message-ID: <4AE7B88EC8BA74469869BB7EEB7D66671BF89B27@g01jpexmbyt23>
References: <1386843347-2725-1-git-send-email-yazzep@gmail.com>
 <1386956028-3463-1-git-send-email-yazzep@gmail.com>
 <20131214091917.GB23563@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"yazzep@gmail.com" <yazzep@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:49351 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab3L2F5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 00:57:24 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 306FD3EE1AC
	for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:57:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 208C245DE5A
	for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:57:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0135145DE55
	for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:57:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B481DB804A
	for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:57:20 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CDB91DB804E
	for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:57:20 +0900 (JST)
In-Reply-To: <20131214091917.GB23563@order.stressinduktion.org>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBEaXR0bywgSSBkbyB0aGluayB3ZSBjYW5ub3QgcmVtb3ZlIHRoaXMgZmxhZyB1bmNvbmRpdGlv
bmFsbHkuDQo+IA0KPiBBY3R1YWxseSwgSSBkb24ndCB0aGluayBpdCBpcyB0aGUgY29ycmVjdCB3
YXkgdG8gcmVtb3ZlIHRoZSBJRkFfRl9QRVJNQU5FTlQNCj4gaGVyZSBhdCBhbGwuIFdlIGJyZWFr
IHRoZSBpbnRlcmFjdGlvbiB3aXRoIHByZWZpeCByb3V0ZXMgYW5kIHdvbid0IHJlbW92ZQ0KPiB0
aGVtDQo+IGF0IHRoZSB0aW1lIG9mIGFkZHJlc3MgZGVsZXRpb24gYW55IG1vcmUuIFRoaXMgaXMg
ZGVmaW5pdGVseSBhIG5vLWdvLCBzb3JyeS4NCj4gDQo+IFRoZSBwcmVmaXggd2FzIGFkZGVkIGJ5
IGhhbmQgYW5kIHNob3VsZCBnZXQgcmVtb3ZlZCBpbW1lZGlhdGVseSBpZiBhIHVzZXINCj4gcmVt
b3ZlcyB0aGUgYWRkcmVzcyAod2VsbCBhY3R1YWxseSBpdCBpcyBhbiBlcnJvciB3ZSBzZXQgdXAg
YSBwcmVmaXggcm91dGUNCj4gaW4NCj4gdGhlIGZpcnN0IHBsYWNlLCBidXQgaXQgaXMgaG93IHRo
aW5ncyBhcmUgbm93KS4NCj4gDQo+IElNSE8sIHRoZSBjaGFuZ2VzIG5lZWQgdG8gYmUgbWFkZSBp
biBhZGRyY29uZl92ZXJpZnkgc28gdGhhdCB0aGUgcm91dGUgZG9lcw0KPiBnZXQgbWFya2VkIGFz
IGRlcHJlY2F0ZWQuIFBsZWFzZSBjaGVjayB0aGUgcGxhY2VzIHdoZXJlIHdlIG1hcmsgYW4gaW50
ZXJmYWNlDQo+IGFkZHJlc3MgYXMgZGVwcmVjYXRlZC4NCj4gDQo+IFRoYW5rcywNCj4gDQo+ICAg
SGFubmVzDQoNClNvcnJ5IGFib3V0IG5vdCBnZXR0aW5nIGJhY2sgdG8geW91IHNvb25lci4NCkkg
aGF2ZSBiZWVuIHRoaW5raW5nIGFuZCB0ZXN0aW5nIGFib3V0IHRoZSBjb3JyZWN0IHdheSBvZiBm
aXhpbmcgdGhlIHByb2JsZW0uDQpJIHVuZGVyc3RhbmQgaXQncyBub3QgdGhlIGNvcnJlY3Qgd2F5
IHRvIHJlbW92ZSB0aGUgSUZBX0ZfUEVSTUFORU5ULiANCkkgYWdyZWUgd2l0aCB5b3UgdGhhdCB0
aGUgY2hhbmdlcyBuZWVkIHRvIGJlIG1hZGUgaW4gYWRkcmNvbmZfdmVyaWZ5Lg0KYW5kIEkgdGhp
bmsgdGhlIGNoYW5nZXMgYWxzbyBuZWVkIHRvIGJlIG1hZGUgaW4gaW5ldDZfZmlsbF9pZmFkZHIN
CnNvIHRoYXQgdGhlICJwcmVmZXJyZWQiIGlzIHNldCBJTkZJTklUWV9MSUZFX1RJTUUgdW5jb25k
aXRpb25hbGx5IHdoaWxlIA0KaWZhLT5mbGFncyBpcyBJRkFfRl9QRVJNQU5FTlQuDQpJdCBtZWFu
cywgInByZWZlcnJlZCIgaXMgc2V0IHRvIElORklOSVRZX0xJRkVfVElNRSB3aGVuIEkgc2V0IHBy
ZWZlcnJlZF9sZnQgYSB2YWx1ZSANCm5vdCB6ZXJvIG9yIGluZmluaXR5LCB3aGlsZSB2YWxpZF9s
ZnQgaXMgaW5maW5pdHkoMHhmZmZmZmZmZikNCkkgYW0gZ29pbmcgdG8gc2VuZCBhIG5ldyBwYXRj
aCBzb29uLg0KWW91ciBraW5kIGNvbnNpZGVyYXRpb24gb2YgdGhpcyBtYXR0ZXIgd291bGQgYmUg
c2luY2VyZWx5IGFwcHJlY2lhdGVkLg0KDQpZYXN1c2hpDQo=
