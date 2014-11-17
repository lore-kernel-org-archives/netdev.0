From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 16:04:18 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34648 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbaKQQEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 11:04:32 -0500
In-Reply-To: <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBTYXR1cmRheSwgTm92ZW1iZXIgMTUs
IDIwMTQgMTA6MjIgQU0NCj4gDQo+IE9uIEZyaSwgMjAxNC0xMS0xNCBhdCAyMjowOCAtMDgwMCwg
SmVmZiBLaXJzaGVyIHdyb3RlOg0KPiA+IEZyb206IFNlcmV5IEtvbmcgPHNlcmV5LmtvbmdAaW50
ZWwuY29tPg0KPiA+DQo+ID4gVGhpcyBoYW5kbGVzIHRoZSBjYXNlIHdoZXJlIGEgc2luZ2xlIHBh
Y2tldCB3aXRoIG1vcmUgdGhhbiA4IGRhdGENCj4gPiBkZXNjcmlwdG9ycyB0cmlnZ2VycyBhIE1h
bGljaW91cyBEcml2ZXIgRGV0ZWN0IGV2ZW50IGluIHRoZSBkZXZpY2UuDQo+ID4NCg0KWy4uLl0N
Cg0KPiA+IC0JaWYgKHR4X2ZsYWdzICYgKEk0MEVfVFhfRkxBR1NfVFNPIHwgSTQwRV9UWF9GTEFH
U19GU08pKQ0KPiA+ICsJaWYgKHR4X2ZsYWdzICYgKEk0MEVfVFhfRkxBR1NfVFNPIHwgSTQwRV9U
WF9GTEFHU19GU08pKSB7DQo+ID4gIAkJZ3NvX3NlZ3MgPSBza2Jfc2hpbmZvKHNrYiktPmdzb19z
ZWdzOw0KPiA+IC0JZWxzZQ0KPiA+ICsJfSBlbHNlIHsNCj4gPiAgCQlnc29fc2VncyA9IDE7DQo+
ID4gKwkJaWYgKHNrYl9zaGluZm8oc2tiKS0+bnJfZnJhZ3MgPj0gSTQwRV9NQVhfQlVGRkVSX1RY
RCkNCj4gPiArCQkJc2tiX2xpbmVhcml6ZShza2IpOw0KPiANCj4gV2hhdCBleGFjdGx5IGhhcHBl
bnMgaWYgc2tiX2xpbmVhcml6ZSgpIGZhaWxzID8NCj4gDQo+IElzIHRoaXMgIk1hbGljaW91cyBE
cml2ZXIgRGV0ZWN0IGV2ZW50IiBmYXRhbCBvciBzaW1wbHkgcGFja2V0IGlzDQo+IGRyb3BwZWQg
d2l0aG91dCBhZGRpdGlvbmFsIGhhcm0gPw0KDQpUaGlzIHR5cGljYWxseSBoaXRzIHdoZW4gdGhl
cmUgYXJlIG1hbnkgbGl0dGxlIFRTTyBwYWNrZXRzIGluIGEgc2luZ2xlIE1UVSBzaXplIGZyYW1l
LiAgVGhlIGhhcmR3YXJlIGRvZXNuJ3QgbGlrZSBkZWFsaW5nIHdpdGggbW9yZSB0aGFuIDggc2Vw
YXJhdGUgYnVmZmVycy4NCg0KSWYgc2tiX2xpbmVhcml6ZSgpIGZhaWxzIGFuZCB3ZSB0cnkgdG8g
c2VuZCB0aGUgc2tiIGFzIGlzLCB0aGUgaGFyZHdhcmUgd2lsbCB0aHJvdyBhbiBNREQgZXZlbnQg
YW5kIGRpc2FibGUgdGhhdCBwYXJ0aWN1bGFyIHF1ZXVlLCBwb3NzaWJseSBjYXVzaW5nIGEgVHgg
aGFuZywgd2hpY2ggd2lsbCBsZWFkIHRvIGEgUEYgcmVzZXQgYW5kIHRoZW4gd2UgY29udGludWUg
b24uICBJdCdzIGEgYml0IG9mIGEgaGl0IHRvIHRocm91Z2hwdXQsIGFuZCBtb3N0IGZvbGtzIGdl
dCBhIGxpdHRsZSBhbm5veWVkIHdoZW4gc2VlaW5nIHRoZSBUeCBoYW5nIHN0YWNrIHRyYWNlIGlu
IHRoZWlyIGxvZywgYnV0IGl0IGdlbmVyYWxseSBpc24ndCBmYXRhbC4NCg0KSWYgd2UgZGlzYWJs
ZSB0aGUgTUREIGRldGVjdGlvbiwgdGhlIGhhcmR3YXJlIGVuZHMgdXAgcHV0dGluZyBnYXJiYWdl
IG9uIHRoZSB3aXJlLg0KDQpJdCBsb29rcyB0byBtZSB0aGF0IHRoZSB3YXkgZm9yIHNrYl9saW5l
YXJpemUoKSB0byBmYWlsIGlzIHdpdGggLUVOT01FTSwgaW4gd2hpY2ggY2FzZSB3ZSBwcm9iYWJs
eSBoYXZlIG90aGVyIGlzc3Vlcy4NCg0KSWYgdGhlcmUgYXJlIHNvbWUgYWx0ZXJuYXRpdmUgc3Vn
Z2VzdGlvbnMgZm9yIGRlYWxpbmcgd2l0aCB0aGlzLCB3ZSdkIGJlIGhhcHB5IHRvIGhlYXIgYWJv
dXQgdGhlbS4NCg0KQ2hlZXJzLA0Kc2xuDQoNCg==
