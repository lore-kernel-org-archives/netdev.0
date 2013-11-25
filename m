From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Mon, 25 Nov 2013 12:22:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7443@saturn3.aculab.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>		 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>	 <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>	 <5291AA8D.6060108@gmail.com> <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com> <5292C76E.1070701@huawei.com> <52933CC7.9070805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev" <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: "Yang Yingliang" <yangyingliang@huawei.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34322 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751128Ab3KYMYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 07:24:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31362-10 for <netdev@vger.kernel.org>;
 Mon, 25 Nov 2013 12:24:31 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52933CC7.9070805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBZYW5nIFlpbmdsaWFuZyA8eWFuZ3lpbmdsaWFuZ0BodWF3ZWkuY29tPg0KPiANCj4g
Q3VycmVudCBtYXhfc2l6ZSBpcyBjYWx1YXRlZCBmcm9tIHJhdGUgdGFibGUuIE5vdywgdGhlIHJh
dGUgdGFibGUNCj4gaGFzIGJlZW4gcmVwbGFjZWQgYW5kIGl0J3Mgd3JvbmcgdG8gY2FjdWxhdGUg
bWF4X3NpemUgYmFzZWQgb24gdGhpcw0KPiByYXRlIHRhYmxlLiBJdCBjYW4gbGVhZCB3cm9uZyBj
YWxjdWxhdGlvbiBvZiBtYXhfc2l6ZS4NCj4gDQo+IFRoZSBidXJzdCBpbiBrZXJuZWwgbWF5IGJl
IGxvd2VyIHRoYW4gdXNlciBhc2tlZCwgYmVjYXVzZSBidXJzdCBtYXkgZ2V0cw0KPiBzb21lIGxv
c3Mgd2hlbiB0cmFuc2Zvcm0gaXQgdG8gYnVmZmVyKEUuZy4gImJ1cnN0IDQwa2IgcmF0ZSAzMG1i
aXQvcyIpDQo+IGFuZCBpdCBzZWVtcyB3ZSBjYW5ub3QgYXZvaWQgdGhpcyBsb3NzLiBBbmQgYnVy
c3QncyB2YWx1ZShtYXhfc2l6ZSkgYmFzZWQNCj4gb24gcmF0ZSB0YWJsZSBtYXkgYmUgZXF1YWwg
dXNlciBhc2tlZC4gSWYgYSBwYWNrZXQncyBsZW5ndGggaXMgbWF4X3NpemUsDQo+IHRoaXMgcGFj
a2V0IHdpbGwgYmUgc3RhbGxlZCBpbiB0YmZfZGVxdWV1ZSgpIGJlY2F1c2UgaXRzIGxlbmd0aCBp
cyBhYm92ZQ0KPiB0aGUgYnVyc3QgaW4ga2VybmVsIHNvIHRoYXQgaXQgY2Fubm90IGdldCBlbm91
Z2ggdG9rZW5zLiBUaGUgbWF4X3NpemUgZ3VhcmRzDQo+IGFnYWluc3QgZW5xdWV1aW5nIHBhY2tl
dCBzaXplcyBhYm92ZSBxLT5idWZmZXIgInRpbWUiIGluIHRiZl9lbnF1ZXVlKCkuDQoNCldoeSBu
b3QgYWRqdXN0IHRoZSBjYWxjdWxhdGlvbnMgc28gdGhhdCB0aGUgbnVtYmVyIG9mIGFsbG9jYXRl
ZCB0b2tlbnMNCmNhbiBnbyBuZWdhdGl2ZT8NCg0KU28gYWxsb3cgdGhlIHRyYW5zZmVyIGlmIHRo
ZSBudW1iZXIgb2YgdG9rZW5zIGlzICt2ZSBhbmQgdGhlbiBzdWJ0cmFjdA0KdGhlIG51bWJlciBu
ZWVkZWQgZm9yIHRoZSBtZXNzYWdlIGl0c2VsZi4NCg0KSSB0aGluayB0aGlzIHdvdWxkIGNoYW5n
ZSB0aGUgc2VtYW50aWNzIG9mIHRoZSBjb25maWd1cmVkICdidXJzdCcgdmFsdWUNCnZlcnkgc2xp
Z2h0bHkgKHRvICdhdCBsZWFzdCcgZnJvbSAnYXQgbW9zdCcpIGJ1dCB0aGUgYXZlcmFnZSB3b3Vs
ZCBzdGlsbA0KYmUgY29ycmVjdC4NCg0KRldJVyBJJ3ZlIGRvbmUgc2ltaWxhciByYXRlIGxpbWl0
ZXJzIHRoYXQgcnVuIGRpcmVjdGx5IGluIHVuaXRzIG9mICd0aW1lJy4NClRoZSBmYWN0IHRoYXQg
c3lzdGVtIHRpbWUgYWR2YW5jZXMgYXV0b21hdGljYWxseSBnZW5lcmF0ZXMgY3JlZGl0Lg0KDQoJ
RGF2aWQNCg0KDQo=
