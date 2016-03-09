From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [net PATCH 1/2] e1000: Do not overestimate descriptor counts in
 Tx pre-check
Date: Wed, 9 Mar 2016 23:50:20 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EABCD0@ORSMSX101.amr.corp.intel.com>
References: <20160302205129.2124.67042.stgit@localhost.localdomain>
 <20160302211601.2124.64160.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11285 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934545AbcCIXuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 18:50:22 -0500
In-Reply-To: <20160302211601.2124.64160.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBv
d25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBBbGV4YW5kZXIgRHV5Y2sNCj4gU2Vu
dDogV2VkbmVzZGF5LCBNYXJjaCAyLCAyMDE2IDE6MTYgUE0NCj4gVG86IG5ldGRldkB2Z2VyLmtl
cm5lbC5vcmc7IGpvZ3JlZW5lQHJlZGhhdC5jb207IGludGVsLXdpcmVkLQ0KPiBsYW5AbGlzdHMu
b3N1b3NsLm9yZzsgS2lyc2hlciwgSmVmZnJleSBUIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5j
b20+Ow0KPiBzYXNzbWFubkByZWRoYXQuY29tDQo+IFN1YmplY3Q6IFtuZXQgUEFUQ0ggMS8yXSBl
MTAwMDogRG8gbm90IG92ZXJlc3RpbWF0ZSBkZXNjcmlwdG9yIGNvdW50cyBpbiBUeA0KPiBwcmUt
Y2hlY2sNCj4gDQo+IFRoZSBjdXJyZW50IGNvZGUgcGF0aCBpcyBjYXBhYmxlIG9mIGdyb3NzbHkg
b3ZlcmVzdGltYXRpbmcgdGhlIG51bWJlciBvZg0KPiBkZXNjcmlwdG9ycyBuZWVkZWQgdG8gdHJh
bnNtaXQgYSBuZXcgZnJhbWUuICBUaGlzIHNwZWNpZmljYWxseSBvY2N1cnMgaWYNCj4gdGhlIHNr
YiBjb250YWlucyBhIG51bWJlciBvZiA0SyBwYWdlcy4gIFRoZSBpc3N1ZSBpcyB0aGF0IHRoZSBs
b2dpYyBmb3INCj4gZGV0ZXJtaW5pbmcgdGhlIGRlc2NyaXB0b3JzIG5lZWRlZCBpcyAoKFMpID4+
IChYKSkgKyAxLiAgV2hlbiBYIGlzIDEyIGl0DQo+IG1lYW5zIHRoYXQgd2Ugd2VyZSBpbmRpY2F0
aW5nIHRoYXQgd2UgcmVxdWlyZWQgMiBkZXNjcmlwdG9ycyBmb3IgZWFjaCA0Sw0KPiBwYWdlIHdo
ZW4gd2Ugb25seSBuZWVkZWQgb25lLg0KPiANCj4gVGhpcyBjaGFuZ2UgY29ycmVjdHMgdGhpcyBi
eSBpbnN0ZWFkIGFkZGluZyAoMSA8PCAoWCkpIC0gMSB0byB0aGUgUyB2YWx1ZQ0KPiBpbnN0ZWFk
IG9mIGFkZGluZyAxIGFmdGVyIHRoZSBmYWN0LiAgVGhpcyB3YXkgd2UgZ2V0IGFuIGFjY3VyYXRl
IGRlc2NyaXB0b3INCj4gbmVlZGVkIGNvdW50IGFzIHdlIGFyZSBlc3NlbnRpYWxseSBkb2luZyBh
IERJVl9ST1VORFVQKCkuDQo+IA0KPiBSZXBvcnRlZC1ieTogSXZhbiBTdXpkYWwgPGlzdXpkYWxA
bWlyYW50aXMuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBBbGV4YW5kZXIgRHV5Y2sgPGFkdXlja0Bt
aXJhbnRpcy5jb20+DQo+IC0tLQ0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDAv
ZTEwMDBfbWFpbi5jIHwgICAgMiArLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCsp
LCAxIGRlbGV0aW9uKC0pDQoNClRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFhcm9uLmYuYnJvd25A
aW50ZWwuY29tPg0K
