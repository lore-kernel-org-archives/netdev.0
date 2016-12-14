From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 3/4] secure_seq: use siphash24 instead of
 md5_transform
Date: Wed, 14 Dec 2016 14:47:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023F7BD@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
 <1e502c6b-cda3-c46d-2535-fcfb58f443a9@stressinduktion.org>
 <CAHmME9o4NVi-MPeURio1Ga58rnW6JAGQdTg6scd+K3EZEf3RNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9o4NVi-MPeURio1Ga58rnW6JAGQdTg6scd+K3EZEf3RNA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSmFzb24gQS4gRG9uZW5mZWxkDQo+IFNlbnQ6IDE0IERlY2VtYmVyIDIwMTYgMTM6NDQN
Cj4gVG86IEhhbm5lcyBGcmVkZXJpYyBTb3dhDQo+ID4gX19wYWNrZWQgbm90IG9ubHkgcmVtb3Zl
cyBhbGwgcGFkZGluZyBvZiB0aGUgc3RydWN0IGJ1dCBhbHNvIGNoYW5nZXMgdGhlDQo+ID4gYWxp
Z25tZW50IGFzc3VtcHRpb25zIGZvciB0aGUgd2hvbGUgc3RydWN0IGl0c2VsZi4gVGhlIHJ1bGUs
IHRoZSBzdHJ1Y3QNCj4gPiBpcyBhbGlnbmVkIGJ5IGl0cyBtYXhpbXVtIGFsaWdubWVudCBvZiBh
IG1lbWJlciBpcyBubyBsb25nZXIgdHJ1ZS4gVGhhdA0KPiA+IHNhaWQsIHRoZSBjb2RlIGFjY2Vz
c2luZyB0aGlzIHN0cnVjdCB3aWxsIGNoYW5nZSAobm90IG9uIGFyY2hzIHRoYXQgY2FuDQo+ID4g
ZGVhbCBlZmZpY2llbnRseSB3aXRoIHVuYWxpZ25lZCBhY2Nlc3MsIGJ1dCBvbiBvdGhlcnMpLg0K
PiANCj4gVGhhdCdzIGludGVyZXN0aW5nLiBUaGVyZSBjdXJyZW50bHkgYXJlbid0IGFueSBhbGln
bm1lbnQgcmVxdWlyZW1lbnRzDQo+IGluIHNpcGhhc2ggYmVjYXVzZSB3ZSB1c2UgdGhlIHVuYWxp
Z25lZCBoZWxwZXIgZnVuY3Rpb25zLCBidXQgYXMgRGF2aWQNCj4gcG9pbnRlZCBvdXQgaW4gYW5v
dGhlciB0aHJlYWQsIG1heWJlIHRoYXQgdG9vIHNob3VsZCBjaGFuZ2UuIEluIHRoYXQNCj4gY2Fz
ZSwgd2UnZCBoYXZlIGFuIGFsaWduZWQtb25seSB2ZXJzaW9uIG9mIHRoZSBmdW5jdGlvbiB0aGF0
IHJlcXVpcmVzDQo+IDgtYnl0ZSBhbGlnbmVkIGlucHV0LiBQZXJoYXBzIHRoZSBiZXN0IHdheSB0
byBnbyBhYm91dCB0aGF0IHdvdWxkIGJlDQo+IHRvIGp1c3QgbWFyayB0aGUgc3RydWN0IGFzIF9f
cGFja2VkIF9fYWxpZ25lZCg4KS4gT3IsIEkgZ3Vlc3MsIHNpbmNlDQo+IDY0LWJpdCBhY2Nlc3Nl
cyBnZXRzIHNwbGl0IGludG8gdHdvIG9uIDMyLWJpdCwgdGhhdCdkIGJlIGJlc3QgZGVzY3JpZWQN
Cj4gYXMgX19wYWNrZWQgX19hbGlnbmVkKHNpemVvZihsb25nKSkuIFdvdWxkIHRoYXQgYmUgYW4g
YWNjZXB0YWJsZQ0KPiBzb2x1dGlvbj8NCg0KSnVzdCByZW1vdmUgdGhlIF9fcGFja2VkIGFuZCBl
bnN1cmUgdGhhdCB0aGUgc3RydWN0dXJlIGlzICduaWNlJy4NClRoaXMgaW5jbHVkZXMgZW5zdXJp
bmcgdGhlcmUgaXMgbm8gJ3RhaWwgcGFkZGluZycuDQpJbiBzb21lIGNhc2VzIHlvdSdsbCBuZWVk
IHRvIHB1dCB0aGUgcG9ydCBudW1iZXIgaW50byBhIDMyYml0IGZpZWxkLg0KDQpJJ2QgYWxzbyBy
ZXF1aXJlIHRoYXQgdGhlIGtleSBiZSBhbGlnbmVkLg0KSXQgcHJvYmFibHkgb3VnaHQgdG8gYmUg
YSBuYW1lZCBzdHJ1Y3R1cmUgdHlwZSB3aXRoIHR3byA2NGJpdCBtZW1iZXJzDQoob3Igd2l0aCBh
biBhcnJheSBtZW1iZXIgdGhhdCBoYXMgdHdvIGVsZW1lbnRzKS4NCg0KCURhdmlkDQoNCg==
