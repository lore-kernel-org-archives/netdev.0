From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by napi_disable
 inside local_bh_disable()d context
Date: Tue, 1 Oct 2013 20:05:15 +0000
Message-ID: <1380657915.22910.7.camel@jekeller-desk1.amr.corp.intel.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
	 <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
	 <20130918230943.GB11989@electric-eye.fr.zoreil.com>
	 <02874ECE860811409154E81DA85FBB58565F1520@ORSMSX104.amr.corp.intel.com>
	 <20130919213254.GC31672@electric-eye.fr.zoreil.com>
	 <02874ECE860811409154E81DA85FBB58565F5E52@ORSMSX104.amr.corp.intel.com>
	 <979A8436335E3744ADCD3A9F2A2B68A52ADFF9EE@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24307 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881Ab3JAUFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 16:05:17 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52ADFF9EE@SJEXCHMB10.corp.ad.broadcom.com>
Content-Language: en-US
Content-ID: <A2A812E777790B429ACC7E50FF32BB99@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDEzLTEwLTAxIGF0IDEyOjExICswMDAwLCBZdXZhbCBNaW50eiB3cm90ZToNCj4g
PiA+ID4gSSBoYXZlIHRvIG1vdmUgdGhlIGxvY2FsX2JoX2Rpc2FibGUgaW4gb3JkZXIgdG8gcHV0
IG5hcGlfZGlzYWJsZQ0KPiA+ID4gb3V0c2lkZQ0KPiA+ID4gPiBvZiB0aGUgY2FsbCBzaW5jZSBu
YXBpX2Rpc2FibGUgY291bGQgc2xlZXAsIGNhdXNpbmcgYSBzY2hlZHVsaW5nIHdoaWxlDQo+ID4g
PiA+IGF0b21pYyBCVUcuDQo+ID4gPg0KPiA+ID4gSSBhbSBpbiB2aW9sZW50IGFncmVlbWVudCB3
aXRoIHRoaXMgcGFydC4NCj4gPiA+IC0tDQo+ID4gPiBVZWltb3INCj4gPiANCj4gPiBSZWdhcmRz
LA0KPiA+IEpha2UNCj4gPiAtLQ0KPiANCj4gSXQgc2VlbSBsaWtlIHdlJ3ZlIGhpdCB0aGUgc2Ft
ZSBpc3N1ZSB3aXRoIHRoZSBibngyeCBkcml2ZXIuDQo+IElzIHRoZXJlIGFueXRoaW5nIG5ldyBh
Ym91dCB0aGUgUkZDPw0KPiANCj4gVGhhbmtzLA0KPiBZdXZhbA0KPiANCj4gDQo+IA0KPiANCj4g
DQoNClRoZSBuYXBpX2Rpc2FibGUgY2FsbCBmb3IgbWlnaHRfc2xlZXAoKSBpcyB0aGUgc2FtZS4g
VGhlIHNvbHV0aW9uIGluIHRoZQ0KaXhnYmUgZHJpdmVyIGlzIGRpZmZlcmVudC4gSSBjb21wbGV0
ZWx5IHJlLXdyb3RlIHRoZSBzZWdtZW50IGFib3V0IGhvdw0KdG8gZGlzYWJsZSB0aGUgcV92ZWN0
b3IgYnkgYWRkaW5nIGEgbmV3IHN0YXRlLCByYXRoZXIgdGhhbiBhYnVzaW5nIHRoZQ0KUVZfTE9D
S0VEX05BUEkgc3RhdGUuIEluIGFkZGl0aW9uIEkgcmVmYWN0b3JlZCBpdCBzbyB0aGF0IHRoZQ0K
cXZfbG9ja19uYXBpIHVzZWQgc3Bpbl9sb2NrX2JoKCkgaW5zdGVhZCBvZiBwbGFpbiBzcGluX2xv
Y2soKSwgYW5kDQpjaGFuZ2VkIGl0IHNvIHRoYXQgd2UgZGlkbid0IG5lZWQgdGhlIGxvY2FsX2Jo
X2Rpc2FibGUoKSBjYWxsIGluDQppeGdiZV9uYXBpX2Rpc2FibGVfYWxsLg0KDQpUaGlzIGlzIGEg
bXVjaCBjbGVhbmVyIHNvbHV0aW9uIHRoYW4gd2hhdCBJIG9yaWdpbmFsbHkgcHJvcG9zZWQuDQoN
ClJlZ2FyZHMsDQpKYWtlDQo=
