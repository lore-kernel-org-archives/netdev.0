From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net-next v2 3/3] net/sched: Change act_api and act_xxx
 modules to use IDR
Date: Thu, 31 Aug 2017 01:05:04 +0000
Message-ID: <VI1PR0501MB214338E35631CF03BAA74CD7AB9D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
 <1504074719-15147-4-git-send-email-chrism@mellanox.com>
 <5b54f1c5-688a-5a7d-25bd-05dc9cbecebd@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mawilcox@microsoft.com" <mawilcox@microsoft.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0086.outbound.protection.outlook.com ([104.47.1.86]:49056
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750822AbdHaBFI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 21:05:08 -0400
In-Reply-To: <5b54f1c5-688a-5a7d-25bd-05dc9cbecebd@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSmFtYWwgSGFkaSBTYWxp
bSBbbWFpbHRvOmpoc0Btb2phdGF0dS5jb21dDQo+IFNlbnQ6IFdlZG5lc2RheSwgQXVndXN0IDMw
LCAyMDE3IDg6MTEgUE0NCj4gVG86IENocmlzIE1pIDxjaHJpc21AbWVsbGFub3guY29tPjsgbmV0
ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBDYzogeGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tOyBqaXJp
QHJlc251bGxpLnVzOyBkYXZlbUBkYXZlbWxvZnQubmV0Ow0KPiBtYXdpbGNveEBtaWNyb3NvZnQu
Y29tDQo+IFN1YmplY3Q6IFJlOiBbcGF0Y2ggbmV0LW5leHQgdjIgMy8zXSBuZXQvc2NoZWQ6IENo
YW5nZSBhY3RfYXBpIGFuZCBhY3RfeHh4DQo+IG1vZHVsZXMgdG8gdXNlIElEUg0KPiANCj4gT24g
MTctMDgtMzAgMDI6MzEgQU0sIENocmlzIE1pIHdyb3RlOg0KPiA+IFR5cGljYWxseSwgZWFjaCBU
QyBmaWx0ZXIgaGFzIGl0cyBvd24gYWN0aW9uLiBBbGwgdGhlIGFjdGlvbnMgb2YgdGhlDQo+ID4g
c2FtZSB0eXBlIGFyZSBzYXZlZCBpbiBpdHMgaGFzaCB0YWJsZS4gQnV0IHRoZSBoYXNoIGJ1Y2tl
dHMgYXJlIHRvbw0KPiA+IHNtYWxsIHRoYXQgaXQgZGVncmFkZXMgdG8gYSBsaXN0LiBBbmQgdGhl
IHBlcmZvcm1hbmNlIGlzIGdyZWF0bHkNCj4gPiBhZmZlY3RlZC4gRm9yIGV4YW1wbGUsIGl0IHRh
a2VzIGFib3V0IDBtMTEuOTE0cyB0byBpbnNlcnQgNjRLIHJ1bGVzLg0KPiA+IElmIHdlIGNvbnZl
cnQgdGhlIGhhc2ggdGFibGUgdG8gSURSLCBpdCBvbmx5IHRha2VzIGFib3V0IDBtMS41MDBzLg0K
PiA+IFRoZSBpbXByb3ZlbWVudCBpcyBodWdlLg0KPiA+DQo+ID4gQnV0IHBsZWFzZSBub3RlIHRo
YXQgdGhlIHRlc3QgcmVzdWx0IGlzIGJhc2VkIG9uIHByZXZpb3VzIHBhdGNoIHRoYXQNCj4gPiBj
bHNfZmxvd2VyIHVzZXMgSURSLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogQ2hyaXMgTWkgPGNo
cmlzbUBtZWxsYW5veC5jb20+DQo+ID4gU2lnbmVkLW9mZi1ieTogSmlyaSBQaXJrbyA8amlyaUBt
ZWxsYW5veC5jb20+DQo+IA0KPiBBY2tlZC1ieTogSmFtYWwgSGFkaSBTYWxpbSA8amhzQG1vamF0
YXR1LmNvbT4NCj4gDQo+IEFsc28gYWxyZWFkeSBhY2tlZCB0aGlzIGJlZm9yZSBidXQgeW91IGxl
ZnQgaXQgb3V0IGluIHRoaXMgdmVyc2lvbi4gSWYgeW91IG1ha2UNCj4gY2hhbmdlcyB0byB0aGUg
cGF0Y2ggdGhlbiB5b3Ugd2lsbCBuZWVkIGEgbmV3IEFDSy4NClNvcnJ5IGFib3V0IHRoYXQsIEph
bWFsLiBJIHRoaW5rIEkgbmVlZCB0byBtYWtlIGEgbm90ZSBvZiB0aGUgcmV2aWV3IGNvbW1lbnQN
CkluIGNhc2UgSSBmb3JnZXQgaXQuDQo+IA0KPiBEb250IGZvcmdldCB0byB1cGRhdGUgc2VsZnRl
c3RzIHBsZWFzZS4NClN1cmUsIHdlIHdpbGwgd29yayBvbiB0aGF0Lg0KDQpUaGFua3MsDQpDaHJp
cw0KPiANCj4gY2hlZXJzLA0KPiBqYW1hbA0K
