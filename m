From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net 0/4] net/sched: Fix a system panic when deleting
 filters
Date: Mon, 16 Oct 2017 11:20:52 +0000
Message-ID: <VI1PR0501MB2143AAEF20039638907C1AE1AB4F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
 <556e3159-78ae-d07b-928e-37d99d380a3d@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "lucasb@mojatatu.com" <lucasb@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20086.outbound.protection.outlook.com ([40.107.2.86]:62432
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751501AbdJPLUz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 07:20:55 -0400
In-Reply-To: <556e3159-78ae-d07b-928e-37d99d380a3d@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgSmFtYWwsDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSmFtYWwg
SGFkaSBTYWxpbSBbbWFpbHRvOmpoc0Btb2phdGF0dS5jb21dDQo+IFNlbnQ6IE1vbmRheSwgT2N0
b2JlciAxNiwgMjAxNyA3OjA2IFBNDQo+IFRvOiBDaHJpcyBNaSA8Y2hyaXNtQG1lbGxhbm94LmNv
bT47IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGx1Y2FzYkBtb2phdGF0dS5jb207IHhp
eW91Lndhbmdjb25nQGdtYWlsLmNvbTsgamlyaUByZXNudWxsaS51czsNCj4gZGF2ZW1AZGF2ZW1s
b2Z0Lm5ldA0KPiBTdWJqZWN0OiBSZTogW3BhdGNoIG5ldCAwLzRdIG5ldC9zY2hlZDogRml4IGEg
c3lzdGVtIHBhbmljIHdoZW4gZGVsZXRpbmcNCj4gZmlsdGVycw0KPiANCj4gDQo+IEhpIENocmlz
LA0KPiANCj4gT24gMTctMTAtMTYgMDQ6MzEgQU0sIENocmlzIE1pIHdyb3RlOg0KPiA+IElmIHNv
bWUgZmlsdGVycyBzaGFyZSB0aGUgc2FtZSBhY3Rpb24sIHdoZW4gZGVsZXRpbmcgdGhlc2UgZmls
dGVycywNCj4gPiBzeXN0ZW0gbWF5IHBhbmljLiBUaGlzIHBhdGNoc2V0IGZpeGVzIHRoaXMgaXNz
dWUuIEFuZCB0aGUgdGVzdCBjYXNlDQo+ID4gZmluZGluZyB0aGlzIGlzc3VlIGlzIGFsc28gaW50
ZWdyYXRlZCBpbnRvIHRjIHRlc3Qgc3VpdGUgb2Ygc2VsZnRlc3RzLg0KPiA+DQo+IA0KPiBJIHRo
aW5rIHRoaXMgd291bGQgcmVhZCBiZXR0ZXIgaWYgcmUtd29yZGVkIGFzOg0KPiAtLS0NCj4gSWYg
c29tZSBmaWx0ZXJzIHNoYXJlIHRoZSBzYW1lIGFjdGlvbiwgd2hlbiBkZWxldGluZyB0aGVzZSBm
aWx0ZXJzLCBpdCBpcw0KPiBwb3NzaWJsZSB0byBjcmVhdGUgYSBzeXN0ZW0gcGFuaWMuIFRoaXMg
aXMgYmVjYXVzZSBkZWxldGlvbnMgY291bGQgYmUNCj4gbWFuaXB1bGF0ZWQgYnkgbWFueSBSQ1Ug
Y2FsbGJhY2tzIGF0IHRoZSBzYW1lIHRpbWUuDQo+IFRoaXMgcGF0Y2ggc2V0IGZpeGVzIHRoZXNl
IGlzc3Vlcy4NCj4gVG8gcmVwcm9kdWNlIHRoZSBpc3N1ZSBydW4gc2VsZnRlc3RzIGluIHBhdGNo
IDMgYW5kIDQuDQo+IFRvIHRlc3QgaWYgdGhlIGlzc3VlIHdhcyBmaXhlZCwgYXBwbHkgcGF0Y2hl
cyAxIGFuZCAyIGFuZCB0aGVuIHJlcGVhdCB0aGUgdGVzdHMuDQo+IC0tLS0tLQ0KRG9uZS4NCj4g
DQo+IE90aGVyIHRoYW4gdGhhdCBhbGwgbG9vayBnb29kIHRvIG1lIGFuZDoNCj4gDQo+IEFja2Vk
LWJ5OiBKYW1hbCBIYWRpIFNhbGltIDxqaHNAbW9qYXRhdHUuY29tPg0KRG9uZS4gQW5kIHRoYW5r
cyBmb3IgeW91ciByZXZpZXcuDQoNClRoYW5rcywNCkNocmlzDQo+IA0KPiBjaGVlcnMsDQo+IGph
bWFsDQo=
