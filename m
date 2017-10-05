From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] ipv6: gso: fix payload length when gso_size is zero
Date: Thu, 5 Oct 2017 18:58:00 +0000
Message-ID: <1507229878.2098.56.camel@intel.com>
References: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexey.kodanev@oracle.com" <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4850 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751454AbdJES6C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 14:58:02 -0400
In-Reply-To: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
Content-Language: en-US
Content-ID: <B19ACD12557AAA4F9BB109E2CB5BA2C4@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE3LTEwLTA1IGF0IDIwOjA2ICswMzAwLCBBbGV4ZXkgS29kYW5ldiB3cm90ZToN
Cj4gV2hlbiBnc29fc2l6ZSByZXNldCB0byB6ZXJvIGZvciB0aGUgdGFpbCBzZWdtZW50IGluIHNr
Yl9zZWdtZW50KCksIGxhdGVyDQo+IGluIGlwdjZfZ3NvX3NlZ21lbnQoKSwgd2Ugd2lsbCBnZXQg
aW5jb3JyZWN0IHBheWxvYWRfbGVuIGZvciB0aGF0IHNlZ21lbnQuDQo+IGluZXRfZ3NvX3NlZ21l
bnQoKSBhbHJlYWR5IGhhcyBhIGNoZWNrIGZvciBnc29fc2l6ZSBiZWZvcmUgY2FsY3VsYXRpbmcN
Cj4gcGF5bG9hZCBzbyBmaXhpbmcgb25seSBJUHY2IHBhcnQuDQo+IA0KPiBUaGUgaXNzdWUgd2Fz
IGZvdW5kIHdpdGggTFRQIHZ4bGFuICYgZ3JlIHRlc3RzIG92ZXIgaXhnYmUgTklDLg0KPiANCj4g
Rml4ZXM6IDA3YjI2Yzk0NTRhMiAoImdzbzogU3VwcG9ydCBwYXJ0aWFsIHNwbGl0dGluZyBhdCB0
aGUgZnJhZ19saXN0IHBvaW50ZXIiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBBbGV4ZXkgS29kYW5ldiA8
YWxleGV5LmtvZGFuZXZAb3JhY2xlLmNvbT4NCj4gLS0tDQo+ICBuZXQvaXB2Ni9pcDZfb2ZmbG9h
ZC5jIHwgMiArLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9u
KC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvaXA2X29mZmxvYWQuYyBiL25ldC9pcHY2
L2lwNl9vZmZsb2FkLmMNCj4gaW5kZXggY2RiMzcyOC4uNGE4N2Y5NCAxMDA2NDQNCj4gLS0tIGEv
bmV0L2lwdjYvaXA2X29mZmxvYWQuYw0KPiArKysgYi9uZXQvaXB2Ni9pcDZfb2ZmbG9hZC5jDQo+
IEBAIC0xMDUsNyArMTA1LDcgQEAgc3RhdGljIHN0cnVjdCBza19idWZmICppcHY2X2dzb19zZWdt
ZW50KHN0cnVjdCBza19idWZmICpza2IsDQo+ICANCj4gIAlmb3IgKHNrYiA9IHNlZ3M7IHNrYjsg
c2tiID0gc2tiLT5uZXh0KSB7DQo+ICAJCWlwdjZoID0gKHN0cnVjdCBpcHY2aGRyICopKHNrYl9t
YWNfaGVhZGVyKHNrYikgKyBuaG9mZik7DQo+IC0JCWlmIChnc29fcGFydGlhbCkNCj4gKwkJaWYg
KGdzb19wYXJ0aWFsICYmIHNrYl9pc19nc28oc2tiKSkNCj4gIAkJCXBheWxvYWRfbGVuID0gc2ti
X3NoaW5mbyhza2IpLT5nc29fc2l6ZSArDQo+ICAJCQkJICAgICAgU0tCX0dTT19DQihza2IpLT5k
YXRhX29mZnNldCArDQo+ICAJCQkJICAgICAgc2tiLT5oZWFkIC0gKHVuc2lnbmVkIGNoYXIgKiko
aXB2NmggKyAxKTsNCg0KU28gbG9va2luZyBvdmVyIHRoaXMgY2hhbmdlIGl0IGxvb2tzIGdvb2Qg
dG8gbWUuIEknbSBqdXN0IHdvbmRlcmluZyBpZg0KeW91IGhhdmUgbG9va2VkIGF0IHRoZSBjb2Rl
IGluIF9fc2tiX3VkcF90dW5uZWxfc2VnbWVudCBvcg0KZ3JlX2dzb19zZWdtZW50PyBJdCBzZWVt
cyBsaWtlIGlmIHlvdSBuZWVkZWQgdGhpcyBjaGFuZ2UgaGVyZSB5b3UNCnNob3VsZCBuZWVkIHRv
IG1ha2Ugc2ltaWxhciBjaGFuZ2VzIHRvIHRob3NlIGZ1bmN0aW9ucyBhcyB3ZWxsLiBJJ20NCndv
bmRlcmluZyBpZiB3ZSBqdXN0IGFyZW4ndCBzZWVpbmcgaXNzdWVzIGR1ZSB0byB0aGUgc2VnbWVu
dHMgYWxyZWFkeQ0KYmVpbmcgTVNTIHNpemVkIGJlZm9yZSBiZWluZyBoYW5kZWQgdG8gdXMgZm9y
IHNlZ21lbnRhdGlvbi4NCg0KLSBBbGV4
