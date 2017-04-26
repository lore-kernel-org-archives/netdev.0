From: Vlad Zakharov <Vladislav.Zakharov@synopsys.com>
Subject: Re: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Wed, 26 Apr 2017 12:56:21 +0000
Message-ID: <1493211381.20370.23.camel@synopsys.com>
References: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
         <20170329.143014.2001816338079751776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "eladkan@mellanox.com" <eladkan@mellanox.com>,
        "noamca@mellanox.com" <noamca@mellanox.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:44002 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946541AbdDZM40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 08:56:26 -0400
In-Reply-To: <20170329.143014.2001816338079751776.davem@davemloft.net>
Content-Language: en-US
Content-ID: <2E4D20F1EFFDC1428C7A02E397684085@internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRGF2aWQsIGFsbCwNCg0KT24gV2VkLCAyMDE3LTAzLTI5IGF0IDE0OjMwIC0wNzAwLCBEYXZp
ZCBNaWxsZXIgd3JvdGU6DQo+IEZyb206IFZsYWQgWmFraGFyb3YgPFZsYWRpc2xhdi5aYWtoYXJv
dkBzeW5vcHN5cy5jb20+DQo+IERhdGU6IFdlZCwgMjkgTWFyIDIwMTcgMTM6NDE6NDYgKzAzMDAN
Cj4gDQo+ID4gDQo+ID4gQWZ0ZXIgYSBuZXcgTkFQSV9TVEFURV9NSVNTRUQgc3RhdGUgd2FzIGFk
ZGVkIHRvIE5BUEkgd2UgY2FuIGdldCBpbnRvDQo+ID4gdGhpcyBzdGF0ZSBhbmQgaW4gc3VjaCBj
YXNlIHdlIGhhdmUgdG8gcmVzY2hlZHVsZSBOQVBJIGFzIHNvbWUgd29yayBpcw0KPiA+IHN0aWxs
IHBlbmRpbmcgYW5kIHdlIGhhdmUgdG8gcHJvY2VzcyBpdC4gbmFwaV9jb21wbGV0ZV9kb25lKCkg
ZnVuY3Rpb24NCj4gPiByZXR1cm5zIGZhbHNlIGlmIHdlIGhhdmUgdG8gcmVzY2hlZHVsZSBzb21l
dGhpbmcgKGUuZy4gaW4gY2FzZSB3ZSB3ZXJlDQo+ID4gaW4gTUlTU0VEIHN0YXRlKSBhcyBjdXJy
ZW50IHBvbGxpbmcgaGF2ZSBub3QgYmVlbiBjb21wbGV0ZWQgeWV0Lg0KPiA+IA0KPiA+IG5wc19l
bmV0IGRyaXZlciBoYXNuJ3QgYmVlbiB2ZXJpZnlpbmcgdGhlIHJldHVybiB2YWx1ZSBvZg0KPiA+
IG5hcGlfY29tcGxldGVfZG9uZSgpIGFuZCBoYXMgYmVlbiBmb3JjaWJseSBlbmFibGluZyBpbnRl
cnJ1cHRzLiBUaGF0IGlzDQo+ID4gbm90IGNvcnJlY3QgYXMgd2Ugc2hvdWxkIG5vdCBlbmFibGUg
aW50ZXJydXB0cyBiZWZvcmUgd2UgaGF2ZSBwcm9jZXNzZWQNCj4gPiBhbGwgc2NoZWR1bGVkIHdv
cmsuIEFzIGEgcmVzdWx0IHdlIHdlcmUgZ2V0dGluZyB0cmFwcGVkIGluIGludGVycnVwdA0KPiA+
IGhhbmxkZXIgY2hhaW4gYXMgd2UgaGFkIG5ldmVyIGJlZW4gYWJsZSB0byBkaXNhYmFsZSBldGhl
cm5ldA0KPiA+IGludGVycnVwdHMgYWdhaW4uDQo+ID4gDQo+ID4gU28gdGhpcyBwYXRjaCBtYWtl
cyBucHNfZW5ldF9wb2xsKCkgZnVuYyB2ZXJpZnkgcmV0dXJuIHZhbHVlIG9mDQo+ID4gbmFwaV9j
b21wbGV0ZV9kb25lKCkgYW5kIGVuYWJsZSBpbnRlcnJ1cHRzIG9ubHkgaW4gY2FzZSBhbGwgc2No
ZWR1bGVkDQo+ID4gd29yayBoYXMgYmVlbiBjb21wbGV0ZWQuDQo+ID4gDQo+ID4gU2lnbmVkLW9m
Zi1ieTogVmxhZCBaYWtoYXJvdiA8dnpha2hhckBzeW5vcHN5cy5jb20+DQo+IA0KPiBBcHBsaWVk
Lg0KPiANCj4gRXJpYywgaWYgdGhpcyBpcyByZWFsbHkgcmVxdWlyZWQgbm93LCB3ZSBoYXZlIDE0
OCBicm9rZW4gZHJpdmVycyBzdGlsbC4NCg0KQ291bGQgeW91IHBsZWFzZSBiYWNrcG9ydCB0aGlz
IHBhdGNoIHRvIHN0YWJsZSB0cmVlIChzdGFydGluZyBmcm9tIDQuMTApIGFzIGl0IGlzIHByZXR0
eSBpbXBvcnRhbnQgYW5kIGZpeGVzIG5wc19lbmV0DQpkcml2ZXI/DQoNCkl0IGJlY2FtZSBhY3R1
YWwgYWZ0ZXIgRXJpYydzIGNvbW1pdMKgMzllNmM4MjA4ZDdiIChuZXQ6IHNvbHZlIGEgTkFQSSBy
YWNlKSB3aGljaCBoYXMgYWxyZWFkeSBiZWVuIGJhY2twb3J0ZWQgdG8gNC4xMC4NCg0KVGhhbmtz
Lg0KDQotLSANCkJlc3QgcmVnYXJkcywNClZsYWQgWmFraGFyb3YgPHZ6YWtoYXJAc3lub3BzeXMu
Y29tPg==
