From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: implement rx_copybreak to improve rx
 performance
Date: Mon, 29 Sep 2014 12:43:38 +0000
Message-ID: <323020b0c5a44235a1707dd0619deba3@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1411976824-28824-1-git-send-email-b38611@freescale.com>
 <1411992739.30721.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.100.120] ([207.46.100.120]:23632 "EHLO
	na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753926AbaI2Mpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:45:41 -0400
In-Reply-To: <1411992739.30721.23.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPiBTZW50OiBNb25kYXks
IFNlcHRlbWJlciAyOSwgMjAxNCA4OjEyIFBNDQo+VG86IER1YW4gRnVnYW5nLUIzODYxMQ0KPkNj
OiBMaSBGcmFuay1CMjA1OTY7IGRhdmVtQGRhdmVtbG9mdC5uZXQ7IHJvbWlldUBmci56b3JlaWwu
Y29tOw0KPm5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHNoYXduLmd1b0BsaW5hcm8ub3JnOyBiaHV0
Y2hpbmdzQHNvbGFyZmxhcmUuY29tDQo+U3ViamVjdDogUmU6IFtQQVRDSCB2MiAxLzFdIG5ldDog
ZmVjOiBpbXBsZW1lbnQgcnhfY29weWJyZWFrIHRvIGltcHJvdmUgcngNCj5wZXJmb3JtYW5jZQ0K
Pg0KPk9uIE1vbiwgMjAxNC0wOS0yOSBhdCAxNTo0NyArMDgwMCwgRnVnYW5nIER1YW4gd3JvdGU6
DQo+PiAtIENvcHkgc2hvcnQgZnJhbWVzIGFuZCBrZWVwIHRoZSBidWZmZXJzIG1hcHBlZCwgcmUt
YWxsb2NhdGUgc2tiIGluc3RlYWQNCj5vZg0KPj4gICBtZW1vcnkgY29weSBmb3IgbG9uZyBmcmFt
ZXMuDQo+PiAtIEFkZCBzdXBwb3J0IGZvciBzZXR0aW5nL2dldHRpbmcgcnhfY29weWJyZWFrIHVz
aW5nIGdlbmVyaWMgZXRodG9vbA0KPj4gdHVuYWJsZQ0KPj4NCj4+IENoYW5nZXMgVjI6DQo+PiAq
IEltcGxlbWVudHMgcnhfY29weWJyZWFrDQo+DQo+Pg0KPj4gKyNkZWZpbmUgQ09QWUJSRUFLX0RF
RkFVTFQgMjU2DQo+PiArc3RhdGljIHVuc2lnbmVkIGludCBjb3B5YnJlYWsgX19yZWFkX21vc3Rs
eSA9IENPUFlCUkVBS19ERUZBVUxUOw0KPj4gK21vZHVsZV9wYXJhbShjb3B5YnJlYWssIHVpbnQs
IDA2NDQpOyBNT0RVTEVfUEFSTV9ERVNDKGNvcHlicmVhaywNCj4+ICsJCSAiTWF4aW11bSBwYWNr
ZXQgc2l6ZSB0aGF0IGlzIGNvcGllZCB0byBhIG5ldyBidWZmZXIgb24NCj5yZWNlaXZlIik7DQo+
PiArDQo+DQo+SXQgaXMgbm90IHRoZSByaWdodCB3YXkgdG8gaGFuZGxlIHRoaXMuDQo+DQo+T2xk
IGRyaXZlcnMgbWlnaHQgc3RpbGwgaGF2ZSBhIGxlZ2FjeSBtb2R1bGUgcGFyYW1ldGVyLg0KPg0K
Pk5ldyBpbXBsZW1lbnRhdGlvbnMgc2hvdWxkIHByb3ZpZGUgdGhlIG5ldyBldGh0b29sIHN1cHBv
cnQsIGFuZCBvbmx5IHRoaXMuDQo+Tm8gbmV3IG1vZHVsZSBwYXJhbWV0ZXIgaXMgYWNjZXB0ZWQu
DQo+DQo+Rm9yIGRldGFpbHMsIGNoZWNrIGZvbGxvd2luZyBjb21taXRzIDoNCj4NCj5kNGFkMzBi
MTgyMzA1ZWNmOTdmMTQ1YTVkNGQxZmQ5ZTcyOGM2ZDAxIGVuaWM6IEFkZCB0dW5hYmxlX29wcyBz
dXBwb3J0IGZvcg0KPnJ4X2NvcHlicmVhaw0KPg0KPmYwZGI5YjA3MzQxNTg0ODcwOWRkNTlhNjM5
NDk2OTg4MmY1MTdkYTkgZXRodG9vbDogQWRkIGdlbmVyaWMgb3B0aW9ucyBmb3INCj50dW5hYmxl
cw0KPg0KPg0KPk9yIGNoZWNrIHRoZSBjdXJyZW50IHRyZWUgOg0KPg0KPmdpdCBncmVwIC1uIHJ4
X2NvcHlicmVhayBkcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmljDQo+DQpUaGUgcGF0Y2gg
aW1wbGVtZW50IGV0aHRvb2wgaW50ZXJmYWNlLCBwbHMgcmVhZCB0aGUgcGF0Y2ggY29tcGxldGVs
eS4NCg0KVGhhbmtzLA0KQW5keQ0K
