From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [net-next v2 02/19] i40e: simplify txd use count calculation
Date: Thu, 8 Dec 2016 01:09:35 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2A54B75@ORSMSX107.amr.corp.intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
         <20161207221918.57932-3-jeffrey.t.kirsher@intel.com>
         <1481156184.4930.77.camel@edumazet-glaptop3.roam.corp.google.com>
         <B1C1DF2ACD01FD4881736AA51731BAB2A54ADC@ORSMSX107.amr.corp.intel.com>
 <1481159012.4930.85.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16151 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752941AbcLHBJi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 20:09:38 -0500
In-Reply-To: <1481159012.4930.85.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBXZWRuZXNkYXksIERlY2VtYmVyIDcs
IDIwMTYgNTowNCBQTQ0KPiBUbzogRHV5Y2ssIEFsZXhhbmRlciBIIDxhbGV4YW5kZXIuaC5kdXlj
a0BpbnRlbC5jb20+DQo+IENjOiBLaXJzaGVyLCBKZWZmcmV5IFQgPGplZmZyZXkudC5raXJzaGVy
QGludGVsLmNvbT47IGRhdmVtQGRhdmVtbG9mdC5uZXQ7DQo+IFdpbGxpYW1zLCBNaXRjaCBBIDxt
aXRjaC5hLndpbGxpYW1zQGludGVsLmNvbT47IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7DQo+IG5o
b3JtYW5AcmVkaGF0LmNvbTsgc2Fzc21hbm5AcmVkaGF0LmNvbTsgam9ncmVlbmVAcmVkaGF0LmNv
bTsNCj4gZ3VydS5hbmJhbGFnYW5lQG9yYWNsZS5jb20NCj4gU3ViamVjdDogUmU6IFtuZXQtbmV4
dCB2MiAwMi8xOV0gaTQwZTogc2ltcGxpZnkgdHhkIHVzZSBjb3VudCBjYWxjdWxhdGlvbg0KPiAN
Cj4gT24gVGh1LCAyMDE2LTEyLTA4IGF0IDAwOjM1ICswMDAwLCBEdXljaywgQWxleGFuZGVyIEgg
d3JvdGU6DQo+IA0KPiA+IFdlbGwgdGhlcmUgZW5kcyB1cCBiZWluZyBhIGZldyBhc3BlY3RzIHRv
IGl0LiAgRmlyc3Qgd2UgZG9uJ3QgbmVlZCB0aGUNCj4gPiBwcmVjaXNpb24gb2YgYSBmdWxsIDY0
YiBpbnZlcnNlIG11bHRpcGxpY2F0aW9uLCB0aGF0IGlzIHdoeSB3ZSBjYW4gZ2V0DQo+ID4gYXdh
eSB3aXRoIG11bHRpcGxlIGJ5IDg1IGFuZCBzaGlmdC4gIFRoZSBhc3N1bXB0aW9uIGlzIHdlIHNo
b3VsZCBuZXZlcg0KPiA+IHNlZSBhIGJ1ZmZlciBsYXJnZXIgdGhhbiA2NEsgZm9yIGEgVFNPIGZy
YW1lLiAgVGhhdCBiZWluZyB0aGUgY2FzZSB3ZQ0KPiA+IGNhbiBkbyB0aGUgc2FtZSB0aGluZyB3
aXRob3V0IGhhdmluZyB0byB1c2UgYSA2NGIgdmFsdWUgd2hpY2ggaXNuJ3QgYW4NCj4gPiBvcHRp
b24gb24gMzJiIGFyY2hpdGVjdHVyZXMuDQo+ID4NCj4gPiBTbyBiYXNpY2FsbHkgd2hhdCBpdCBj
b21lcyBkb3duIHRvIGlzIGRlYWxpbmcgd2l0aCB0aGUgIm9wdGltaXplZCBmb3INCj4gPiBzaXpl
IiBrZXJuZWwgb3B0aW9uLCBhbmQgMzJiIGFyY2hpdGVjdHVyZXMgbm90IGJlaW5nIGFibGUgdG8g
ZG8gdGhpcy4NCj4gPiBBcmd1YWJseSBib3RoIGFyZSBjb3JuZXIgY2FzZXMgYnV0IGJldHRlciB0
byBkZWFsIHdpdGggdGhlbSB0aGFuIHRha2UNCj4gPiBhIHBlcmZvcm1hbmNlIGhpdCB3ZSBkb24n
dCBoYXZlIHRvLg0KPiANCj4gb2sgb2sgOykNCj4gDQo+IFRvbyBiYWQgdGhlIDY1NTM2IHZhbHVl
IGlzIGFjY2VwdGVkLCAoaXMgaXQgPykgb3RoZXJ3aXNlDQo+IA0KPiB1bnNpZ25lZCBpbnQgZm9v
KHVuc2lnbmVkIHNob3J0IHNpemUpDQo+IHsNCj4gCXJldHVybiBzaXplIC8gMHgzMDAwOw0KPiB9
DQo+IA0KPiAtPiBnZW5lcmF0ZXMgdGhlIHNhbWUga2luZCBvZiBpbnN0cnVjdGlvbnMsIHdpdGgg
bWF5YmUgYSBiZXR0ZXINCj4gcHJlY2lzaW9uLg0KPiANCj4gZm9vOg0KPiAJbW92endsCSVkaSwg
JWVheA0KPiAJaW11bGwJJDQzNjkxLCAlZWF4LCAlZWF4DQo+IAlzaHJsCSQyOSwgJWVheA0KPiAJ
cmV0DQoNCkkgaGF2ZW4ndCBldmVyIGxvb2tlZCBhbGwgdGhhdCBjbG9zZWx5LiAgSSdtIGFzc3Vt
aW5nIHRoZSBmcmFtZSBzaXplIGNhbiBwcm9iYWJseSBleGNlZWQgYnkgYXQgbGVhc3QgRVRIX0hM
RU4gLSAxIHNpbmNlIHRoZSBJUCBoZWFkZXIgbGVuZ3RoIGNhbiB0aGVvcmV0aWNhbGx5IHJlYWNo
IDY0SyAtIDEgYmVmb3JlIHdlIGFyZSBtYXhlZCBvdXQuDQoNCldlIGRvbid0IHJlYWxseSBuZWVk
IHRoZSBleHRyYSBwcmVjaXNpb24gYW55d2F5LiAgV2Ugd2lsbCBiZSBvZmYgYnkgMSBtb3N0IGxp
a2VseSBhbnl3YXkgaW4gbWFueSBjYXNlcyBzaW5jZSB0aGUgYWN0dWFsIGhhcmR3YXJlIGNhbiBo
YW5kbGUgdXAgdG8gMTZLIC0gMSBpbiBlaXRoZXIgdGhlIGZpcnN0IGFuZC9vciBsYXN0IGJ1ZmZl
ciBvZiBhbnkgc2VyaWVzIHNpbmNlIHRoZSBhY3R1YWwgbGltaXQgaXMgdGhlIDE0IGJpdHMgaW4g
dGhlIFR4IGRlc2NyaXB0b3IgZm9yIHJlcG9ydGluZyB0aGUgYnVmZmVyIGxlbmd0aCBhbmQgd2Ug
dHJ5IHRvIGtlZXAgdGhlIHNwbGl0IGJldHdlZW4gYnVmZmVycyA0SyBhbGlnbmVkLg0KDQotIEFs
ZXgNCg==
