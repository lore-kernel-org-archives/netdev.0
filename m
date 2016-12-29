From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
 stmmac_dvr_probe
Date: Thu, 29 Dec 2016 00:26:44 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A916EA5@PGSMSX102.gar.corp.intel.com>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
 <20161227.113405.362102687632949941.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
 <CAJ3s=NAzfUSCnxxZph5j6Vk2T=pw2F9U3FLP7dOKRp21mmQvcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kishan Sandeep <sandeepkishan108@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3s=NAzfUSCnxxZph5j6Vk2T=pw2F9U3FLP7dOKRp21mmQvcg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBLaXNoYW4gU2FuZGVlcCBbbWFp
bHRvOnNhbmRlZXBraXNoYW4xMDhAZ21haWwuY29tXQ0KPiBTZW50OiBXZWRuZXNkYXksIERlY2Vt
YmVyIDI4LCAyMDE2IDc6NTYgUE0NCj4gVG86IEt3ZWgsIEhvY2sgTGVvbmcgPGhvY2subGVvbmcu
a3dlaEBpbnRlbC5jb20+DQo+IENjOiBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+
OyBmLmZhaW5lbGxpQGdtYWlsLmNvbTsNCj4gSm9hby5QaW50b0BzeW5vcHN5cy5jb207IHBlcHBl
LmNhdmFsbGFyb0BzdC5jb207DQo+IHNlcmFwaGluLmJvbm5hZmZlQHN0LmNvbTsgYWxleGFuZHJl
LnRvcmd1ZUBnbWFpbC5jb207DQo+IG1hbmFiaWFuQGdtYWlsLmNvbTsgbmlrbGFzLmNhc3NlbEBh
eGlzLmNvbTsgam9oYW5Aa2VybmVsLm9yZzsNCj4gcGF2ZWxAdWN3LmN6OyBsYXJzLnBlcnNzb25A
YXhpcy5jb207IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LQ0KPiBrZXJuZWxAdmdlci5r
ZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggdjJdIG5ldDogc3RtbWFjOiBidWcgZml4
IHRvIHN5bmNocm9uaXplIHN0bW1hY19vcGVuIGFuZA0KPiBzdG1tYWNfZHZyX3Byb2JlDQo+IA0K
PiBPbiBXZWQsIERlYyAyOCwgMjAxNiBhdCA3OjEwIEFNLCBLd2VoLCBIb2NrIExlb25nDQo+IDxo
b2NrLmxlb25nLmt3ZWhAaW50ZWwuY29tPiB3cm90ZToNCj4gPj4gLS0tLS1PcmlnaW5hbCBNZXNz
YWdlLS0tLS0NCj4gPj4gRnJvbTogRGF2aWQgTWlsbGVyIFttYWlsdG86ZGF2ZW1AZGF2ZW1sb2Z0
Lm5ldF0NCj4gPj4gU2VudDogV2VkbmVzZGF5LCBEZWNlbWJlciAyOCwgMjAxNiAxMjozNCBBTQ0K
PiA+PiBUbzogS3dlaCwgSG9jayBMZW9uZyA8aG9jay5sZW9uZy5rd2VoQGludGVsLmNvbT4NCj4g
Pj4gQ2M6IEpvYW8uUGludG9Ac3lub3BzeXMuY29tOyBwZXBwZS5jYXZhbGxhcm9Ac3QuY29tOw0K
PiA+PiBzZXJhcGhpbi5ib25uYWZmZUBzdC5jb207IGYuZmFpbmVsbGlAZ21haWwuY29tOw0KPiA+
PiBhbGV4YW5kcmUudG9yZ3VlQGdtYWlsLmNvbTsgbWFuYWJpYW5AZ21haWwuY29tOw0KPiA+PiBu
aWtsYXMuY2Fzc2VsQGF4aXMuY29tOyBqb2hhbkBrZXJuZWwub3JnOyBwYXZlbEB1Y3cuY3o7IE9u
ZywgQm9vbg0KPiA+PiBMZW9uZyA8Ym9vbi5sZW9uZy5vbmdAaW50ZWwuY29tPjsgVm9vbiwgV2Vp
ZmVuZw0KPiA+PiA8d2VpZmVuZy52b29uQGludGVsLmNvbT47IGxhcnMucGVyc3NvbkBheGlzLmNv
bTsNCj4gPj4gbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVs
Lm9yZw0KPiA+PiBTdWJqZWN0OiBSZTogW1BBVENIIHYyXSBuZXQ6IHN0bW1hYzogYnVnIGZpeCB0
byBzeW5jaHJvbml6ZQ0KPiA+PiBzdG1tYWNfb3BlbiBhbmQgc3RtbWFjX2R2cl9wcm9iZQ0KPiA+
Pg0KPiA+PiBGcm9tOiAiS3dlaCwgSG9jayBMZW9uZyIgICAgICA8aG9jay5sZW9uZy5rd2VoQGlu
dGVsLmNvbT4NCj4gPj4gRGF0ZTogVHVlLCAyNyBEZWMgMjAxNiAyMjo0MjozNiArMDgwMA0KPiA+
Pg0KPiA+PiA+IEZyb206ICJLd2VoLCBIb2NrIExlb25nIiA8aG9jay5sZW9uZy5rd2VoQGludGVs
LmNvbT4NCj4gPj4NCj4gPj4gWW91IGFyZSBub3QgdGhlIGF1dGhvciBvZiB0aGlzIGNoYW5nZSwg
ZG8gbm90IHRha2UgY3JlZGl0IGZvciBpdC4NCj4gPj4NCj4gPj4gWW91IGhhdmUgY29waWVkIEZs
b3JpYW4ncyBwYXRjaCBjaGFyYWN0ZXIgYnkgY2hhcmFjdGVyLCB0aGVyZWZvcmUgaGUNCj4gPj4g
aXMgdGhlIGF1dGhvci4NCj4gPj4NCj4gPj4gWW91IGFsc28gZGlkbid0IENDOiB0aGUgbmV0ZGV2
IG1haWxpbmcgbGlzdCBwcm9wZXJseS4NCj4gPg0KPiA+IE5vdGVkICYgVGhhbmtzLg0KPiA+DQo+
ID4gSGkgRmxvcmlhbiwgY291bGQgeW91IHN1Ym1pdCB0aGlzIGZpeCBmcm9tIHlvdXIgc2lkZSBz
byB0aGF0IHlvdSBhcmUgdGhlIGF1dGhvci4NCj4gPiBJIHdpbGwgaGVscCB0byB0ZXN0IG91dC4N
Cj4gPg0KPiA+IFRoYW5rcyAmIFJlZ2FyZHMsDQo+ID4gV2lsc29uDQo+ID4NCj4gSSB0aGluayB5
b3UgY2FuIGdpdmUgKi0tYXV0aG9yKiBmb3IgZ2l2aW5nIGF1dGhvciBuYW1lLiBUcnkgZ2l0IGNv
bW1pdCAtYW0NCj4gImNvbW1pdCBtZXNzYWdlIiAtLWF1dGhvcj0iQXV0aG9yX25hbWUgPGF1dGhv
cl9lbWFpbD4iDQoNCk9oIC4uLiBJIGFtIG5vdCBhd2FyZSBvZiB0aGF0LiBUaGFua3MgZm9yIGlu
Zm9ybWluZy4gDQo6LSkNCg0KUmVnYXJkcywNCldpbHNvbg0K
