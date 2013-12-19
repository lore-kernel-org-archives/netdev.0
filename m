From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v2] xen-netback: add gso_segs calculation
Date: Thu, 19 Dec 2013 09:14:40 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01BBCC2@AMSPEX01CL01.citrite.net>
References: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
 <1387318507.19078.292.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David Miller (davem@davemloft.net)" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8954 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab3LSJOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 04:14:44 -0500
In-Reply-To: <1387318507.19078.292.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJl
aGFsZiBPZiBFcmljIER1bWF6ZXQNCj4gU2VudDogMTcgRGVjZW1iZXIgMjAxMyAyMjoxNQ0KPiBU
bzogUGF1bCBEdXJyYW50DQo+IENjOiB4ZW4tZGV2ZWxAbGlzdHMueGVuLm9yZzsgbmV0ZGV2QHZn
ZXIua2VybmVsLm9yZzsgV2VpIExpdTsgSWFuIENhbXBiZWxsOw0KPiBEYXZpZCBWcmFiZWwNCj4g
U3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dCB2Ml0geGVuLW5ldGJhY2s6IGFkZCBnc29fc2Vn
cyBjYWxjdWxhdGlvbg0KPiANCj4gT24gVHVlLCAyMDEzLTEyLTE3IGF0IDExOjQ0ICswMDAwLCBQ
YXVsIER1cnJhbnQgd3JvdGU6DQo+ID4gbmV0YmFjayBhbHJlYWR5IGhhcyBjb2RlIHdoaWNoIHBh
cnNlcyBJUHY0IGFuZCB2NiBoZWFkZXJzIHRvIHNldCB1cA0KPiBjaGVja3N1bQ0KPiA+IG9mZnNl
dHMgYW5kIHRoZXNlIGFyZSBhbHdheXMgYXBwbGllZCB0byBHU08gcGFja2V0cyBiZWluZyBzZW50
IGZyb20NCj4gPiBmcm9udGVuZHMuIEl0J3MgdGhlcmVmb3JlIHN1Ym9wdGltYWwgdGhhdCBHU09z
IGFyZSBiZWluZyBtYXJrZWQNCj4gPiBTS0JfR1NPX0RPREdZIHRvIGRlZmVyIHRoZSBnc29fc2Vn
cyBjYWxjdWxhdGlvbiB3aGVuIG5ldGJhY2sgYWxyZWFkeQ0KPiBoYXMgYWxsDQo+ID4gbmVjZXNz
YXJ5IGluZm9ybWF0aW9uIHRvIGhhbmQgdG8gZG8gdGhlIGNhbGN1bGF0aW9uLiBUaGlzIHBhdGNo
IGFkZHMgdGhhdA0KPiA+IGNhbGN1bGF0aW9uLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogUGF1
bCBEdXJyYW50IDxwYXVsLmR1cnJhbnRAY2l0cml4LmNvbT4NCj4gPiBDYzogV2VpIExpdSA8d2Vp
LmxpdTJAY2l0cml4LmNvbT4NCj4gPiBDYzogSWFuIENhbXBiZWxsIDxpYW4uY2FtcGJlbGxAY2l0
cml4LmNvbT4NCj4gPiBDYzogRGF2aWQgVnJhYmVsIDxkYXZpZC52cmFiZWxAY2l0cml4LmNvbT4N
Cj4gPiBDYzogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KPiA+IC0tLQ0K
PiANCj4gQWNrZWQtYnk6IEVyaWMgRHVtYXpldCA8ZWR1bWF6ZXRAZ29vZ2xlLmNvbT4NCj4gDQoN
ClRoYW5rcyA6LSkNCg0KICBQYXVsDQoNCj4gDQo+IC0tDQo+IFRvIHVuc3Vic2NyaWJlIGZyb20g
dGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1bnN1YnNjcmliZSBuZXRkZXYiIGluDQo+IHRoZSBi
b2R5IG9mIGEgbWVzc2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnDQo+IE1vcmUgbWFq
b3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21vLWluZm8uaHRt
bA0K
