From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 18:30:21 +0000
Message-ID: <1503426617.2434.5.camel@intel.com>
References: <20170821212506.1cb0d5d6@redhat.com>
         <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
         <599C7530.2010405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65376 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751753AbdHVSaY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 14:30:24 -0400
In-Reply-To: <599C7530.2010405@gmail.com>
Content-Language: en-US
Content-ID: <35592A9F08C1AB408F401453791BADC0@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE3LTA4LTIyIGF0IDExOjE3IC0wNzAwLCBKb2huIEZhc3RhYmVuZCB3cm90ZToN
Cj4gT24gMDgvMjIvMjAxNyAxMTowMiBBTSwgTWljaGFlbCBDaGFuIHdyb3RlOg0KPiA+IE9uIE1v
biwgQXVnIDIxLCAyMDE3IGF0IDEyOjI1IFBNLCBKZXNwZXIgRGFuZ2FhcmQgQnJvdWVyDQo+ID4g
PGJyb3VlckByZWRoYXQuY29tPiB3cm90ZToNCj4gPiA+IA0KPiA+ID4gSSdiZSBiZWVuIHBsYXlp
bmcgd2l0aCB0aGUgbGF0ZXN0IFhEUF9SRURJUkVDVCBmZWF0dXJlLCB0aGF0IHdhcw0KPiA+ID4g
YWNjZXB0ZWQgaW4gbmV0LW5leHQgKGZvciBpeGdiZSksIHNlZSBtZXJnZSBjb21taXRbMV0uDQo+
ID4gPiAgWzFdIGh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcvZGF2ZW0vbmV0LW5leHQvYy82MDkzZWMy
ZGMzMQ0KPiA+ID4gDQo+ID4gDQo+ID4gSnVzdCBjYXRjaGluZyBvbiBYRFBfUkVESVJFQ1QgYW5k
IEkgaGF2ZSBhIHZlcnkgYmFzaWMgcXVlc3Rpb24uICBUaGUNCj4gPiBpbmdyZXNzIGRldmljZSBw
YXNzZXMgdGhlIFhEUCBidWZmZXIgdG8gdGhlIGVncmVzcyBkZXZpY2UgZm9yIFhEUA0KPiA+IHJl
ZGlyZWN0IHRyYW5zbWlzc2lvbi4gIFdoZW4gdGhlIGVncmVzcyBkZXZpY2UgaGFzIHRyYW5zbWl0
dGVkIHRoZQ0KPiA+IHBhY2tldCwgaXMgaXQgc3VwcG9zZWQgdG8ganVzdCBmcmVlIHRoZSBidWZm
ZXI/ICBPciBpcyBpdCBzdXBwb3NlZCB0bw0KPiA+IGJlIHJlY3ljbGVkPw0KPiA+IA0KPiA+IElu
IFhEUF9UWCwgdGhlIGJ1ZmZlciBpcyByZWN5Y2xlZCBiYWNrIHRvIHRoZSByeCByaW5nLg0KPiA+
IA0KPiANCj4gV2l0aCBYRFBfUkVESVJFQ1Qgd2UgbXVzdCAianVzdCBmcmVlIHRoZSBidWZmZXIi
IGluIGl4Z2JlIHRoaXMgbWVhbnMNCj4gcGFnZV9mcmFnX2ZyZWUoKSBvbiB0aGUgZGF0YS4gVGhl
cmUgaXMgbm8gd2F5IHRvIGtub3cgd2hlcmUgdGhlIHhkcA0KPiBidWZmZXIgY2FtZSBmcm9tIGl0
IGNvdWxkIGJlIGEgZGlmZmVyZW50IE5JQyBmb3IgZXhhbXBsZS4NCj4gDQo+IEhvd2V2ZXIgd2l0
aCBob3cgaXhnYmUgaXMgY29kZWQgdXAgcmVjeWNsaW5nIHdpbGwgd29yayBhcyBsb25nIGFzDQo+
IHRoZSBtZW1vcnkgaXMgZnJlZSdkIGJlZm9yZSB0aGUgZHJpdmVyIHJpbmcgdHJpZXMgdG8gdXNl
IGl0IGFnYWluLiBJbg0KPiBub3JtYWwgdXNhZ2UgdGhpcyBzaG91bGQgYmUgdGhlIGNhc2UuIEFu
ZCBpZiB3ZSBhcmUgb3Zlci1ydW5uaW5nIGEgZGV2aWNlDQo+IGl0IGRvZXNuJ3QgcmVhbGx5IGh1
cnQgdG8gc2xvdyBkb3duIHRoZSBzZW5kZXIgYSBiaXQuDQo+IA0KPiBJIHRoaW5rIHRoaXMgaXMg
YSBwcmV0dHkgZ29vZCBtb2RlbCwgd2UgY291bGQgcHJvYmFibHkgcHJvdmlkZSBhIHNldA0KPiBv
ZiBBUElzIGZvciBkcml2ZXJzIHRvIHVzZSBzbyB0aGF0IHdlIGdldCBzb21lIGNvbnNpc3RlbmN5
IGFjcm9zcw0KPiB2ZW5kb3JzIGhlcmUsIGFsYSBKZXNwZXIncyBwYWdlIHBvb2wgaWRlYXMuDQo+
IA0KPiAoK0FsZXgsIGZvciBpeGdiZSBkZXRhaWxzKQ0KPiANCj4gVGhhbmtzLA0KPiBKb2huDQoN
CkkgdGhpbmsgeW91IHByZXR0eSBtdWNoIGNvdmVyZWQgdGhlIGlubmVyIHdvcmtpbmdzIGZvciB0
aGUgaXhnYmUgYml0cy4NCg0KVGhlIG9ubHkgcGllY2UgSSB3b3VsZCBhZGQgaXMgdGhhdCB0aGUg
cmVjeWNsaW5nIHRyaWNrIG5vcm1hbGx5IG9ubHkNCndvcmtzIGlmIHRoZSBzYW1lIGludGVyZmFj
ZS9kcml2ZXIgaXMgZG9pbmcgYm90aCB0aGUgVHggYW5kIHRoZSBSeC4gVGhlDQpyZWRpcmVjdCBj
b2RlIGNhbm5vdCBhc3N1bWUgdGhhdCBpcyB0aGUgY2FzZSBhbmQgdGhhdCBpcyB0aGUgcmVhc29u
IHdoeQ0KaXQgbXVzdCBhbHdheXMgYmUgZnJlZWluZyB0aGUgdHJhZmZpYyBvbiBjbGVhbi11cC4N
Cg0KLSBBbGV4
