From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
 stmmac_dvr_probe
Date: Thu, 29 Dec 2016 00:28:59 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A916EB3@PGSMSX102.gar.corp.intel.com>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
 <20161227.113405.362102687632949941.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C5A916CA0@PGSMSX102.gar.corp.intel.com>
 <e88996a8-e010-c07f-7dee-d220a6dfc706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "Voon, Weifeng" <weifeng.voon@intel.com>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e88996a8-e010-c07f-7dee-d220a6dfc706@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBGbG9yaWFuIEZhaW5lbGxpIFtt
YWlsdG86Zi5mYWluZWxsaUBnbWFpbC5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBEZWNlbWJlciAy
OSwgMjAxNiAyOjQzIEFNDQo+IFRvOiBLd2VoLCBIb2NrIExlb25nIDxob2NrLmxlb25nLmt3ZWhA
aW50ZWwuY29tPjsgRGF2aWQgTWlsbGVyDQo+IDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBDYzog
Sm9hby5QaW50b0BzeW5vcHN5cy5jb207IHBlcHBlLmNhdmFsbGFyb0BzdC5jb207DQo+IHNlcmFw
aGluLmJvbm5hZmZlQHN0LmNvbTsgYWxleGFuZHJlLnRvcmd1ZUBnbWFpbC5jb207DQo+IG1hbmFi
aWFuQGdtYWlsLmNvbTsgbmlrbGFzLmNhc3NlbEBheGlzLmNvbTsgam9oYW5Aa2VybmVsLm9yZzsN
Cj4gcGF2ZWxAdWN3LmN6OyBPbmcsIEJvb24gTGVvbmcgPGJvb24ubGVvbmcub25nQGludGVsLmNv
bT47IFZvb24sIFdlaWZlbmcNCj4gPHdlaWZlbmcudm9vbkBpbnRlbC5jb20+OyBsYXJzLnBlcnNz
b25AYXhpcy5jb207IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2Vy
Lmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSCB2Ml0gbmV0OiBzdG1tYWM6IGJ1ZyBm
aXggdG8gc3luY2hyb25pemUgc3RtbWFjX29wZW4gYW5kDQo+IHN0bW1hY19kdnJfcHJvYmUNCj4g
DQo+IE9uIDEyLzI3LzIwMTYgMDk6NDkgUE0sIEt3ZWgsIEhvY2sgTGVvbmcgd3JvdGU6DQo+ID4+
IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4+IEZyb206IERhdmlkIE1pbGxlciBbbWFp
bHRvOmRhdmVtQGRhdmVtbG9mdC5uZXRdDQo+ID4+IFNlbnQ6IFdlZG5lc2RheSwgRGVjZW1iZXIg
MjgsIDIwMTYgMTI6MzQgQU0NCj4gPj4gVG86IEt3ZWgsIEhvY2sgTGVvbmcgPGhvY2subGVvbmcu
a3dlaEBpbnRlbC5jb20+DQo+ID4+IENjOiBKb2FvLlBpbnRvQHN5bm9wc3lzLmNvbTsgcGVwcGUu
Y2F2YWxsYXJvQHN0LmNvbTsNCj4gPj4gc2VyYXBoaW4uYm9ubmFmZmVAc3QuY29tOyBmLmZhaW5l
bGxpQGdtYWlsLmNvbTsNCj4gPj4gYWxleGFuZHJlLnRvcmd1ZUBnbWFpbC5jb207IG1hbmFiaWFu
QGdtYWlsLmNvbTsNCj4gPj4gbmlrbGFzLmNhc3NlbEBheGlzLmNvbTsgam9oYW5Aa2VybmVsLm9y
ZzsgcGF2ZWxAdWN3LmN6OyBPbmcsIEJvb24NCj4gPj4gTGVvbmcgPGJvb24ubGVvbmcub25nQGlu
dGVsLmNvbT47IFZvb24sIFdlaWZlbmcNCj4gPj4gPHdlaWZlbmcudm9vbkBpbnRlbC5jb20+OyBs
YXJzLnBlcnNzb25AYXhpcy5jb207DQo+ID4+IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4
LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gPj4gU3ViamVjdDogUmU6IFtQQVRDSCB2Ml0gbmV0
OiBzdG1tYWM6IGJ1ZyBmaXggdG8gc3luY2hyb25pemUNCj4gPj4gc3RtbWFjX29wZW4gYW5kIHN0
bW1hY19kdnJfcHJvYmUNCj4gPj4NCj4gPj4gRnJvbTogIkt3ZWgsIEhvY2sgTGVvbmciCTxob2Nr
Lmxlb25nLmt3ZWhAaW50ZWwuY29tPg0KPiA+PiBEYXRlOiBUdWUsIDI3IERlYyAyMDE2IDIyOjQy
OjM2ICswODAwDQo+ID4+DQo+ID4+PiBGcm9tOiAiS3dlaCwgSG9jayBMZW9uZyIgPGhvY2subGVv
bmcua3dlaEBpbnRlbC5jb20+DQo+ID4+DQo+ID4+IFlvdSBhcmUgbm90IHRoZSBhdXRob3Igb2Yg
dGhpcyBjaGFuZ2UsIGRvIG5vdCB0YWtlIGNyZWRpdCBmb3IgaXQuDQo+ID4+DQo+ID4+IFlvdSBo
YXZlIGNvcGllZCBGbG9yaWFuJ3MgcGF0Y2ggY2hhcmFjdGVyIGJ5IGNoYXJhY3RlciwgdGhlcmVm
b3JlIGhlDQo+ID4+IGlzIHRoZSBhdXRob3IuDQo+ID4+DQo+ID4+IFlvdSBhbHNvIGRpZG4ndCBD
QzogdGhlIG5ldGRldiBtYWlsaW5nIGxpc3QgcHJvcGVybHkuDQo+ID4NCj4gPiBIaSBEYXZpZCAm
IEZsb3JpYW4sDQo+ID4NCj4gPiBKdXN0IHRvIGNsYXJpZnkgdGhhdCBJIGRvIG5vdCBjb3B5IGV4
YWN0bHkgZnJvbSBGbG9yaWFuLg0KPiA+IEkgaGF2ZSBjaGFuZ2VkIGl0IHRvIGhhdmUgcHJvcGVy
IGhhbmRsaW5nIG9uIG1kaW8gdW5yZWdpc3RlciB3aGlsZQ0KPiA+IG5ldGRldl9yZWdpc3Rlcigp
IGZhaWxlZCBhcyBzaG93ZWQgYmVsb3c6DQo+ID4NCj4gPiAJcmV0dXJuIDA7DQo+ID4NCj4gPiAt
ZXJyb3JfbWRpb19yZWdpc3RlcjoNCj4gPiAtCXVucmVnaXN0ZXJfbmV0ZGV2KG5kZXYpOw0KPiA+
ICBlcnJvcl9uZXRkZXZfcmVnaXN0ZXI6DQo+ID4gKwlzdG1tYWNfbWRpb191bnJlZ2lzdGVyKG5k
ZXYpOw0KPiANCj4gQWx0aG91Z2ggdGhpcyBpcyByZXF1aXJlZCwgd2UgY2FuJ3QgYmUgZG9pbmcg
aXQgaW4gYWxsIGNpcmN1bXN0YW5jZXMsIHdlIG5lZWQgdG8NCj4gbWltaWMgd2hhdCBzdG1tYWNf
ZHJ2X3JlbW92ZSgpIGRvZXMuDQo+IA0KPiBMZXQgbWUgc3VibWl0IGFuIGluY3JlbWVudGFsIGZp
eCB3aGljaCB0YWtlcyBjYXJlIG9mIG1kaW8gYnVzIHVucmVnaXN0cmF0aW9uLg0KPiAtLQ0KPiBG
bG9yaWFuDQoNCk5vdGVkICYgVGhhbmtzLiBXaWxsIHRlc3QgaXQgb3V0IG9uY2UgeW91IHN1Ym1p
dHRlZC4NCg0KVGhhbmtzICYgUmVnYXJkcywNCldpbHNvbg0KDQo=
