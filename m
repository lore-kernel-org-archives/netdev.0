From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Fri, 31 Mar 2017 15:03:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFC37E0@AcuExch.aculab.com>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
 <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:52373 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754099AbdCaPDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 11:03:36 -0400
In-Reply-To: <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDMxIE1hcmNoIDIwMTcgMTQ6MjUNCj4gT24gRnJp
LCAyMDE3LTAzLTMxIGF0IDExOjQ3ICswMjAwLCBQYW9sbyBBYmVuaSB3cm90ZToNCj4gPiBJbiB0
aGUgdWRwX3NvY2sgc3RydWN0LCB0aGUgJ2ZvcndhcmRfZGVmaWNpdCcgYW5kICdwY2ZsYWcnIGZp
ZWxkcw0KPiA+IHNoYXJlIHRoZSBzYW1lIGNhY2hlbGluZS4gV2hpbGUgdGhlIGZpcnN0IGlzIGRp
cnRpZWQgYnkNCj4gPiB1ZHBfcmVjdm1zZywgdGhlIGxhdHRlciBpcyByZWFkLCBwb3NzaWJseSBz
ZXZlcmFsIHRpbWVzLCBieSB0aGUNCj4gPiBib3R0b20gaGFsZiBwcm9jZXNzaW5nIHRvIGRpc2Ny
aW1pbmF0ZSBiZXR3ZWVuIHVkcCBhbmQgdWRwbGl0ZQ0KPiA+IHNvY2tldHMuDQo+ID4NCj4gPiBX
aXRoIHRoaXMgcGF0Y2gsIHNrLT5za19wcm90b2NvbCBpcyB1c2VkIHRvIGNoZWNrIGlzIHRoZSBz
b2NrZXQgaXMNCj4gPiByZWFsbHkgYW4gdWRwbGl0ZSBvbmUsIGF2b2lkaW5nIHNvbWUgY2FjaGUg
bWlzc2VzIHBlcg0KPiA+IHBhY2tldCBhbmQgaW1wcm92aW5nIHRoZSBwZXJmb3JtYW5jZSB1bmRl
ciB1ZHBfZmxvb2Qgd2l0aA0KPiA+IHNtYWxsIHBhY2tldCB1cCB0byAxMCUuDQouLi4NCj4gSSBh
bSBwcmV0dHkgc3VyZSB3ZSBhZ3JlZWQgaW4gdGhlIHBhc3QgdGhhdCBmb3J3YXJkX2RlZmljaXQg
d291bGQgbmVlZA0KPiB0byBiZSBwbGFjZWQgb24gYSBjYWNoZSBsaW5lIG9mIGl0cyBvd24uIFNv
bWVob3cgd2UgbWFuYWdlIHRvIG5vdA0KPiBpbXBsZW1lbnQgdGhpcyBwcm9wZXJseS4NCj4gDQo+
IFdoYXQgYWJvdXQgb3RoZXIgZmllbGRzIGxpa2UgZW5jYXBfcmN2LCBlbmNhcF9kZXN0cm95LCBn
cm9fcmVjZWl2ZSwNCj4gZ3JvX2NvbXBsZXRlLiBUaGV5IHJlYWxseSBzaG91bGQgaGF2ZSB0aGUg
c2FtZSBmYWxzZSBzaGFyaW5nIGlzc3VlLg0KPiANCj4gUHJvcGVyIGZpeCBpcyA6DQouLi4NCj4g
LQkvKiBUaGlzIGZpZWxkIGlzIGRpcnRpZWQgYnkgdWRwX3JlY3Ztc2coKSAqLw0KPiAtCWludAkJ
Zm9yd2FyZF9kZWZpY2l0Ow0KPiArCS8qIFRoaXMgZmllbGQgaXMgZGlydGllZCBieSB1ZHBfcmVj
dm1zZygpLg0KPiArCSAqIE1ha2Ugc3VyZSBpdCB3b250IHNoYXJlIGEgY2FjaGUgbGluZSB3aXRo
IHByaW9yIGZpZWxkcy4NCj4gKwkgKi8NCj4gKwlpbnQJCWZvcndhcmRfZGVmaWNpdCBfX19fY2Fj
aGVsaW5lX2FsaWduZWRfaW5fc21wOw0KDQpJcyB0aGF0IHJlYWxseSBzZW5zaWJsZSBvbiBzeXN0
ZW1zIHdpdGggbGFyZ2UgY2FjaGUgbGluZXM/DQoNCglEYXZpZA0KDQo=
