From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [net PATCH 1/2] ipv4: Restore fib_trie_flush_external function
 and fix call ordering
Date: Tue, 15 Nov 2016 20:29:09 +0000
Message-ID: <1479241747.681.105.camel@intel.com>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
         <20161115104606.13711.37506.stgit@ahduyck-blue-test.jf.intel.com>
         <20161115195107.GB1783@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>
To: "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:42672 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751937AbcKOU3L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 15:29:11 -0500
In-Reply-To: <20161115195107.GB1783@nanopsycho.orion>
Content-Language: en-US
Content-ID: <135EE1363550D64880C1A458F6AAF430@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE2LTExLTE1IGF0IDIwOjUxICswMTAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBU
dWUsIE5vdiAxNSwgMjAxNiBhdCAxMTo0NjowNkFNIENFVCwgYWxleGFuZGVyLmguZHV5Y2tAaW50
ZWwuY29tIHdyb3RlOg0KPiA+IA0KPiA+IFRoZSBwYXRjaCB0aGF0IHJlbW92ZWQgdGhlIEZJQiBv
ZmZsb2FkIGluZnJhc3RydWN0dXJlIHdhcyBhIGJpdCB0b28NCj4gPiBhZ2dyZXNzaXZlIGFuZCBh
bHNvIHJlbW92ZWQgY29kZSBuZWVkZWQgdG8gY2xlYW4gdXAgdXMgc3BsaXR0aW5nIHRoZSB0YWJs
ZQ0KPiA+IGlmIGFkZGl0aW9uYWwgcnVsZXMgd2VyZSBhZGRlZC4gIFNwZWNpZmljYWxseSB0aGUg
ZnVuY3Rpb24NCj4gPiBmaWJfdHJpZV9mbHVzaF9leHRlcm5hbCB3YXMgY2FsbGVkIGF0IHRoZSBl
bmQgb2YgYSBuZXcgcnVsZSBiZWluZyBhZGRlZCB0bw0KPiA+IGZsdXNoIHRoZSBmb3JlaWduIHRy
aWUgZW50cmllcyBmcm9tIHRoZSBtYWluIHRyaWUuDQo+ID4gDQo+ID4gSSB1cGRhdGVkIHRoZSBj
b2RlIHNvIHRoYXQgd2Ugb25seSBjYWxsIGZpYl90cmllX2ZsdXNoX2V4dGVybmFsIG9uIHRoZSBt
YWluDQo+ID4gdGFibGUgc28gdGhhdCB3ZSBmbHVzaCB0aGUgZW50cmllcyBmb3IgbG9jYWwgZnJv
bSBtYWluLiAgVGhpcyB3YXkgd2UgZG9uJ3QNCj4gPiBjYWxsIGl0IGZvciBldmVyeSBydWxlIGNo
YW5nZSB3aGljaCBpcyB3aGF0IHdhcyBoYXBwZW5pbmcgcHJldmlvdXNseS4NCj4gDQo+IFdlbGws
IHRoZSBmdW5jdGlvbiB3YXMgaW50cm9kdWNlZCBieToNCj4gDQo+IGNvbW1pdCAxMDQ2MTZlNzRl
MGI0NjRkNDQ5ZmRkMmVlMmY1NDdkMmZhZDcxNjEwDQo+IEF1dGhvcjogU2NvdHQgRmVsZG1hbiA8
c2ZlbGRtYUBnbWFpbC5jb20+DQo+IERhdGU6ICAgVGh1IE1hciA1IDIxOjIxOjE2IDIwMTUgLTA4
MDANCj4gDQo+ICAgICBzd2l0Y2hkZXY6IGRvbid0IHN1cHBvcnQgY3VzdG9tIGlwIHJ1bGVzLCBm
b3Igbm93DQo+ICAgICANCj4gICAgIEtlZXAgc3dpdGNoZGV2IEZJQiBvZmZsb2FkIG1vZGVsIHNp
bXBsZSBmb3Igbm93IGFuZCBkb24ndCBhbGxvdyBjdXN0b20gaXANCj4gICAgIHJ1bGVzLg0KPiAN
Cj4gV2h5IHRoaXMgd2FzIG5vdCBuZWVkZWQgYmVmb3JlPyBXaGF0IGNoYW5nZWQgaW4gYmV0d2Vl
bjoNCj4gMTA0NjE2ZTc0ZTBiNDY0ZDQ0OWZkZDJlZTJmNTQ3ZDJmYWQ3MTYxMCAoInN3aXRjaGRl
djogZG9uJ3Qgc3VwcG9ydCBjdXN0b20gaXAgcnVsZXMsIGZvciBub3ciKQ0KPiBhbmQNCj4gMzQ3
ZTNiMjhjMWJhMiAoInN3aXRjaGRldjogcmVtb3ZlIEZJQiBvZmZsb2FkIGluZnJhc3RydWN0dXJl
IikNCg0KV2UgY29sbGFwc2VkIHRoZSB0d28gdGFibGVzIGludG8gb25lIGluIGNvbW1pdMKgMGRk
Y2Y0M2Q1ZDRhICgiaXB2NDogRklCDQpMb2NhbC9NQUlOIHRhYmxlIGNvbGxhcHNlIikgd2hpY2gg
d2FzIHN1Ym1pdHRlZCB0aGUgbmV4dCBkYXkuIMKgU2NvdHQNCmFuZCBJIHdlcmUgd29ya2luZyBv
biB0aGluZ3MgYXQgdGhlIHNhbWUgdGltZSBhbmQgdGhlDQpmaWJfdGFibGVfZmx1c2hfZXh0ZXJu
YWwgZnVuY3Rpb24gd2FzIHNvbWV0aGluZyB3ZSBoYWQgd29ya2VkIG91dCB0aGF0DQp3b3VsZCBh
bGxvdyBoaW0gdG8gdGFrZSBjYXJlIG9mIGhpcyB1c2UgY2FzZSBhbmQgbWUgdG8gdGFrZSBjYXJl
IG9mDQpjbGVhbmluZyB1cCB0aGUgdGFibGVzIGFmdGVyIHVubWVyZ2luZy4NCg0KLSBBbGV4DQo=
