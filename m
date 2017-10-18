From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net v3 2/4] net/sched: Use action array instead of action
 list as parameter
Date: Wed, 18 Oct 2017 00:58:56 +0000
Message-ID: <VI1PR0501MB2143ABD1C4794B98468B42B7AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1508203218-17998-1-git-send-email-chrism@mellanox.com>
 <1508203218-17998-3-git-send-email-chrism@mellanox.com>
 <CAM_iQpUz4bKhb2uUiBBeXL6f6BfdAND7sW+az5MjbjbifRnmhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10077.outbound.protection.outlook.com ([40.107.1.77]:40399
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751643AbdJRA7B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 20:59:01 -0400
In-Reply-To: <CAM_iQpUz4bKhb2uUiBBeXL6f6BfdAND7sW+az5MjbjbifRnmhw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQ29uZyBXYW5nIFttYWls
dG86eGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tXQ0KPiBTZW50OiBXZWRuZXNkYXksIE9jdG9iZXIg
MTgsIDIwMTcgMTI6NTYgQU0NCj4gVG86IENocmlzIE1pIDxjaHJpc21AbWVsbGFub3guY29tPg0K
PiBDYzogTGludXggS2VybmVsIE5ldHdvcmsgRGV2ZWxvcGVycyA8bmV0ZGV2QHZnZXIua2VybmVs
Lm9yZz47IEphbWFsIEhhZGkNCj4gU2FsaW0gPGpoc0Btb2phdGF0dS5jb20+OyBMdWNhcyBCYXRl
cyA8bHVjYXNiQG1vamF0YXR1LmNvbT47IEppcmkgUGlya28NCj4gPGppcmlAcmVzbnVsbGkudXM+
OyBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+IFN1YmplY3Q6IFJlOiBbcGF0
Y2ggbmV0IHYzIDIvNF0gbmV0L3NjaGVkOiBVc2UgYWN0aW9uIGFycmF5IGluc3RlYWQgb2YgYWN0
aW9uDQo+IGxpc3QgYXMgcGFyYW1ldGVyDQo+IA0KPiBPbiBNb24sIE9jdCAxNiwgMjAxNyBhdCA2
OjIwIFBNLCBDaHJpcyBNaSA8Y2hyaXNtQG1lbGxhbm94LmNvbT4gd3JvdGU6DQo+ID4gV2hlbiBk
ZXN0cm95aW5nIGZpbHRlcnMsIGFjdGlvbnMgc2hvdWxkIGJlIGRlc3Ryb3llZCBmaXJzdC4NCj4g
PiBUaGUgcG9pbnRlcnMgb2YgZWFjaCBhY3Rpb24gYXJlIHNhdmVkIGluIGFuIGFycmF5LiBUQyBk
b2Vzbid0IHVzZSB0aGUNCj4gPiBhcnJheSBkaXJlY3RseSwgYnV0IHB1dCBhbGwgYWN0aW9ucyBp
biBhIGRvdWJseSBsaW5rZWQgbGlzdCBhbmQgdXNlDQo+ID4gdGhhdCBsaXN0IGFzIHBhcmFtZXRl
ci4NCj4gPg0KPiA+IFRoZXJlIGlzIG5vIHByb2JsZW0gaWYgZWFjaCBmaWx0ZXIgaGFzIGl0cyBv
d24gYWN0aW9ucy4gQnV0IGlmIHNvbWUNCj4gPiBmaWx0ZXJzIHNoYXJlIHRoZSBzYW1lIGFjdGlv
biwgd2hlbiB0aGVzZSBmaWx0ZXJzIGFyZSBkZXN0cm95ZWQsIFJDVQ0KPiA+IGNhbGxiYWNrIGZs
X2Rlc3Ryb3lfZmlsdGVyKCkgbWF5IGJlIGNhbGxlZCBhdCB0aGUgc2FtZSB0aW1lLiBUaGF0DQo+
ID4gbWVhbnMgdGhlIHNhbWUgYWN0aW9uJ3MgJ3N0cnVjdCBsaXN0X2hlYWQgbGlzdCcNCj4gPiBj
b3VsZCBiZSBtYW5pcHVsYXRlZCBhdCB0aGUgc2FtZSB0aW1lLiBJdCBtYXkgcG9pbnQgdG8gYW4g
aW52YWxpZA0KPiA+IGFkZHJlc3Mgc28gdGhhdCBzeXN0ZW0gd2lsbCBwYW5pYy4NCj4gDQo+IFNv
IGlmIHdlIHJlbW92ZSB0aGVzZSBSQ1UgY2FsbGJhY2tzIChieSBhZGRpbmcgYSBzeWNocm9uaXpl
X3JjdSkgdGhpcyBpcyBub3QgYQ0KPiBwcm9ibGVtLCByaWdodD8gDQpNYXliZSB5b3UgYXJlIHJp
Z2h0LiBCdXQgZG8geW91IHRoaW5rIGl0IHdpbGwgY2F1c2UgcGVyZm9ybWFuY2UgaXNzdWUsIEkg
bWVhbiBpdCB0YWtlcw0KbG9uZ2VyIHRpbWUgdG8gZGVzdHJveSBmaWx0ZXJzIGlmIHVzaW5nIHN5
bmNocm9uaXplX3JjdSgpPw0KT3IgaXMgdGhlcmUgYW55IG90aGVyIHJhY2VzIHRoYW4gUkNVIGNh
bGxiYWNrcz8NCldlIGhhdmVuJ3QgZm91bmQgdGhlbS4gIFRoaXMgaXMgdGhlIG9ubHkgb25lIHdl
IGZvdW5kLg0KPiANCj4gDQo+ID4NCj4gPiBUaGlzIHBhdGNoIHVzZXMgdGhlIGFjdGlvbiBhcnJh
eSBkaXJlY3RseSB0byBmaXggdGhpcyBpc3N1ZS4NCj4gPg0KPiA+IEZpeGVzIGNvbW1pdCBpbiBw
cmUtZ2l0IGVyYS4NCj4gPg0KPiA+IEZpeGVzOiAxZGExNzdlNGMzZjQgKCJMaW51eC0yLjYuMTIt
cmMyIikNCj4gDQo+IFRoaXMgaXMgd3JvbmcgdG9vLiBSQ1UgY2FsbGJhY2tzIHdlcmUgaW50cm9k
dWNlZCB2ZXJ5IGxhdGUuDQo=
