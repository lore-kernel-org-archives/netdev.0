From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by napi_disable
 inside local_bh_disable()d context
Date: Tue, 1 Oct 2013 20:08:12 +0000
Message-ID: <1380658092.22910.10.camel@jekeller-desk1.amr.corp.intel.com>
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
Received: from mga09.intel.com ([134.134.136.24]:58580 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab3JAUIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 16:08:13 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52ADFF9EE@SJEXCHMB10.corp.ad.broadcom.com>
Content-Language: en-US
Content-ID: <EEE82570D57A9D448C487CF9DE79D623@intel.com>
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
DQoNCkZZSSwgdGhlIG5ldyBwYXRjaCBpcyBjdXJyZW50bHkgZ29pbmcgdGhyb3VnaCBpbnRlcm5h
bCB2YWxpZGF0aW9uIGhlcmUsDQphbmQgb25jZSBKZWZmIEtpcnNoZXIgbWFpbHMgaXQsIEkgd2ls
bCBlbnN1cmUgdGhhdCB5b3UgYXJlIENjJ2VkIG9uIGl0Lg0KDQpSZWdhcmRzLA0KSmFrZQ0K
