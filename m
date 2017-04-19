From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 3/4] qed: Fix possible system hang in the
 dcbnl-getdcbx() path.
Date: Wed, 19 Apr 2017 14:14:36 +0000
Message-ID: <BL2PR07MB23064619E4B20EB954BF1B0E8D180@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
 <20170419101955.26444-4-sudarsana.kalluru@cavium.com>
 <1873138594.16006381.1492610196115.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lance Richardson <lrichard@redhat.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0079.outbound.protection.outlook.com ([104.47.36.79]:41312
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1762467AbdDSOOk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 10:14:40 -0400
In-Reply-To: <1873138594.16006381.1492610196115.JavaMail.zimbra@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IHFlZF9kY2JubF9nZXRfZGNieCgpIEFQSSB1c2VzIGttYWxsb2MgaW4gR0ZUX0tFUk5FTCBt
b2RlLiBUaGUgQVBJIGdldHMNCj4gPiBpbnZva2VkIGluIHRoZSBpbnRlcnJ1cHQgY29udGV4dCBi
eSBxZWRfZGNibmxfZ2V0ZGNieCBjYWxsYmFjay4gTmVlZA0KPiA+IHRvIGludm9rZSB0aGlzIGtt
YWxsb2MgaW4gYXRvbWljIG1vZGUuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBTdWRhcnNhbmEg
UmVkZHkgS2FsbHVydSA8U3VkYXJzYW5hLkthbGx1cnVAY2F2aXVtLmNvbT4NCj4gPiBTaWduZWQt
b2ZmLWJ5OiBZdXZhbCBNaW50eiA8WXV2YWwuTWludHpAY2F2aXVtLmNvbT4NCj4gPiAtLS0NCj4g
PiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvcWxvZ2ljL3FlZC9xZWRfZGNieC5jIHwgMiArLQ0KPiA+
ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gPg0KPiA+
IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9xbG9naWMvcWVkL3FlZF9kY2J4LmMN
Cj4gPiBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3Fsb2dpYy9xZWQvcWVkX2RjYnguYw0KPiA+IGlu
ZGV4IGZmMDU4YTMuLjhmMDc4M2EgMTAwNjQ0DQo+ID4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvcWxvZ2ljL3FlZC9xZWRfZGNieC5jDQo+ID4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQv
cWxvZ2ljL3FlZC9xZWRfZGNieC5jDQo+ID4gQEAgLTEyNjQsNyArMTI2NCw3IEBAIHN0YXRpYyBz
dHJ1Y3QgcWVkX2RjYnhfZ2V0DQo+ID4gKnFlZF9kY2JubF9nZXRfZGNieChzdHJ1Y3QgcWVkX2h3
Zm4gKmh3Zm4sICB7DQo+ID4gIAlzdHJ1Y3QgcWVkX2RjYnhfZ2V0ICpkY2J4X2luZm87DQo+ID4N
Cj4gPiAtCWRjYnhfaW5mbyA9IGt6YWxsb2Moc2l6ZW9mKCpkY2J4X2luZm8pLCBHRlBfS0VSTkVM
KTsNCj4gPiArCWRjYnhfaW5mbyA9IGttYWxsb2Moc2l6ZW9mKCpkY2J4X2luZm8pLCBHRlBfQVRP
TUlDKTsNCj4gDQo+IFlvdSBhcmUgY2hhbmdpbmcgYSBremFsbG9jIHRvIGttYWxsb2MsIHdhcyB0
aGF0IGludGVudGlvbmFsPw0KDQpOb3QgcmVhbGx5LiBBcHBhcmVudGx5IHRoZSBjb25mdXNpb24g
cmVzdWx0ZWQgZnJvbSB0aGUgZmFjdCB0aGF0DQppbW1lZGlhdGVseSBhZnRlciB0aGUgbmV4dCBj
b25kaXRpb24gd2UncmUgbWVtc2V0dGluZyBkY2J4X2luZm8NCnRvIHplcm8gW3NvIGN1cnJlbnQg
Y29kZSB6ZXJvcyB0aGUgbWVtb3J5IHR3aWNlXSwgd2hpY2ggYWxzbw0KbWVhbnMgdGhlcmUncyBu
byBmdW5jdGlvbmFsIHByb2JsZW0gd2l0aCB0aGlzIGNoYW5nZS4NCg0KRGF2ZSwgZG8geW91IHdh
bnQgdXMgdG8gcmUtc3BpbiB0aGlzIFtldmVuIHRob3VnaCBjaGFuZ2UgaXNuJ3QNCmZ1bmN0aW9u
YWxseSBicm9rZW5dPw0KTm90aWNlIHRoaXMgaXMgYSByZWN1cnJlbnQgcGF0dGVybiwgc28gaW4g
ZnV0dXJlIHdlJ2QgaGF2ZSB0byBzZW5kDQphIGNsZWFudXAgZm9yIHRoZXNlIGtpbmQgb2Ygc3R1
ZmYsIHJlZ2FyZGxlc3Mgb2Ygd2hldGhlciB3ZSByZS1zcGluDQpub3cgb3Igbm90Lg0KDQo+IA0K
PiA+ICAJaWYgKCFkY2J4X2luZm8pDQo+ID4gIAkJcmV0dXJuIE5VTEw7DQo+ID4NCj4gPiAtLQ0K
PiA+IDEuOC4zLjENCj4gPg0KPiA+DQo=
