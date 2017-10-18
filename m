From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Wed, 18 Oct 2017 01:03:31 +0000
Message-ID: <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com>
 <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
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
Received: from mail-eopbgr10074.outbound.protection.outlook.com ([40.107.1.74]:9824
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756151AbdJRBDe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 21:03:34 -0400
In-Reply-To: <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBDb25nIFdhbmcgW21haWx0bzp4
aXlvdS53YW5nY29uZ0BnbWFpbC5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIE9jdG9iZXIgMTcsIDIw
MTcgMTE6NTMgUE0NCj4gVG86IENocmlzIE1pIDxjaHJpc21AbWVsbGFub3guY29tPg0KPiBDYzog
TGludXggS2VybmVsIE5ldHdvcmsgRGV2ZWxvcGVycyA8bmV0ZGV2QHZnZXIua2VybmVsLm9yZz47
IEphbWFsIEhhZGkNCj4gU2FsaW0gPGpoc0Btb2phdGF0dS5jb20+OyBMdWNhcyBCYXRlcyA8bHVj
YXNiQG1vamF0YXR1LmNvbT47IEppcmkgUGlya28NCj4gPGppcmlAcmVzbnVsbGkudXM+OyBEYXZp
ZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+IFN1YmplY3Q6IFJlOiBbcGF0Y2ggbmV0
IHYyIDEvNF0gbmV0L3NjaGVkOiBDaGFuZ2UgdGNfYWN0aW9uIHJlZmNudCBhbmQNCj4gYmluZGNu
dCB0byBhdG9taWMNCj4gDQo+IE9uIE1vbiwgT2N0IDE2LCAyMDE3IGF0IDY6MTQgUE0sIENocmlz
IE1pIDxjaHJpc21AbWVsbGFub3guY29tPiB3cm90ZToNCj4gPiBJIGRvbid0IHRoaW5rIHRoaXMg
YnVnIHdlcmUgaW50cm9kdWNlZCBieSBhYm92ZSB0d28gY29tbWl0cyBvbmx5Lg0KPiA+IEFjdHVh
bGx5LCB0aGlzIGJ1ZyB3ZXJlIGludHJvZHVjZWQgYnkgc2V2ZXJhbCBjb21taXRzLCBhdCBsZWFz
dCB0aGUNCj4gZm9sbG93aW5nOg0KPiA+IDEuIHJlZmNudCBhbmQgYmluZGNudCBhcmUgbm90IGF0
b21pYw0KPiANCj4gTm9wZSwgaXQgaXMgcGVyZmVjdGx5IG9rYXkgd2l0aCBub24tYXRvbWljIGFz
IGxvbmcgYXMgbm8gcGFyYWxsZWwsIGFuZCB3aXRob3V0DQo+IFJDVSBjYWxsYmFjayB0aGV5IGFy
ZSBwZXJmZWN0bHkgc2VyaWFsaXplZCBieSBSVE5MLg0KQWdyZWUuDQo+IA0KPiANCj4gPiAyLiBw
YXNzaW5nIGFjdGlvbnMgdXNpbmcgbGlzdCBpbnN0ZWFkIG9mIGFycmF5cyAoSSB0aGluayBpbml0
aWFsbHkgd2UNCj4gPiBhcmUgdXNpbmcgYXJyYXlzKQ0KPiANCj4gV2UgYXJlIGRpc2N1c3Npbmcg
cGF0Y2ggMS80LCB0aGlzIGlzIHBhdGNoIDIvNCwgc28gaXJyZWxldmFudC4NCkFncmVlLg0KPiAN
Cj4gDQo+ID4gMy4gdXNpbmcgUkNVIGNhbGxiYWNrcw0KPiANCj4gVGhpcyBpbnRyb2R1Y2VzIHBy
b2JsZW0gMS4NCkkgdGhpbmsgdGhpcyBwYXRjaCBzZXQgb25seSBmaXhlcyBvbmUgcHJvYmxlbSwg
dGhhdCdzIHRoZSByYWNlIGFuZCB0aGUgcGFuaWMuDQpXaGF0IGRvIHlvdSBtZWFuIGJ5IHByb2Js
ZW0gMS4NCj4gDQo+IA0KPiA+IFNvIGluc3RlYWQgb2YgYmxhbWluZyB0aGUgbGF0ZXN0IGNvbW1p
dCwgaXQgaXMgYmV0dGVyIHRvIHNheSBpdCBpcyBhIHByZS1naXQgZXJyb3IuDQo+IA0KPiBZb3Ug
YXJlIHdyb25nLg0KT0ssIHlvdSBhcmUgcmlnaHQuIEJ1dCBjb3VsZCBJIGtub3cgd2hhdCdzIHlv
dXIgc3VnZ2VzdGlvbiBmb3IgdGhpcyBwYXRjaCBzZXQ/DQoxLiByZWplY3QgaXQ/DQoyLiBjaGFu
Z2UgdGhlICJGaXhlcyIgYXMgeW91IHN1Z2dlc3RlZD8NCjMuIHNvbWV0aGluZyBlbHNlPw0KDQpU
aGFua3MsDQpDaHJpcw0K
