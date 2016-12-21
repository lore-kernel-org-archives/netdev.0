From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH][V2] qed: fix memory leak of a qed_spq_entry on error
 failure paths
Date: Wed, 21 Dec 2016 13:29:56 +0000
Message-ID: <BL2PR07MB230615AAE3CF67DEBC6083778D930@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161220114424.11244-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>
To: Colin King <colin.king@canonical.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0072.outbound.protection.outlook.com ([104.47.38.72]:21028
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751294AbcLUPDG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Dec 2016 10:03:06 -0500
In-Reply-To: <20161220114424.11244-1-colin.king@canonical.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBDb2xpbiBJYW4gS2luZyA8Y29saW4ua2luZ0BjYW5vbmljYWwuY29tPg0KPiANCj4g
QSBxZWRfc3BxX2VudHJ5IGVudHJ5IGlzIGFsbG9jYXRlZCBieSBxZWRfc3BfaW5pdF9yZXF1ZXN0
IGJ1dCBpcyBub3Qga2ZyZWUnZA0KPiBpZiBhbiBlcnJvciBvY2N1cnMsIGNhdXNpbmcgYSBtZW1v
cnkgbGVhay4gRml4IHRoaXMgYnkgcmV0dXJuaW5nIHRoZSBwcmV2aW91c2x5DQo+IGFsbG9jYXRl
ZCBzcHEgZW50cnkgYW5kIGFsc28gc2V0dGluZyAqcHBfZW50IHRvIE5VTEwgdG8gYmUgc2FmZS4N
Cj4gDQo+IFRoYW5rcyB0byBZdXZhbCBNaW50eiBmb3Igc3VnZ2VzdGlvbnMgb24gaG93IHRvIGlt
cHJvdmUgbXkgb3JpZ2luYWwgZml4Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQ29saW4gSWFuIEtp
bmcgPGNvbGluLmtpbmdAY2Fub25pY2FsLmNvbT4NCg0KV2UndmUgZ2l2ZW4gaXQgYSBtb3JlIHRo
b3JvdWdoIGxvb2ssIGFuZCBhcHBhcmVudGx5IHRoaXMgaXNuJ3QgdGhlIGNvcnJlY3QgZml4Lg0K
U28gSSdsbCBzdGFydCBieSBzYXlpbmcgc29ycnkgZm9yIG1ha2luZyB5b3Ugc2VuZCB0aGlzIFYy
IG5lZWRsZXNzbHkuDQoNCkl0IGJvaWxzIGRvd24gdG8gdGhlIGZhY3QgdGhlcmUgYXJlIHR3byBr
aW5kcyBvZiBTUFEgZW50cmllcyAtDQpUaG9zZSBvcmlnaW5hdGluZyBmcm9tIHRoZSAnZnJlZV9w
b29sJyBhbmQgdGhvc2UgZnJvbSB0aGUgJ3VubGltaXRlZF9wZW5kaW5nJy4NCk9ubHkgdGhvc2Ug
b3JpZ2luYXRpbmcgZnJvbSB0aGUgZnJlZV9wb29sIHNob3VsZCBiZSByZXR1cm5lZA0KdXNpbmcg
dGhlIHFlZF9zcHFfcmV0dXJuX2VudHJ5KCksIGFzIG9ubHkgdGhvc2UgYWN0dWFsbHkgcG9pbnQg
dG8gYSB2YWxpZA0KZG1hLW1hcHBlZCBtZW1vcnkgd2hlcmUgRlcgZXhwZWN0cyB0byBmaW5kIHRo
ZSBlbnRyaWVzOw0KUmV0dXJuaW5nIHRoZSBvdGhlciBraW5kIHdvdWxkIGxlYWQgdG8gYXNzZXJ0
aW9ucyBsYXRlciwNCmFzIGRyaXZlciB3b3VsZCBwb3N0IGEgcmFtcm9kIHRvIEZXIHdoaWNoIGFj
dHVhbGx5IHBvaW50cyB0byBhZGRyZXNzIDAuDQoNCkxvb2tpbmcgYXQgdGhlIGVycm9yIGZsb3dz
LCBpdCBzZWVtcyBwb3NzaWJsZSB0aGlzIGlzbid0IHRoZSBvbmx5IGZhdWx0eQ0KZXJyb3IgZmxv
dyBpbiB0aGUgU1BRLiBJIHN1Z2dlc3QgeW91J2QgZHJvcCB0aGlzIGFuZCB3ZSdsbCB0YWtlIGl0
IGZyb20NCmhlcmUgW2FsdGhvdWdoIGlmIHlvdSByZWFsbHkgaGF2ZSB0aGUgdXJnZSB0byBjb250
aW51ZSAtIHBsZWFzZSBkb10uDQoNClRoYW5rcywNCll1dmFsDQoNCg0K
