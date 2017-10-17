From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Re: [patch net-next 01/20] net: sched: add block bind/unbind notif.
 and extended block_get/put
Date: Tue, 17 Oct 2017 20:22:16 +0000
Message-ID: <1508271733.11655.3.camel@intel.com>
References: <20171017200615.4530-1-jiri@resnulli.us>
         <20171017200615.4530-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@kernel.org" <ast@kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        "john.hurley@netronome.com" <john.hurley@netronome.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.di
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41607 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759702AbdJQUWR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 16:22:17 -0400
In-Reply-To: <20171017200615.4530-2-jiri@resnulli.us>
Content-Language: en-US
Content-ID: <DB876989DFD1314189D7F8516B379E23@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE3LTEwLTE3IGF0IDIyOjA1ICswMjAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBG
cm9tOiBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNvbT4NCj4gDQo+IEludHJvZHVjZSBuZXcg
dHlwZSBvZiBuZG9fc2V0dXBfdGMgbWVzc2FnZSB0byBwcm9wYWdlIGJpbmRpbmcvdW5iaW5kaW5n
DQo+IG9mIGEgYmxvY2sgdG8gZHJpdmVyLiBDYWxsIHRoaXMgbmRvIHdoZW5ldmVyIHFkaXNjIGdl
dHMvcHV0cyBhIGJsb2NrLg0KPiBBbG9uZ3NpZGUgd2l0aCB0aGlzLCB0aGVyZSdzIG5lZWQgdG8g
cHJvcGFnYXRlIGJpbmRlciB0eXBlIGZyb20gcWRpc2MNCj4gY29kZSBkb3duIHRvIHRoZSBub3Rp
Zmllci4gU28gaW50cm9kdWNlIGV4dGVuZGVkIHZhcmlhbnRzIG9mDQo+IGJsb2NrX2dldC9wdXQg
aW4gb3JkZXIgdG8gcGFzcyB0aGlzIGluZm8uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBKaXJpIFBp
cmtvIDxqaXJpQG1lbGxhbm94LmNvbT4NCj4gLS0tDQo+ICBpbmNsdWRlL2xpbnV4L25ldGRldmlj
ZS5oIHwgIDEgKw0KPiAgaW5jbHVkZS9uZXQvcGt0X2Nscy5oICAgICB8IDQwICsrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKw0KPiAgbmV0L3NjaGVkL2Nsc19hcGkuYyAgICAgICB8IDU2
ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0tDQo+ICAzIGZp
bGVzIGNoYW5nZWQsIDk0IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZm
IC0tZ2l0IGEvaW5jbHVkZS9saW51eC9uZXRkZXZpY2UuaCBiL2luY2x1ZGUvbGludXgvbmV0ZGV2
aWNlLmgNCj4gaW5kZXggMzFiYjMwMS4uMDYyYTRmNSAxMDA2NDQNCj4gLS0tIGEvaW5jbHVkZS9s
aW51eC9uZXRkZXZpY2UuaA0KPiArKysgYi9pbmNsdWRlL2xpbnV4L25ldGRldmljZS5oDQo+IEBA
IC03NzEsNiArNzcxLDcgQEAgdHlwZWRlZiB1MTYgKCpzZWxlY3RfcXVldWVfZmFsbGJhY2tfdCko
c3RydWN0IG5ldF9kZXZpY2UgKmRldiwNCj4gIA0KPiAgZW51bSB0Y19zZXR1cF90eXBlIHsNCj4g
IAlUQ19TRVRVUF9NUVBSSU8sDQo+ICsJVENfU0VUVVBfQkxPQ0ssDQo+ICAJVENfU0VUVVBfQ0xT
VTMyLA0KPiAgCVRDX1NFVFVQX0NMU0ZMT1dFUiwNCj4gIAlUQ19TRVRVUF9DTFNNQVRDSEFMTCwN
Cg0KSSdtIG5vdCBhIGJpZyBmYW4gb2YgYWRkaW5nIHRoaXMgdG8gdGhlIG1pZGRsZSBvZiB0aGUg
ZW51bS4gSXQgd2lsbA0KbWFrZSBpdCBoYXJkZXIgZm9yIHBlb3BsZSB0aGF0IGhhdmUgdG8gYmFj
a3BvcnQgY2hhbmdlcyBhbmQgc3VjaCBzaW5jZQ0KaXQgaXMgcmVvcmRlcmluZyB2YWx1ZXMgdGhh
dCBhcmUgcGFzc2VkIGFzIGEgcGFydCBvZiB0aGUga2FiaSBiZXR3ZWVuDQpkcml2ZXJzIGFuZCB0
aGUga2VybmVsLg0KDQpBbHNvIGRvZXMgdGhpcyBwYXRjaCBzZXQgcmVhbGx5IG5lZWQgdG8gYmUg
MjAgcGF0Y2hlcyBsb25nPyBTZWVtcyBsaWtlDQp5b3UgY291bGQgaGF2ZSBkb25lIHRoaXMgYXMg
YSBzZXQgb2YgOCBhbmQgYW5vdGhlciBvZiAxMiBzaW5jZSB5b3UgbmVlZA0KYWJvdXQgOCBwYXRj
aGVzIHRvIGdldCB0byB0aGUgcG9pbnQgd2hlcmUgeW91IHN0YXJ0IHB1bGxpbmcgdGhlIGNvZGUN
Cm91dCBvZiB0aGUgZHJpdmVycy4NCg0KLSBBbGV4
