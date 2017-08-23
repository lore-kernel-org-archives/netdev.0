From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: [PATCH v2 net-next 1/3] ipv6: Prevent unexpected sk->sk_prot
 changes
Date: Wed, 23 Aug 2017 07:49:09 +0000
Message-ID: <AM4PR0501MB272370367F819BEB1EBF2D7DD4850@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <1502795320-22538-1-git-send-email-ilyal@mellanox.com>
         <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
         <1502798357.4936.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <DB6PR05MB31768343CE15F47F8CC12CD8B08D0@DB6PR05MB3176.eurprd05.prod.outlook.com>
 <1502808336.4936.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        "Aviad Yehezkel" <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0085.outbound.protection.outlook.com ([104.47.2.85]:9248
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753386AbdHWHtM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 03:49:12 -0400
In-Reply-To: <1502808336.4936.78.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBUdWVzZGF5LCBBdWd1c3QgMTUsIDIw
MTcgNTo0NiBQTQ0KPiBUbzogQm9yaXMgUGlzbWVubnkgPGJvcmlzcEBtZWxsYW5veC5jb20+DQo+
IENjOiBJbHlhIExlc29raGluIDxpbHlhbEBtZWxsYW5veC5jb20+OyBuZXRkZXZAdmdlci5rZXJu
ZWwub3JnOw0KPiBkYXZlbUBkYXZlbWxvZnQubmV0OyBkYXZlandhdHNvbkBmYi5jb207IEF2aWFk
IFllaGV6a2VsDQo+IDxhdmlhZHllQG1lbGxhbm94LmNvbT4NCj4gU3ViamVjdDogUmU6IFtQQVRD
SCB2MiBuZXQtbmV4dCAxLzNdIGlwdjY6IFByZXZlbnQgdW5leHBlY3RlZCBzay0+c2tfcHJvdA0K
PiBjaGFuZ2VzDQo+IA0KPiBJIGFtIGp1c3Qgc2F5aW5nIElQVjZfQUREUkZPUk0gaXMgYmVjb21p
bmcgc3BhZ2hldHRpIGNvZGUsIGFuZCBtYXliZQ0KPiB0aGlzIGlzIHRpbWUgdG8gbWFrZSBpdCBt
b2R1bGFyLiANCj4gDQoNCkhpIEVyaWMsDQpJIHVuZGVyc3RhbmQgeW91ciBjb25jZXJuLCBidXQg
SSB3b3VsZCBsaWtlIHRvIHBvc3Rwb25lIGltcGxlbWVudGluZyB0aGlzDQpmZWF0dXJlIHVudGls
IHRoZSB1bHAgaW5mcmFzdHJ1Y3R1cmUgc3RhYmlsaXplcy4NCkkgZG9uJ3QgZXZlbiBrbm93IGhv
dyBtYW55IHVzZXJzIHdhbnQgdG8gdXNlIElQVjZfQUREUkZPUk0gb24gc29ja2V0cyB3aXRoIHVs
cC4NCkkgdGhpbmsgdGhhdCBzaW1wbHkgcmV0dXJuaW5nIGFuIGVycm9yIGZvciB1bHAgc29ja2V0
cyBpbiB0aGUgbWVhbnRpbWUgaXMgYSByZWFzb25hYmxlIA0KY29tcHJvbWlzZS4NCg0Kd2hhdCBk
byB5b3UgdGhpbmsgYWJvdXQgdGhlIHBhdGNoIGJlbG93Pw0KDQpTdWJqZWN0OiBbUEFUQ0ggMS8x
XSBpcHY2OiBEaXNhYmxlIElQVjZfQUREUkZPUk0gb24gc29ja2V0cyB3aXRoIHVscCBhdHRhY2hl
ZA0KDQpUaGUgSVBWNl9BRERSRk9STSBzZXRzb2Nrb3B0IHdvcmtzIGJ5IG92ZXJyaWRpbmcgc2st
PnNrX3Byb3QuDQpUaGUgY3VycmVudCBLVExTIHVscCBhbHNvIG92ZXJyaWRlcyBzay0+c2tfcHJv
dC4NCkNvbnNlcXVlbnRseSwgdXNpbmcgSVBWNl9BRERSRk9STSB3aGVuIHRoZXJlIGlzIGEgdWxw
IGF0dGFjaGVkIGlzDQp1bnNhZmUgYW5kIHRoaXMgcGF0Y2ggZGlzYWJsZXMgaXQuDQoNCkZpeGVz
OiAzYzRkNzU1OTE1OWIgKCd0bHM6IGtlcm5lbCBUTFMgc3VwcG9ydCcpDQpTaWduZWQtb2ZmLWJ5
OiBJbHlhIExlc29raGluIDxpbHlhbEBtZWxsYW5veC5jb20+DQotLS0NCiBuZXQvaXB2Ni9pcHY2
X3NvY2tnbHVlLmMgfCA2ICsrKysrLQ0KIDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyks
IDEgZGVsZXRpb24oLSkNCg0KZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYyBi
L25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYw0KaW5kZXggMDJkNzk1Zi4uZDkzNTk0OCAxMDA2NDQN
Ci0tLSBhL25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYw0KKysrIGIvbmV0L2lwdjYvaXB2Nl9zb2Nr
Z2x1ZS5jDQpAQCAtMTg1LDggKzE4NSwxMiBAQCBzdGF0aWMgaW50IGRvX2lwdjZfc2V0c29ja29w
dChzdHJ1Y3Qgc29jayAqc2ssIGludCBsZXZlbCwgaW50IG9wdG5hbWUsDQogCQkJCQlyZXR2ID0g
LUVCVVNZOw0KIAkJCQkJYnJlYWs7DQogCQkJCX0NCi0JCQl9IGVsc2UgaWYgKHNrLT5za19wcm90
b2NvbCAhPSBJUFBST1RPX1RDUCkNCisJCQl9IGVsc2UgaWYgKHNrLT5za19wcm90b2NvbCA9PSBJ
UFBST1RPX1RDUCkgew0KKwkJCQlpZiAoaW5ldF9jc2soc2spLT5pY3NrX3VscF9vcHMpDQorCQkJ
CQlicmVhazsNCisJCQl9IGVsc2Ugew0KIAkJCQlicmVhazsNCisJCQl9DQogDQogCQkJaWYgKHNr
LT5za19zdGF0ZSAhPSBUQ1BfRVNUQUJMSVNIRUQpIHsNCiAJCQkJcmV0diA9IC1FTk9UQ09OTjsN
Cg0KDQpUaGFua3MsDQpJbHlhDQo=
