From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Wed, 22 May 2013 14:27:12 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com>
References: <519B38EC.90401@yandex-team.ru>  <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru>  <1369150693.3301.233.camel@edumazet-glaptop>  <519BB90B.6080706@yandex-team.ru>  <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <paulmck@linux.vnet.ibm.com>,
	"Dipankar Sarma" <dipankar@in.ibm.com>, <zhmurov@yandex-team.ru>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Roman Gushchin" <klamm@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44826 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753042Ab3EVN1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 09:27:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12632-05 for <netdev@vger.kernel.org>;
 Wed, 22 May 2013 14:27:32 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369225837.3301.324.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBTbyB5ZXMsIHRoZSBwYXRjaCBhcHBlYXJzIHRvIGZpeCB0aGUgYnVnLCBidXQgaXQgc291bmRz
IG5vdCBsb2dpY2FsIHRvDQo+IG1lLg0KDQpJIHdhcyBjb25mdXNlZCBiZWNhdXNlIHRoZSBjb3B5
IG9mIHRoZSBjb2RlIEkgZm91bmQgd2FzIGRpZmZlcmVudA0KKGl0IGhhcyBzb21lIGNoZWNrcyBm
b3IgcmV1c2FkZHIgLSB3aGljaCBmb3JjZSBhIGZ1bmN0aW9uIGNhbGwgaW4gdGhlDQpsb29wKS4N
Cg0KVGhlIGNvZGUgYmVpbmcgY29tcGlsZWQgaXM6DQoNCmJlZ2luOg0KCXJlc3VsdCA9IE5VTEw7
DQoJYmFkbmVzcyA9IC0xOw0KCXVkcF9wb3J0YWRkcl9mb3JfZWFjaF9lbnRyeV9yY3Uoc2ssIG5v
ZGUsICZoc2xvdDItPmhlYWQpIHsNCgkJc2NvcmUgPSBjb21wdXRlX3Njb3JlMihzaywgbmV0LCBz
YWRkciwgc3BvcnQsDQoJCQkJICAgICAgZGFkZHIsIGhudW0sIGRpZik7DQoJCWlmIChzY29yZSA+
IGJhZG5lc3MpIHsNCgkJCXJlc3VsdCA9IHNrOw0KCQkJYmFkbmVzcyA9IHNjb3JlOw0KCQkJaWYg
KHNjb3JlID09IFNDT1JFMl9NQVgpDQoJCQkJZ290byBleGFjdF9tYXRjaDsNCgkJfQ0KCX0NCgkv
Kg0KCSAqIGlmIHRoZSBudWxscyB2YWx1ZSB3ZSBnb3QgYXQgdGhlIGVuZCBvZiB0aGlzIGxvb2t1
cCBpcw0KCSAqIG5vdCB0aGUgZXhwZWN0ZWQgb25lLCB3ZSBtdXN0IHJlc3RhcnQgbG9va3VwLg0K
CSAqIFdlIHByb2JhYmx5IG1ldCBhbiBpdGVtIHRoYXQgd2FzIG1vdmVkIHRvIGFub3RoZXIgY2hh
aW4uDQoJICovDQoJaWYgKGdldF9udWxsc192YWx1ZShub2RlKSAhPSBzbG90MikNCgkJZ290byBi
ZWdpbjsNCg0KV2hpY2ggaXMgZW50aXJlbHkgaW5saW5lZCAtIHNvIHRoZSBjb21waWxlciBpcyBh
bGxvd2VkIHRvIGFzc3VtZQ0KdGhhdCBubyBvdGhlciBjb2RlIG1vZGlmaWVzIGFueSBvZiB0aGUg
ZGF0YS4NCkhlbmNlIGl0IGlzIGFsbG93ZWQgdG8gY2FjaGUgdGhlIGxpc3QgaGVhZCB2YWx1ZS4N
CkluZGVlZCBpdCBjb3VsZCBjb252ZXJ0IHRoZSBsYXN0IGxpbmUgdG8gImZvciAoOzspOyIuDQoN
CkEgYXNtIHZvbGF0aWxlICgiIjo6OiJtZW1vcnkiKSBzb21ld2hlcmUgd291bGQgZml4IGl0Lg0K
DQoJRGF2aWQNCg0K
