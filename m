From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Wed, 8 Apr 2015 18:41:22 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBF0E8@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Tom Tucker" <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	infinipath <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Eli Cohen" <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Upinder Malhi" <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	"Nikolova, Tatyana E" <tatyana.e.nikolova@intel.
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428517786.2980.180.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBJJ20gY29uY2VybmVkIGFib3V0IHRoZSBwZXJmb3JtYW5jZSBpbXBsaWNhdGlvbnMgb2YgdGhp
cy4gIFRoZSBzaXplIG9mDQo+IHRoaXMgcGF0Y2hzZXQgYWxyZWFkeSBwb2ludHMgb3V0IGp1c3Qg
aG93IG1hbnkgcGxhY2VzIGluIHRoZSBjb2RlIHdlDQo+IGhhdmUgdG8gY2hlY2sgZm9yIHZhcmlv
dXMgYXNwZWN0cyBvZiB0aGUgZGV2aWNlIHRyYW5zcG9ydCBpbiBvcmRlciB0byBkbw0KPiB0aGUg
cmlnaHQgdGhpbmcuICBXaXRob3V0IGdvaW5nIHRocm91Z2ggdGhlIGVudGlyZSBsaXN0IHRvIHNl
ZSBob3cgbWFueQ0KPiBhcmUgb24gY3JpdGljYWwgaG90IHBhdGhzLCBJJ20gc3VyZSBzb21lIG9m
IHRoZW0gYXJlIG9uIGF0IGxlYXN0DQo+IHBhcnRpYWxseSBjcml0aWNhbCBob3QgcGF0aHMgKGxp
a2UgY3JlYXRpb24gb2YgbmV3IGNvbm5lY3Rpb25zKS4gIEkNCj4gd291bGQgcHJlZmVyIHRvIHNl
ZSB0aGlzIGNoYW5nZSBiZSBpbXBsZW1lbnRlZCB2aWEgYSBkZXZpY2UgYXR0cmlidXRlLA0KPiBu
b3QgYSBmdW5jdGlvbmFsIGNhbGwgcXVlcnkuICBUaGF0IGFkZHMgYSBuZWVkbGVzcyBmdW5jdGlv
biBjYWxsIGluDQo+IHRoZXNlIHBhdGhzLg0KDQpNeSBpbXByZXNzaW9uIG9mIHRoZXNlIGNoYW5n
ZXMgd2VyZSB0aGF0IHRoZXkgd291bGQgZXZlbnR1YWxseSBsZWFkIHRvIHRoZSBtZWNoYW5pc20g
dGhhdCB5b3Ugb3V0bGluZWQ6IA0KDQoNCj4gSSdtIGFsc28gY29uY2VybmVkIGFib3V0IHRoaXMu
ICBJIHdvdWxkIGxpa2UgdG8gc2VlIHRoaXMgZW51bQ0KPiBlc3NlbnRpYWxseSB0dXJuZWQgaW50
byBhIGJpdG1hcC4gIE9uZSB0aGF0IGlzIGNvbnN0cnVjdGVkIGluIHN1Y2ggYSB3YXkNCj4gdGhh
dCB3ZSBjYW4gYWx3YXlzIGdldCB0aGUgc3BlY2lmaWMgdGVzdCB3ZSBuZWVkIHdpdGggb25seSBv
bmUgY29tcGFyZQ0KPiBhZ2FpbnN0IHRoZSBvdmVyYWxsIHZhbHVlLiAgSW4gb3JkZXIgdG8gZG8g
c28sIHdlIG5lZWQgdG8gYnJlYWsgaXQgZG93bg0KPiBpbnRvIHRoZSBlc3NlbnRpYWwgZWxlbWVu
dHMgdGhhdCBhcmUgcGFydCBvZiBlYWNoIG9mIHRoZSB0cmFuc3BvcnRzLg0KPiBTbywgZm9yIGlu
c3RhbmNlLCB3ZSBjYW4gZGVmaW5lIHRoZSB0d28gbGluayBsYXllcnMgd2UgaGF2ZSBzbyBmYXIs
IHBsdXMNCj4gcmVzZXJ2ZSBvbmUgZm9yIE9QQSB3aGljaCB3ZSBrbm93IGlzIGNvbWluZzoNCj4g
DQo+IFJETUFfTElOS19MQVlFUl9JQiAgICAgICA9IDB4MDAwMDAwMDEsDQo+IFJETUFfTElOS19M
QVlFUl9FVEggICAgICA9IDB4MDAwMDAwMDIsDQo+IFJETUFfTElOS19MQVlFUl9PUEEgICAgICA9
IDB4MDAwMDAwMDQsDQo+IFJETUFfTElOS19MQVlFUl9NQVNLICAgICA9IDB4MDAwMDAwMGYsDQo+
IA0KPiBXZSBjYW4gdGhlbiBkZWZpbmUgdGhlIGN1cnJlbnRseSBrbm93biBoaWdoIGxldmVsIHRy
YW5zcG9ydCB0eXBlczoNCj4gDQo+IFJETUFfVFJBTlNQT1JUX0lCICAgICAgICA9IDB4MDAwMDAw
MTAsDQo+IFJETUFfVFJBTlNQT1JUX0lXQVJQICAgICA9IDB4MDAwMDAwMjAsDQo+IFJETUFfVFJB
TlNQT1JUX1VTTklDICAgICA9IDB4MDAwMDAwNDAsDQo+IFJETUFfVFJBTlNQT1JUX1VTTklDX1VE
UCA9IDB4MDAwMDAwODAsDQo+IFJETUFfVFJBTlNQT1JUX01BU0sgICAgICA9IDB4MDAwMDAwZjAs
DQo+IA0KPiBXZSBjb3VsZCB0aGVuIGRlZmluZSBiaXRzIGZvciB0aGUgSUIgbWFuYWdlbWVudCB0
eXBlczoNCj4gDQo+IFJETUFfTUdNVF9JQiAgICAgICAgICAgICA9IDB4MDAwMDAxMDAsDQo+IFJE
TUFfTUdNVF9PUEEgICAgICAgICAgICA9IDB4MDAwMDAyMDAsDQo+IFJETUFfTUdNVF9NQVNLICAg
ICAgICAgICA9IDB4MDAwMDBmMDAsDQo+IA0KPiBUaGVuIHdlIGhhdmUgc3BhY2UgdG8gZGVmaW5l
IHNwZWNpZmljIHF1aXJrczoNCj4gDQo+IFJETUFfU0VQQVJBVEVfUkVBRF9TR0UgICA9IDB4MDAw
MDEwMDAsDQo+IFJETUFfUVVJUktTX01BU0sgICAgICAgICA9IDB4ZmZmZmYwMDANCg0KSSB0b28g
d291bGQgbGlrZSB0byBzZWUgdGhpcyBhcyB0aGUgZW5kIHJlc3VsdCwgYnV0IEkgdGhpbmsgaXQn
cyBwb3NzaWJsZSB0byBzdGFnZSB0aGUgY2hhbmdlcyBieSBoYXZpbmcgdGhlIHN0YXRpYyBpbmxp
bmUgY2FsbHMgYmVpbmcgYWRkZWQgY29udmVydCB0byB1c2luZyB0aGVzZSBzb3J0IG9mIGF0dHJp
YnV0ZXMuDQoNCi0gU2Vhbg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
