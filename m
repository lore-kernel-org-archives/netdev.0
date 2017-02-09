From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [patch net-next 1/7] ipv4: fib: Only flush FIB aliases
 belonging to currently flushed table
Date: Thu, 9 Feb 2017 19:00:51 +0000
Message-ID: <1486666849.7829.67.camel@intel.com>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
         <1486632524-5588-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "eladr@mellanox.com" <eladr@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        "kaber@trash.net" <kaber@trash.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24934 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754185AbdBITBE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 14:01:04 -0500
In-Reply-To: <1486632524-5588-2-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Content-ID: <66DF0DF53163004999F4E2BCE505D9F5@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE3LTAyLTA5IGF0IDEwOjI4ICswMTAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBG
cm9tOiBJZG8gU2NoaW1tZWwgPGlkb3NjaEBtZWxsYW5veC5jb20+DQo+IA0KPiBJbiBjYXNlIHRo
ZSBNQUlOIHRhYmxlIGlzIGZsdXNoZWQgYW5kIGl0cyB0cmllIGlzIHNoYXJlZCB3aXRoIHRoZSBM
T0NBTA0KPiB0YWJsZSwgdGhlbiB3ZSBtaWdodCBiZSBmbHVzaGluZyBGSUIgYWxpYXNlcyBiZWxv
bmdpbmcgdG8gdGhlIGxhdHRlci4NCj4gVGhpcyBjYW4gbGVhZCB0byBGSUJfRU5UUllfREVMIG5v
dGlmaWNhdGlvbnMgc2VudCB3aXRoIHRoZSB3cm9uZyB0YWJsZQ0KPiBJRC4NCj4gDQo+IFRoZSBh
Ym92ZSBkb2Vzbid0IGFmZmVjdCBjdXJyZW50IGxpc3RlbmVycywgYXMgdGhlIHRhYmxlIElEIGlz
IGlnbm9yZWQNCj4gZHVyaW5nIGVudHJ5IGRlbGV0aW9uLCBidXQgdGhpcyB3aWxsIGNoYW5nZSBs
YXRlciBpbiB0aGUgcGF0Y2hzZXQuDQo+IA0KPiBXaGVuIGZsdXNoaW5nIGEgcGFydGljdWxhciB0
YWJsZSwgc2tpcCBhbnkgYWxpYXNlcyBiZWxvbmdpbmcgdG8gYQ0KPiBkaWZmZXJlbnQgb25lLg0K
PiANCj4gU2lnbmVkLW9mZi1ieTogSWRvIFNjaGltbWVsIDxpZG9zY2hAbWVsbGFub3guY29tPg0K
PiBTaWduZWQtb2ZmLWJ5OiBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNvbT4NCj4gQ0M6IEFs
ZXhhbmRlciBEdXljayA8YWxleGFuZGVyLmguZHV5Y2tAaW50ZWwuY29tPg0KPiBDQzogUGF0cmlj
ayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+DQo+IC0tLQ0KPiAgbmV0L2lwdjQvZmliX3RyaWUu
YyB8IDMgKystDQo+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9u
KC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvZmliX3RyaWUuYyBiL25ldC9pcHY0L2Zp
Yl90cmllLmMNCj4gaW5kZXggMjkxOWQxYS4uNWVmNDU5NiAxMDA2NDQNCj4gLS0tIGEvbmV0L2lw
djQvZmliX3RyaWUuYw0KPiArKysgYi9uZXQvaXB2NC9maWJfdHJpZS5jDQo+IEBAIC0xOTYzLDcg
KzE5NjMsOCBAQCBpbnQgZmliX3RhYmxlX2ZsdXNoKHN0cnVjdCBuZXQgKm5ldCwgc3RydWN0IGZp
Yl90YWJsZSAqdGIpDQo+ICAJCWhsaXN0X2Zvcl9lYWNoX2VudHJ5X3NhZmUoZmEsIHRtcCwgJm4t
PmxlYWYsIGZhX2xpc3QpIHsNCj4gIAkJCXN0cnVjdCBmaWJfaW5mbyAqZmkgPSBmYS0+ZmFfaW5m
bzsNCj4gIA0KPiAtCQkJaWYgKCFmaSB8fCAhKGZpLT5maWJfZmxhZ3MgJiBSVE5IX0ZfREVBRCkp
IHsNCj4gKwkJCWlmICghZmkgfHwgIShmaS0+ZmliX2ZsYWdzICYgUlROSF9GX0RFQUQpIHx8DQo+
ICsJCQkgICAgdGItPnRiX2lkICE9IGZhLT50Yl9pZCkgew0KPiAgCQkJCXNsZW4gPSBmYS0+ZmFf
c2xlbjsNCj4gIAkJCQljb250aW51ZTsNCj4gIAkJCX0NCg0KT25lIGNoYW5nZSBJIG1pZ2h0IG1h
a2UgaWYgeW91IGVuZCB1cCBoYXZpbmcgdG8gZG8gYSB2MiB3b3VsZCBiZSB0bw0KdGVzdCBmb3Ig
dGhlIHRhYmxlIElEIGZpcnN0LiDCoEl0IGNhbiBlbmQgdXAgc2F2aW5nIGEgZmV3IGN5Y2xlcyBp
biB0aGUNCndob2xlIGZsdXNoaW5nIHByb2Nlc3Mgc2luY2UgdGhlIHRhYmxlIElEIGlzIGluIHRo
ZSBmaWIgYWxpYXMgaW5zdGVhZA0Kb2YgaGF2aW5nIHRvIGRlcmVmZXJlbmNlIHRoZSBmaWIgaW5m
by4NCg0KVGhhdCBiZWluZyBzYWlkLCBJIGFtIGp1c3QgYmVpbmcgYSBiaXQgbml0LXBpY2t5IHNv
IHRoZSBjb2RlIGl0c2VsZiBpcw0KZnVuY3Rpb25hbGx5IGNvcnJlY3QgYW5kIHRoZXJlIGlzIG5v
dGhpbmcgaGVyZSB0aGF0IHNob3VsZCBjYXVzZSBhbnkNCmlzc3Vlcy4NCg0KUmV2aWV3ZWQtYnk6
IEFsZXhhbmRlciBEdXljayA8YWxleGFuZGVyLmguZHV5Y2tAaW50ZWwuY29tPg==
