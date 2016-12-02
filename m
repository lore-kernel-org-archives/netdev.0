From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net v2] igb: re-assign hw address pointer on reset after
 PCI error
Date: Fri, 2 Dec 2016 16:41:59 +0000
Message-ID: <1480696918.16244.2.camel@intel.com>
References: <1478803603-30306-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
         <58416F5C.20602@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Fujinaka, Todd" <todd.fujinaka@intel.com>
To: "gpiccoli@linux.vnet.ibm.com" <gpiccoli@linux.vnet.ibm.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17531 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752998AbcLBQmB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 11:42:01 -0500
In-Reply-To: <58416F5C.20602@linux.vnet.ibm.com>
Content-Language: en-US
Content-ID: <42EE1A582779DE47BA69D028FE34B0B0@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDE2LTEyLTAyIGF0IDEwOjU1IC0wMjAwLCBHdWlsaGVybWUgRy4gUGljY29saSB3
cm90ZToNCj4gT24gMTEvMTAvMjAxNiAwNDo0NiBQTSwgR3VpbGhlcm1lIEcuIFBpY2NvbGkgd3Jv
dGU6DQo+ID4gV2hlbmV2ZXIgdGhlIGlnYiBkcml2ZXIgZGV0ZWN0cyB0aGUgcmVzdWx0IG9mIGEg
cmVhZCBvcGVyYXRpb24NCj4gPiByZXR1cm5zDQo+ID4gYSB2YWx1ZSBjb21wb3NlZCBvbmx5IGJ5
IEYncyAobGlrZSAweEZGRkZGRkZGKSwgaXQgd2lsbCBkZXRhY2ggdGhlDQo+ID4gbmV0X2Rldmlj
ZSwgY2xlYXIgdGhlIGh3X2FkZHIgcG9pbnRlciBhbmQgd2FybiB0byB0aGUgdXNlciB0aGF0DQo+
ID4gYWRhcHRlcidzDQo+ID4gbGluayBpcyBsb3N0IC0gdGhvc2Ugc3RlcHMgaGFwcGVuIG9uIGln
Yl9yZDMyKCkuDQo+ID4gDQo+ID4gSW4gY2FzZSBhIFBDSSBlcnJvciBoYXBwZW5zIG9uIFBvd2Vy
IGFyY2hpdGVjdHVyZSwgdGhlcmUncyBhDQo+ID4gcmVjb3ZlcnkNCj4gPiBtZWNoYW5pc20gY2Fs
bGVkIEVFSCwgdGhhdCB3aWxsIHJlc2V0IHRoZSBQQ0kgc2xvdCBhbmQgY2FsbA0KPiA+IGRyaXZl
cidzDQo+ID4gaGFuZGxlcnMgdG8gcmVzZXQgdGhlIGFkYXB0ZXIgYW5kIG5ldHdvcmsgZnVuY3Rp
b25hbGl0eSBhcyB3ZWxsLg0KPiA+IA0KPiA+IFdlIG9ic2VydmVkIHRoYXQgb25jZSBod19hZGRy
IGlzIE5VTEwgYWZ0ZXIgdGhlIGVycm9yIGlzIGRldGVjdGVkDQo+ID4gb24NCj4gPiBpZ2JfcmQz
MigpLCBpdCdzIG5ldmVyIGFzc2lnbmVkIGJhY2ssIHNvIGluIHRoZSBwcm9jZXNzIG9mDQo+ID4g
cmVzZXR0aW5nDQo+ID4gdGhlIG5ldHdvcmsgZnVuY3Rpb25hbGl0eSB3ZSBnb3QgYSBOVUxMIHBv
aW50ZXIgZGVyZWZlcmVuY2UgaW4gYm90aA0KPiA+IGlnYl9jb25maWd1cmVfdHhfcmluZygpIGFu
ZCBpZ2JfY29uZmlndXJlX3J4X3JpbmcoKS4gSW4gb3JkZXIgdG8NCj4gPiBhdm9pZA0KPiA+IHN1
Y2ggYnVnLCB0aGlzIHBhdGNoIHJlLWFzc2lnbnMgdGhlIGh3X2FkZHIgdmFsdWUgaW4gdGhlIHNs
b3RfcmVzZXQNCj4gPiBoYW5kbGVyLg0KPiA+IA0KPiA+IFJlcG9ydGVkLWJ5OiBBbnRob255IEgu
IFRoYWkgPGFodGhhaUB1cy5pYm0uY29tPg0KPiA+IFJlcG9ydGVkLWJ5OiBIYXJzaGEgVGh5YWdh
cmFqYSA8aGF0aHlhZ2FAaW4uaWJtLmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBHdWlsaGVybWUg
Ry4gUGljY29saSA8Z3BpY2NvbGlAbGludXgudm5ldC5pYm0uY29tPg0KPiA+IC0tLQ0KPiA+IMKg
ZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9tYWluLmMgfCA1ICsrKysrDQo+ID4g
wqAxIGZpbGUgY2hhbmdlZCwgNSBpbnNlcnRpb25zKCspDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBh
L2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfbWFpbi5jDQo+ID4gYi9kcml2ZXJz
L25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYw0KPiA+IGluZGV4IGVkYzlhNmEuLjEz
NmVlOWUgMTAwNjQ0DQo+ID4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2ln
Yl9tYWluLmMNCj4gPiArKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21h
aW4uYw0KPiA+IEBAIC03ODc4LDYgKzc4NzgsMTEgQEAgc3RhdGljIHBjaV9lcnNfcmVzdWx0X3QN
Cj4gPiBpZ2JfaW9fc2xvdF9yZXNldChzdHJ1Y3QgcGNpX2RldiAqcGRldikNCj4gPiDCoAkJcGNp
X2VuYWJsZV93YWtlKHBkZXYsIFBDSV9EM2hvdCwgMCk7DQo+ID4gwqAJCXBjaV9lbmFibGVfd2Fr
ZShwZGV2LCBQQ0lfRDNjb2xkLCAwKTsNCj4gPiANCj4gPiArCQkvKiBJbiBjYXNlIG9mIFBDSSBl
cnJvciwgYWRhcHRlciBsb3NlIGl0cyBIVw0KPiA+IGFkZHJlc3MNCj4gPiArCQnCoCogc28gd2Ug
c2hvdWxkIHJlLWFzc2lnbiBpdCBoZXJlLg0KPiA+ICsJCcKgKi8NCj4gPiArCQlody0+aHdfYWRk
ciA9IGFkYXB0ZXItPmlvX2FkZHI7DQo+ID4gKw0KPiA+IMKgCQlpZ2JfcmVzZXQoYWRhcHRlcik7
DQo+ID4gwqAJCXdyMzIoRTEwMDBfV1VTLCB+MCk7DQo+ID4gwqAJCXJlc3VsdCA9IFBDSV9FUlNf
UkVTVUxUX1JFQ09WRVJFRDsNCj4gPiANCj4gDQo+IFBpbmc/DQo+IA0KPiBTb3JyeSB0byBhbm5v
eSwgYW55IG5ld3Mgb24gdGhpcz8NCj4gVGhhbmtzIGluIGFkdmFuY2UhDQo+IA0KPiBDaGVlcnMs
DQo+IA0KPiANCj4gR3VpbGhlcm1lDQo+IA0KDQpUaGlzIHNlZW1zIHJlYXNvbmFibGUuIEl0J3Mg
c2ltaWxhciB0byB3aGF0IGZtMTBrIGRyaXZlciBkb2VzIHVuZGVyDQp0aGlzIGNpcmN1bXN0YW5j
ZS4NCg0KVGhhbmtzLA0KSmFrZQ==
