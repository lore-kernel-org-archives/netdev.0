From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Thu, 08 Jun 2017 09:59:58 -0400 (EDT)
Message-ID: <20170608.095958.853026498068086014.davem@davemloft.net>
References: <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
        <20170608050041.cte3gpavshg2nmdc@ast-mbp>
        <6CE04FE7-4904-4047-95F5-80461324CDA6@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        edumazet@google.com
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdFHOAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:00:10 -0400
In-Reply-To: <6CE04FE7-4904-4047-95F5-80461324CDA6@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTog5Lil5rW35Y+MIDx5YW5oYWlzaHVhbmdAY21zcy5jaGluYW1vYmlsZS5jb20+DQpEYXRl
OiBUaHUsIDggSnVuIDIwMTcgMTU6MzM6NTggKzA4MDANCg0KPj4gT24gOCBKdW4gMjAxNywgYXQg
MTowMCBQTSwgQWxleGVpIFN0YXJvdm9pdG92IDxhbGV4ZWkuc3Rhcm92b2l0b3ZAZ21haWwuY29t
PiB3cm90ZToNCj4+IA0KPj4gT24gVGh1LCBKdW4gMDgsIDIwMTcgYXQgMTI6NTY6NThQTSArMDgw
MCwg5Lil5rW35Y+MIHdyb3RlOg0KPj4+IA0KPj4+PiBPbiA4IEp1biAyMDE3LCBhdCAxMjozOCBQ
TSwgQWxleGVpIFN0YXJvdm9pdG92IDxhbGV4ZWkuc3Rhcm92b2l0b3ZAZ21haWwuY29tPiB3cm90
ZToNCj4+Pj4gDQo+Pj4+IE9uIFRodSwgSnVuIDA4LCAyMDE3IGF0IDEyOjMyOjQ0UE0gKzA4MDAs
IEhhaXNodWFuZyBZYW4gd3JvdGU6DQo+Pj4+PiBXaGVuIF9faXA2X3RubF9yY3YgZmFpbHMsIHRo
ZSB0dW5fZHN0IHdvbid0IGJlIGZyZWVkLCBzbyBjYWxsDQo+Pj4+PiBkc3RfcmVsZWFzZSB0byBm
cmVlIGl0IGluIGVycm9yIGNvZGUgcGF0aC4NCj4+Pj4+IA0KPj4+Pj4gQ0M6IEFsZXhlaSBTdGFy
b3ZvaXRvdiA8YXN0QGZiLmNvbT4NCj4+Pj4+IEZpeGVzOiA4ZDc5MjY2YmM0OGMgKCJpcDZfdHVu
bmVsOiBhZGQgY29sbGVjdF9tZCBtb2RlIHRvIElQdjYgdHVubmVscyIpDQo+Pj4+PiBTaWduZWQt
b2ZmLWJ5OiBIYWlzaHVhbmcgWWFuIDx5YW5oYWlzaHVhbmdAY21zcy5jaGluYW1vYmlsZS5jb20+
DQo+Pj4+IA0KPj4+PiBJIGRvbid0IGdldCBpdC4gV2h5IGRpZCB5b3Ugc2VuZCBhbm90aGVyIHZl
cnNpb24gb2YgdGhlIHBhdGNoPw0KPj4+PiBXaGF0IHdhcyB3cm9uZyB3aXRoIHByZXZpb3VzIGFw
cHJvYWNoIHRoYXQgbXlzZWxmIGFuZCBFcmljIGFja2VkPw0KPj4+PiANCj4+Pj4gDQo+Pj4gDQo+
Pj4gU29ycnkgZm9yIHlvdXIgY29uZnVzaW5nLCBiZWNhdXNlIFByYXZpbiBTaGVsYXIgZ2l2ZSBh
IGZlZWRiYWNrIGluIGlwdjQgcGF0Y2gsIHNlZSBiZWxvdzoNCj4+IA0KPj4gaG1tLiByaWdodC4N
Cj4+IFRoZW4gaXQgcmFpc2VzIHRoZSBxdWVzdGlvbjogSG93IGRpZCB5b3UgdGVzdCB0aGlzIGFu
ZCBwcmV2aW91cyBwYXRjaD8NCj4+IA0KPj4gc2luY2UgcHJldmlvdXMgdmVyc2lvbiB3YXMgc29y
dC1vZiBmaXhpbmcgdGhlIGJ1ZywgYnV0IGNvbXBsZXRlbHkNCj4+IGJyZWFraW5nIHRoZSBsb2dp
Yy4uLg0KPj4gDQo+PiANCj4gDQo+IFNvcnJ5IGZvciBteSBwcmV2aW91cyBmYXVsdCwgSSB0cmll
ZCB0byBmaXggdGhpcyBwcm9ibGVtIGluIHRoZW9yeSB3aXRob3V0IHRlc3RpbmcgY2FyZWZ1bGx5
Lg0KPiBJIGhhdmUgdGVzdGVkIHRoZSBsYXRlc3QgcGF0Y2hlcywgaXQgd29ya3Mgb2sgbm93Lg0K
DQpUaGlzIGRvZXMgbm90IGluc3RpbGwgYSBsb3Qgb2YgY29uZmlkZW5jZSBpbiB1cy4NCg0KSSB3
YW50IHNvbWVvbmUgZWxzZSB0byB0ZXN0IHRoZXNlIHBhdGNoZXMsIHRoZW4geW91IGNhbiByZXN1
Ym1pdCB0aGVtDQp3aXRoIHByb3BlciBUZXN0ZWQtYnk6IHRhZ3MgYWRkZWQsIHNpbmNlIHlvdSB0
aG91Z2h0IGl0IHdhcyBPSyB0byBzdWJtaXQNCmEgcGF0Y2ggd2l0aG91dCB0ZXN0aW5nIGluIHRo
ZSBmaXJzdCBwbGFjZS4NCg==
