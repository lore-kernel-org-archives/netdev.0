From: Roman Kagan <rkagan@parallels.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Wed, 13 Jun 2012 15:12:17 +0400
Message-ID: <1339585937.17472.11.camel@rkaganb.sw.ru>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
	 <4FD11F49.5060805@gmail.com>
	 <20120607.144358.1732928576389957779.davem@davemloft.net>
	 <20120608021542.GA10112@kroah.com> <1339141042.7850.51.camel@rkaganb.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"tarbal@gmail.com" <tarbal@gmail.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"dnelson@redhat.com" <dnelson@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.or
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:49155 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783Ab2FMLM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 07:12:29 -0400
In-Reply-To: <1339141042.7850.51.camel@rkaganb.sw.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDEyLTA2LTA4IGF0IDExOjM3ICswNDAwLCBSb21hbiBLYWdhbiB3cm90ZToNCj4g
T24gRnJpLCAyMDEyLTA2LTA4IGF0IDA2OjE1ICswNDAwLCBHcmVnIEtIIHdyb3RlOg0KPiA+IE9u
IFRodSwgSnVuIDA3LCAyMDEyIGF0IDAyOjQzOjU4UE0gLTA3MDAsIERhdmlkIE1pbGxlciB3cm90
ZToNCj4gPiA+IEZyb206IEplZmYgS2lyc2hlciA8dGFyYmFsQGdtYWlsLmNvbT4NCj4gPiA+IERh
dGU6IFRodSwgMDcgSnVuIDIwMTIgMTQ6Mzg6MTcgLTA3MDANCj4gPiA+IA0KPiA+ID4gPiBUaGFu
a3MhIEkgaGF2ZSBhcHBsaWVkIHRoZSBwYXRjaCB0byBteSBxdWV1ZQ0KPiA+ID4gDQo+ID4gPiBX
aHk/DQo+ID4gPiANCj4gPiA+IE15IGltcHJlc3Npb24gaXMgdGhhdCB0aGlzIGlzIGEgcGF0Y2gg
YWxyZWFkeSBpbiB0aGUgdHJlZSwgYW5kIGl0J3MNCj4gPiA+IGJlaW5nIHN1Ym1pdHRlZCBmb3Ig
LXN0YWJsZSBidXQgc3VjaCBtaW5vciBwZXJmb3JtYW5jZSBoYWNrcyBhcmUNCj4gPiA+IGFic29s
dXRlbHkgbm90IGFwcHJvcHJpYXRlIGZvciAtc3RhYmxlIHN1Ym1pc3Npb24uDQo+ID4gDQo+ID4g
VGhlIHBhdGNoIGRlc2NyaXB0aW9uIHNheXMgaXQgaXMgZml4aW5nIHJlcG9ydGVkIG9vcHNlcywN
Cj4gDQo+IEV4YWN0bHkuDQo+IA0KPiA+IGJ1dCB0aGUgU3ViamVjdDogaXNuJ3QgYWxsIHRoYXQg
aGVscGZ1bCB0aGVyZS4NCj4gDQo+IFdlbGwgSSBqdXN0IHByZXNlcnZlZCB0aGUgb3JpZ2luYWwg
c3ViamVjdCBmcm9tIHRoZSB1cHN0cmVhbSBjb21taXQuDQo+IFdhbnQgbWUgdG8gcmVzdWJtaXQg
d2l0aCBhIG1vcmUgYWxhcm1pbmcgb25lPw0KPiANCj4gPiBTbyB3aGljaCBpcyB0aGlzPyAgU2hv
dWxkIEkgYWNjZXB0IGl0IGZvciBhIHN0YWJsZSByZWxlYXNlIG9yIG5vdD8NCj4gDQo+IElNTyB5
ZXMgOykNCg0KV2hhdCBjYW1lIG91dCBvZiB0aGlzIGRpc2N1c3Npb24/ICBTaG91bGQgSSByZXN1
Ym1pdCB3aXRoIGEgZGlmZmVyZW50DQpzdWJqZWN0LCBvciB0aGUgb3JpZ2luYWwgb25lIGlzIGdv
b2QgZW5vdWdoPw0KDQpUaGUgcGF0Y2ggcmVzb2x2ZXMgYSByZWFsIG9vcHM7IHdlJ3ZlIHNlZW4g
aXQgbXVsdGlwbGUgdGltZXMgd2hlbg0KcnVubmluZyBVYnVudHUtMTEuMTAgaW4gdmlydHVhbCBt
YWNoaW5lcy4gIFVwc3RyZWFtIGFuZCBSSEVMIGhhdmUgdGhlDQpmaXggc2luY2UgbG9uZy4gIFVi
dW50dSBpcyB3YWl0aW5nIGZvciAzLjAtc3RhYmxlIHRvIG1lcmdlIGl0DQooaHR0cHM6Ly9idWdz
LmxhdW5jaHBhZC5uZXQvYnVncy8xMDA5NTQ1KS4NCg0KSSdkIGFwcHJlY2lhdGUgYW55IHN1Z2dl
c3Rpb24gb24gaG93IHRvIHByb2NlZWQuDQoNClRoYW5rcywNClJvbWFuLg0K
