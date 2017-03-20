From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH] net: convert sk_filter.refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 09:31:56 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C5B19A@IRSMSX102.ger.corp.intel.com>
References: <1489841889-27601-1-git-send-email-elena.reshetova@intel.com>
 <a19263a2-141b-22ad-4300-0ffe54cae8d6@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "ast@fb.com" <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a19263a2-141b-22ad-4300-0ffe54cae8d6@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBIZWxsbyENCj4gDQo+IE9uIDMvMTgvMjAxNyAzOjU4IFBNLCBFbGVuYSBSZXNoZXRvdmEgd3Jv
dGU6DQo+IA0KPiA+IHJlZmNvdW50X3QgdHlwZSBhbmQgY29ycmVzcG9uZGluZyBBUEkgc2hvdWxk
IGJlDQo+ID4gdXNlZCBpbnN0ZWFkIG9mIGF0b21pY190IHdoZW4gdGhlIHZhcmlhYmxlIGlzIHVz
ZWQgYXMNCj4gPiBhIHJlZmVyZW5jZSBjb3VudGVyLiBUaGlzIGFsbG93cyB0byBhdm9pZCBhY2Np
ZGVudGFsDQo+ID4gcmVmY291bnRlciBvdmVyZmxvd3MgdGhhdCBtaWdodCBsZWFkIHRvIHVzZS1h
ZnRlci1mcmVlDQo+ID4gc2l0dWF0aW9ucy4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEVsZW5h
IFJlc2hldG92YSA8ZWxlbmEucmVzaGV0b3ZhQGludGVsLmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5
OiBIYW5zIExpbGplc3RyYW5kIDxpc2hrYW1pZWxAZ21haWwuY29tPg0KPiA+IFNpZ25lZC1vZmYt
Ynk6IEtlZXMgQ29vayA8a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPg0KPiA+IFNpZ25lZC1vZmYtYnk6
IERhdmlkIFdpbmRzb3IgPGR3aW5kc29yQGdtYWlsLmNvbT4NCj4gWy4uLl0NCj4gPiBkaWZmIC0t
Z2l0IGEvbmV0L2NvcmUvZmlsdGVyLmMgYi9uZXQvY29yZS9maWx0ZXIuYw0KPiA+IGluZGV4IGVi
YWVhZjIuLjYyMjY3ZTIgMTAwNjQ0DQo+ID4gLS0tIGEvbmV0L2NvcmUvZmlsdGVyLmMNCj4gPiAr
KysgYi9uZXQvY29yZS9maWx0ZXIuYw0KPiBbLi4uXQ0KPiA+IEBAIC0xMTc5LDEyICsxMTc5LDEz
IEBAIHN0YXRpYyBpbnQgX19za19hdHRhY2hfcHJvZyhzdHJ1Y3QgYnBmX3Byb2cgKnByb2csDQo+
IHN0cnVjdCBzb2NrICpzaykNCj4gPiAgCQlyZXR1cm4gLUVOT01FTTsNCj4gPg0KPiA+ICAJZnAt
PnByb2cgPSBwcm9nOw0KPiA+IC0JYXRvbWljX3NldCgmZnAtPnJlZmNudCwgMCk7DQo+ID4gKwly
ZWZjb3VudF9zZXQoJmZwLT5yZWZjbnQsIDEpOw0KPiA+DQo+ID4gIAlpZiAoIXNrX2ZpbHRlcl9j
aGFyZ2Uoc2ssIGZwKSkgew0KPiA+ICAJCWtmcmVlKGZwKTsNCj4gPiAgCQlyZXR1cm4gLUVOT01F
TTsNCj4gPiAgCX0NCj4gPiArCXJlZmNvdW50X3NldCgmZnAtPnJlZmNudCwgMSk7DQo+IA0KPiAg
ICAgV2h5IGRvIGl0IHR3aWNlPw0KPiANCj4gWy4uLl0NCj4gDQo+IE1CUiwgU2VyZ2VpDQoNClNv
cnJ5IEkganVzdCByZWFsaXplZCB0aGF0IEkgaGFkIHVuc3F1YXNoZWQgY2hhbmdlcyB3aGVuIEkg
c2VudCB0aGlzIHBhdGNoLCBzbyB0aGlzIGlzIHN0aWxsIHRoZSBvbGQgdmVyc2lvbi4gDQpXaWxs
IHNlbmQgYSBuZXcgb25lIG5vdy4gDQoNCkJlc3QgUmVnYXJkcywNCkVsZW5hLg0KDQo=
