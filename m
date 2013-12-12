From: "Asano, Yasushi" <yasushi.asano@jp.fujitsu.com>
Subject: RE: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing
 behavior while valid_lft is infinity
Date: Thu, 12 Dec 2013 00:58:10 +0000
Message-ID: <4AE7B88EC8BA74469869BB7EEB7D66671BF674D0@g01jpexmbyt23>
References: <4AE7B88EC8BA74469869BB7EEB7D66671BF656D2@g01jpexmbyt23>
 <20131209234704.GF7396@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:58970 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab3LLA6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 19:58:15 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0F4493EE1AF
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:58:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC95645DE5A
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:58:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE38E45DE53
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:58:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2921E08001
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:58:13 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7844F1DB803A
	for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:58:13 +0900 (JST)
In-Reply-To: <20131209234704.GF7396@order.stressinduktion.org>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnDQo+IFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10gT24gQmVo
YWxmIE9mIEhhbm5lcyBGcmVkZXJpYyBTb3dhDQo+IFNlbnQ6IFR1ZXNkYXksIERlY2VtYmVyIDEw
LCAyMDEzIDg6NDcgQU0NCj4gVG86IEFzYW5vLCBZYXN1c2hpDQo+IENjOiBuZXRkZXZAdmdlci5r
ZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8xXSBpcHY2IGFkZHJjb25mOmZpeCBw
cmVmZXJyZWQgbGlmZXRpbWUNCj4gc3RhdGUtY2hhbmdpbmcgYmVoYXZpb3Igd2hpbGUgdmFsaWRf
bGZ0IGlzIGluZmluaXR5DQo+IEltcG9ydGFuY2U6IEhpZ2gNCj4gDQo+IE9uIE1vbiwgRGVjIDA5
LCAyMDEzIGF0IDA1OjU0OjM3QU0gKzAwMDAsIEFzYW5vLCBZYXN1c2hpIHdyb3RlOg0KPiA+IGZy
b206IFlhc3VzaGkgQXNhbm8gIDx5YXN1c2hpLmFzYW5vQGpwLmZ1aml0c3UuY29tPg0KPiA+DQo+
ID4gVGhlcmUgaXMgYSBwcm9ibGVtIHdoZW4gc2V0dGluZyB0aGUgbGlmZXRpbWUgb2YgYW4gSVB2
NiBhZGRyZXNzLg0KPiA+IFdoZW4gSSBzZXQgcHJlZmVycmVkX2xmdCB0byBhIHZhbHVlIG5vdCB6
ZXJvIG9yIGluZmluaXR5LCB3aGlsZSB2YWxpZF9sZnQNCj4gaXMgaW5maW5pdHkoMHhmZmZmZmZm
ZikNCj4gPiBwcmVmZXJyZWQgbGlmZXRpbWUgaXMgc2V0IHRvIGZvcmV2ZXIgYW5kIGRvZXMgbm90
IHVwZGF0ZS4NCj4gPiBUaGVyZWZvcmUgcHJlZmVycmVkIGxpZmV0aW1lIG5ldmVyIGJlY29tZXMg
ZGVwcmVjYXRlZC4NCj4gPg0KPiA+IEkgdGhpbmsgdmFsaWQgbGlmZXRpbWUgYW5kIHByZWZlcnJl
ZCBsaWZldGltZSBzaG91bGQgYmUgc2V0IGluZGVwZW5kZW50bHksDQo+ID4gZXZlbiBpZiB2YWxp
ZCBsaWZldGltZSBpcyBpbmZpbml0eSwgcHJlZmVycmVkIGxpZmV0aW1lIG11c3QgZXhwaXJlDQo+
IGNvcnJlY3RseSAobWVhbmluZyBpdCBtdXN0IGV2ZW50dWFsbHkgYmVjb21lIGRlcHJlY2F0ZWQp
DQo+ID4NCj4gPiBJIG1hZGUgYSBwYXRjaCBmb3IgMy4xMiBzdGFibGUgdG8gc29sdmUgdGhlIHBy
b2JsZW0uDQo+IA0KPiBUaGlzIGluZGVlZCBjb3VsZCBiZSBpbXByb3ZlZC4gVGhhbmtzIGZvciB0
aGUgcGF0Y2guIEJ1dCB5b3Ugc2hvdWxkIGJhc2UNCj4gaXQgb24gbmV0LW5leHQgc28gaXQgY2Fu
IGJlIGFwcGxpZWQgYW5kIHBsZWFzZSBjbGVhbiB1cCB0aGUgd2FybmluZ3MNCj4gYW5kIGVycm9y
cyBpZiB5b3UgcnVuIHRoZSBwYXRjaCB0aHJvdWdoIC4vc2NyaXB0cy9jaGVja3BhdGNoIC0tc3Ry
aWN0Lg0KPiANCj4gVGhhbmsgeW91LA0KPiANCj4gICBIYW5uZXMNCj4gDQpJIG1hZGUgYSBwYXRj
aCBiYXNlZCBvbiBuZXQtbmV4dCBhbmQgZW1haWxlZCBNTCB1c2luZyBnaXQgc2VuZC1lbWFpbCBs
YXN0IG5pZ2h0Lg0KDQpTdWJqZWN0OiBbUEFUQ0ggMS8xXSBpcHY2IGFkZHJjb25mOmZpeCBwcmVm
ZXJyZWQgbGlmZXRpbWUgc3RhdGUtY2hhbmdpbmcgYmVoYXZpb3Igd2hpbGUgdmFsaWRfbGZ0IGlz
IGluZmluaXR5DQpEYXRlOiBXZWQsIDExIERlYyAyMDEzIDE5OjU3OjMyICswOTAwDQpNZXNzYWdl
LUlEOiA8MTM4Njc1OTQ1Mi0yMjE1OS0xLWdpdC1zZW5kLWVtYWlsLXlhc3VzaGkuYXNhbm9AanAu
ZnVqaXRzdS5jb20+DQpYLU1haWxlcjogZ2l0LXNlbmQtZW1haWwgMS43LjEyLjQNCg0KVGhhbmsg
eW91IGZvciB5b3VyIHRpbWUgYW5kIGFzc2lzdGFuY2UgcmVnYXJkaW5nIHRoaXMgbWF0dGVyLg0K
WWFzdXNoaQ0KDQo=
