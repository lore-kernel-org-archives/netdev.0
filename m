From: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>
Subject: RE: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Tue, 31 Jan 2017 06:47:29 +0000
Message-ID: <CS1PR84MB00721E8E05290D70693B0EFECA4A0@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
 <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
 <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, Elad Raz <e@eladraz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0131.outbound.protection.outlook.com ([104.47.41.131]:47469
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750710AbdAaGrp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 01:47:45 -0500
In-Reply-To: <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SEkgQ29uZywNCglIYXZlIHlvdSBwb3N0ZWQgYW55IHBhdGNoIGZvciB0aGUgc2FtZT8gSSBhbSBs
b29raW5nIGZvciBzaW5nbGUgbmV0bGluayBzb2NrZXQgdG8gaGFuZGxlIG11bHRpcGxlIG5ldHdv
cmsgbmFtZXNwYWNlIGV2ZW50cyB1c2luZyBORVRMSU5LX0xJU1RFTl9BTExfTlNJRC4gSSBkb24n
dCBzZWUgZGV0ZWN0aW9uIG9mIG5ldyBuYW1lc3BhY2VzIGJ5IHRoaXMgc29ja2V0IHlldCBhbmQg
Y2F1c2luZyB1cGRhdGVzIHRvIGJlIG1pc3NlZC4NCg0KDQpUaGFua3MNCktyaXNobmEgTW9oYW4u
DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10gT24gQmVoYWxm
IE9mIENvbmcgV2FuZw0KU2VudDogVGh1cnNkYXksIE9jdG9iZXIgMjAsIDIwMTYgMTozNyBBTQ0K
VG86IEVsYWQgUmF6IDxlQGVsYWRyYXouY29tPg0KQ2M6IE5pY29sYXMgRGljaHRlbCA8bmljb2xh
cy5kaWNodGVsQDZ3aW5kLmNvbT47IERhdmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47
IExpbnV4IE5ldGRldiBMaXN0IDxuZXRkZXZAdmdlci5rZXJuZWwub3JnPjsgSmlyaSBQaXJrbyA8
amlyaUByZXNudWxsaS51cz47IElkbyBTY2hpbW1lbCA8aWRvc2NoQG1lbGxhbm94LmNvbT47IFlv
dGFtIEdpZ2kgPHlvdGFtZ0BtZWxsYW5veC5jb20+DQpTdWJqZWN0OiBSZTogW1BhdGNoIG5ldC1u
ZXh0IDIvMl0gbmV0bnM6IGF2b2lkIGRpc2FibGluZyBpcnEgZm9yIG5ldG5zIGlkDQoNCk9uIFdl
ZCwgT2N0IDE5LCAyMDE2IGF0IDg6MjEgQU0sIEVsYWQgUmF6IDxlQGVsYWRyYXouY29tPiB3cm90
ZToNCj4gT24gRnJpLCBTZXAgMiwgMjAxNiBhdCAxMToxMiBBTSwgTmljb2xhcyBEaWNodGVsIA0K
PiA8bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbT4gd3JvdGU6DQo+PiBMZSAwMi8wOS8yMDE2IMOg
IDA2OjUzLCBDb25nIFdhbmcgYSDDqWNyaXQgOg0KPj4+IFdlIG5ldmVyIHJlYWQgb3IgY2hhbmdl
IG5ldG5zIGlkIGluIGhhcmRpcnEgY29udGV4dCwgdGhlIG9ubHkgcGxhY2UgDQo+Pj4gd2UgcmVh
ZCBuZXRucyBpZCBpbiBzb2Z0aXJxIGNvbnRleHQgaXMgaW4gdnhsYW5feG1pdCgpLiBTbywgaXQg
DQo+Pj4gc2hvdWxkIGJlIGVub3VnaCB0byBqdXN0IGRpc2FibGUgQkguDQo+Pg0KPj4gQXJlIHlv
dSBzdXJlPyBEaWQgeW91IGF1ZGl0IGFsbCBwYXJ0IG9mIHRoZSBjb2RlPw0KPj4gcGVlcm5ldDJp
ZCgpIGlzIGNhbGxlZCBmcm9tIG5ldGxpbmsgY29yZSBzeXN0ZW0gKGRvX29uZV9icm9hZGNhc3Qo
KSkuIA0KPj4gQXJlIHlvdSBzdXJlIHRoYXQgbm8gZHJpdmVyIGNhbGwgdGhpcyBmdW5jdGlvbiBm
cm9tIGFuIGhhcmQgaXJxIGNvbnRleHQ/DQo+Pg0KPj4gSSB0aGluayB0aGF0IE5FVExJTktfTElT
VEVOX0FMTF9OU0lEIGlzIGxhcmdlbHkgdW50ZXN0ZWQsIHNvIGl0IHdpbGwgDQo+PiBiZSBoYXJk
IHRvIGRldGVjdCBhIGJ1ZyBpbnRyb2R1Y2VkIGluIHRoaXMgZmVhdHVyZS4NCj4NCj4gSSdtIHNl
ZWluZyBzdHJhbmdlIHRoaW5ncyBvbiBvdXIgc3lzdGVtcyBvbiBib290IHRpbWUgd2hlbiB0cnlp
bmcgdG8gDQo+IG1vdW50IGF1dG9mcy4NCj4gSSBiaXNlY3RlZCBhbmQgZ290IHRoaXMgcGF0Y2gg
YXMgdGhlIGJhZCBvbmUuDQo+IEkgY2FuIHNlZSB0aGF0IG9ubHkgd2hlbiBJJ20gdXNpbmcgImRl
YnVnIiBjb25maWcgZmlsZS4NCg0KWWVhaCwgSSBzYXcgdGhlIHNhbWUgcmVwb3J0IGZyb20gU0VM
aW51eCBkZXZlbG9wZXJzLCBJIGFtIHdvcmtpbmcgb24gYSBmaXguDQoNClRoYW5rcy4NCg==
