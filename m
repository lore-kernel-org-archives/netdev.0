From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Tue, 29 Aug 2017 01:34:23 +0000
Message-ID: <VI1PR0501MB2143575D285D155C3AD465D3AB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-3-git-send-email-chrism@mellanox.com>
 <a562fbec-797f-1cb2-8af5-cce36126aa23@mojatatu.com>
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
Received: from mail-ve1eur01on0086.outbound.protection.outlook.com ([104.47.1.86]:33184
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751211AbdH2Be0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 21:34:26 -0400
In-Reply-To: <a562fbec-797f-1cb2-8af5-cce36126aa23@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKYW1hbCBIYWRpIFNhbGltIFtt
YWlsdG86amhzQG1vamF0YXR1LmNvbV0NCj4gU2VudDogVHVlc2RheSwgQXVndXN0IDI5LCAyMDE3
IDU6NTYgQU0NCj4gVG86IENocmlzIE1pIDxjaHJpc21AbWVsbGFub3guY29tPjsgbmV0ZGV2QHZn
ZXIua2VybmVsLm9yZw0KPiBDYzogeGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tOyBqaXJpQHJlc251
bGxpLnVzOyBkYXZlbUBkYXZlbWxvZnQubmV0Ow0KPiBtYXdpbGNveEBtaWNyb3NvZnQuY29tDQo+
IFN1YmplY3Q6IFJlOiBbcGF0Y2ggbmV0LW5leHQgMi8zXSBuZXQvc2NoZWQ6IENoYW5nZSBjbHNf
Zmxvd2VyIHRvIHVzZSBJRFINCj4gDQo+IE9uIDE3LTA4LTI4IDAyOjQxIEFNLCBDaHJpcyBNaSB3
cm90ZToNCj4gPiBDdXJyZW50bHksIGFsbCBmaWx0ZXJzIHdpdGggdGhlIHNhbWUgcHJpb3JpdHkg
YXJlIGxpbmtlZCBpbiBhIGRvdWJseQ0KPiA+IGxpbmtlZCBsaXN0LiBFdmVyeSBmaWx0ZXIgc2hv
dWxkIGhhdmUgYSB1bmlxdWUgaGFuZGxlLiBUbyBtYWtlIHRoZQ0KPiA+IGhhbmRsZSB1bmlxdWUs
IHdlIG5lZWQgdG8gaXRlcmF0ZSB0aGUgbGlzdCBldmVyeSB0aW1lIHRvIHNlZSBpZiB0aGUNCj4g
PiBoYW5kbGUgZXhpc3RzIG9yIG5vdCB3aGVuIGluc2VydGluZyBhIG5ldyBmaWx0ZXIuIEl0IGlz
IHRpbWUtY29uc3VtaW5nLg0KPiA+IEZvciBleGFtcGxlLCBpdCB0YWtlcyBhYm91dCA1bTMuMTY5
cyB0byBpbnNlcnQgNjRLIHJ1bGVzLg0KPiA+DQo+ID4gVGhpcyBwYXRjaCBjaGFuZ2VzIGNsc19m
bG93ZXIgdG8gdXNlIElEUi4gV2l0aCB0aGlzIHBhdGNoLCBpdCB0YWtlcw0KPiA+IGFib3V0IDBt
MS4xMjdzIHRvIGluc2VydCA2NEsgcnVsZXMuIFRoZSBpbXByb3ZlbWVudCBpcyBodWdlLg0KPiA+
DQo+ID4gQnV0IHBsZWFzZSBub3RlIHRoYXQgaW4gdGhpcyB0ZXN0aW5nLCBhbGwgZmlsdGVycyBz
aGFyZSB0aGUgc2FtZSBhY3Rpb24uDQo+ID4gSWYgZXZlcnkgZmlsdGVyIGhhcyBhIHVuaXF1ZSBh
Y3Rpb24sIHRoYXQgaXMgYW5vdGhlciBib3R0bGVuZWNrLg0KPiA+IEZvbGxvdy11cCBwYXRjaCBp
biB0aGlzIHBhdGNoc2V0IGFkZHJlc3NlcyB0aGF0Lg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTog
Q2hyaXMgTWkgPGNocmlzbUBtZWxsYW5veC5jb20+DQo+ID4gU2lnbmVkLW9mZi1ieTogSmlyaSBQ
aXJrbyA8amlyaUBtZWxsYW5veC5jb20+DQo+IA0KPiBBY2tlZC1ieTogSmFtYWwgSGFkaSBTYWxp
bSA8amhzQG1vamF0YXR1LmNvbT4NCj4gDQo+IEFzIENvbmcgYXNrZWQgbGFzdCB0aW1lIC0gYW55
IHBsYW5zIHRvIGFkZCB0byBvdGhlciBjbGFzc2lmaWVycz8NCkkgdGhpbmsgaWYgb3RoZXIgY2xh
c3NpZmllcnMgZG9uJ3QgbmVlZCBzbyBtYW55IGl0ZW1zLCBsaXN0IGlzIGVub3VnaCBmb3IgdGhl
bS4NCklmIHdlIGNoYW5nZSBhbGwgb2YgdGhlbSwgd2UgbmVlZCBzcGVuZCBhIGxvdCBvZiB0aW1l
IHRvIHRlc3QgdGhlbSB0byBtYWtlIHN1cmUNCnRoZXJlIGlzIG5vIHJlZ3Jlc3Npb24uIEJ1dCB0
aGUgYmVuZWZpdCBpcyBub3QgdmVyeSBiaWcuIElmIGEgY2VydGFpbiBjbGFzc2lmaWVyDQpuZWVk
IHRvIGNoYW5nZSBpbiB0aGUgZnV0dXJlLCBmbG93ZXIgaXMgYW4gZXhhbXBsZSBmb3IgcmVmZXJl
bmNlLg0KDQotQ2hyaXMNCj4gDQo+IGNoZWVycywNCj4gamFtYWwNCg==
