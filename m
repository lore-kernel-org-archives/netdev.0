From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v2 02/17] IB/Verbs: Implement raw management helpers
Date: Tue, 7 Apr 2015 21:25:02 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE403@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CDA7.8090902@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	infinipath <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Trond Myklebust" <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	"Nikolova, Tatyana E" <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel@mellan
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CDA7.8090902-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiArc3RhdGljIGlubGluZSBpbnQgcmRtYV90cmFuc3BvcnRfaWIoc3RydWN0IGliX2RldmljZSAq
ZGV2aWNlLCB1OA0KPiBwb3J0X251bSkNCj4gK3sNCj4gKwlyZXR1cm4gZGV2aWNlLT5xdWVyeV90
cmFuc3BvcnQoZGV2aWNlLCBwb3J0X251bSkNCj4gKwkJCT09IFJETUFfVFJBTlNQT1JUX0lCOw0K
PiArfQ0KPiArDQo+ICtzdGF0aWMgaW5saW5lIGludCByZG1hX3RyYW5zcG9ydF9pYm9lKHN0cnVj
dCBpYl9kZXZpY2UgKmRldmljZSwgdTgNCj4gcG9ydF9udW0pDQo+ICt7DQo+ICsJcmV0dXJuIGRl
dmljZS0+cXVlcnlfdHJhbnNwb3J0KGRldmljZSwgcG9ydF9udW0pDQo+ICsJCQk9PSBSRE1BX1RS
QU5TUE9SVF9JQk9FOw0KPiArfQ0KDQpXZSBuZWVkIHRvIGRvIHNvbWV0aGluZyB3aXRoIHRoZSBm
dW5jdGlvbiBuYW1lcyB0byBtYWtlIHRoZWlyIHVzZSBtb3JlIG9idmlvdXMuICBCb3RoIElCIGFu
ZCBJQm9FIGhhdmUgdHJhbnNwb3J0IElCLiAgSSB0aGluayBKYXNvbiBzdWdnZXN0ZWQgcmRtYV90
ZWNoX2liIC8gcmRtYV90ZWNoX2lib2UuDQoNClJlZ2FyZGluZyB0cmFuc3BvcnQgdHlwZXMsIEkg
YmVsaWV2ZSB0aGF0IHVzbmljIHN1cHBvcnRzIDIgZGlmZmVyZW50IHRyYW5zcG9ydHMuICBBbHRo
b3VnaCB1c25pYyBpc24ndCB1c2VkIGJ5IGFueXRoaW5nIGVsc2UgaW4gdGhlIGNvcmUgbGF5ZXIs
IHdlIHNob3VsZCBwcm9iYWJseSBiZSBhYmxlIHRvIGhhbmRsZSBhIGRldmljZSB0aGF0IHN1cHBv
cnRzIG11bHRpcGxlIHByb3RvY29scy4gIEknbSBub3Qgc3VyZSB3aGF0IHRoZSAndHJhbnNwb3J0
JyBzaG91bGQgYmUgZm9yIGlXYXJwLCBzaW5jZSBpV2FycCBpcyBsYXllcmVkIG92ZXIgVENQLiAg
QnV0IHRoYXQgbWF5IGp1c3QgbWVhbiB0aGF0IHRoZSB0ZXJtIHRyYW5zcG9ydCBpc24ndCBncmVh
dC4NCg0KLSBTZWFuDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
