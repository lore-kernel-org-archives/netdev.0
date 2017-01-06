From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] net: stmmac: fix maxmtu assignment to be within valid
 range
Date: Fri, 6 Jan 2017 01:59:23 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A9186FA@PGSMSX102.gar.corp.intel.com>
References: <1483613277-6005-1-git-send-email-hock.leong.kweh@intel.com>
 <CAHp75Ve6c4W-eqWdqabX5Q5cX4SpqmxByb6=TKnrr1yodkoPkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        Jarod Wilson <jarod@redhat.com>,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        "Joachim Eastwood" <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16575 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753741AbdAFB7a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 20:59:30 -0500
In-Reply-To: <CAHp75Ve6c4W-eqWdqabX5Q5cX4SpqmxByb6=TKnrr1yodkoPkw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBbmR5IFNoZXZjaGVua28gW21h
aWx0bzphbmR5LnNoZXZjaGVua29AZ21haWwuY29tXQ0KPiBTZW50OiBGcmlkYXksIEphbnVhcnkg
MDYsIDIwMTcgNTowNyBBTQ0KPiBUbzogS3dlaCwgSG9jayBMZW9uZyA8aG9jay5sZW9uZy5rd2Vo
QGludGVsLmNvbT4NCj4gQ2M6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47
IEpvYW8gUGludG8NCj4gPEpvYW8uUGludG9Ac3lub3BzeXMuY29tPjsgR2l1c2VwcGUgQ0FWQUxM
QVJPIDxwZXBwZS5jYXZhbGxhcm9Ac3QuY29tPjsNCj4gc2VyYXBoaW4uYm9ubmFmZmVAc3QuY29t
OyBKYXJvZCBXaWxzb24gPGphcm9kQHJlZGhhdC5jb20+OyBBbGV4YW5kcmUNCj4gVE9SR1VFIDxh
bGV4YW5kcmUudG9yZ3VlQGdtYWlsLmNvbT47IEpvYWNoaW0gRWFzdHdvb2QNCj4gPG1hbmFiaWFu
QGdtYWlsLmNvbT47IE5pa2xhcyBDYXNzZWwgPG5pa2xhcy5jYXNzZWxAYXhpcy5jb20+OyBKb2hh
biBIb3ZvbGQNCj4gPGpvaGFuQGtlcm5lbC5vcmc+OyBQYXZlbCBNYWNoZWsgPHBhdmVsQHVjdy5j
ej47IGxhcnMucGVyc3NvbkBheGlzLmNvbTsNCj4gbmV0ZGV2IDxuZXRkZXZAdmdlci5rZXJuZWwu
b3JnPjsgTEtNTCA8bGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZz4NCj4gU3ViamVjdDogUmU6
IFtQQVRDSF0gbmV0OiBzdG1tYWM6IGZpeCBtYXhtdHUgYXNzaWdubWVudCB0byBiZSB3aXRoaW4g
dmFsaWQNCj4gcmFuZ2UNCj4gDQo+IE9uIFRodSwgSmFuIDUsIDIwMTcgYXQgMTI6NDcgUE0sIEt3
ZWgsIEhvY2sgTGVvbmcNCj4gPGhvY2subGVvbmcua3dlaEBpbnRlbC5jb20+IHdyb3RlOg0KPiA+
IEZyb206ICJLd2VoLCBIb2NrIExlb25nIiA8aG9jay5sZW9uZy5rd2VoQGludGVsLmNvbT4NCj4g
Pg0KPiA+IFRoZXJlIGlzIG5vIGNoZWNraW5nIHZhbGlkIHZhbHVlIG9mIG1heG10dSB3aGVuIGdl
dHRpbmcgaXQgZnJvbSBkZXZpY2V0cmVlLg0KPiANCj4gJ0RldmljZSBUcmVlJyBvciAnZGV2aWNl
IHRyZWUnID8NCg0KTm90ZWQgJiBUaGFua3MuIFN1Ym1pdHRpbmcgVjIuDQoNCj4gDQo+ID4gVGhp
cyByZXNvbHV0aW9uIGFkZGVkIHRoZSBjaGVja2luZyBjb25kaXRpb24gdG8gZW5zdXJlIHRoZSBh
c3NpZ25tZW50DQo+ID4gaXMgbWFkZSB3aXRoaW4gYSB2YWxpZCByYW5nZS4NCj4gDQo+ID4gZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL3N0bW1hY19tYWlu
LmMNCj4gPiBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL3N0bW1hY19tYWlu
LmMNCj4gPiBpbmRleCAzOWViN2E2Li42ODNkNTlmIDEwMDY0NA0KPiA+IC0tLSBhL2RyaXZlcnMv
bmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL3N0bW1hY19tYWluLmMNCj4gPiArKysgYi9kcml2
ZXJzL25ldC9ldGhlcm5ldC9zdG1pY3JvL3N0bW1hYy9zdG1tYWNfbWFpbi5jDQo+ID4gQEAgLTMz
MTksNyArMzMxOSw4IEBAIGludCBzdG1tYWNfZHZyX3Byb2JlKHN0cnVjdCBkZXZpY2UgKmRldmlj
ZSwNCj4gPiAgICAgICAgICAgICAgICAgbmRldi0+bWF4X210dSA9IEpVTUJPX0xFTjsNCj4gPiAg
ICAgICAgIGVsc2UNCj4gPiAgICAgICAgICAgICAgICAgbmRldi0+bWF4X210dSA9IFNLQl9NQVhf
SEVBRChORVRfU0tCX1BBRCArIE5FVF9JUF9BTElHTik7DQo+ID4gLSAgICAgICBpZiAocHJpdi0+
cGxhdC0+bWF4bXR1IDwgbmRldi0+bWF4X210dSkNCj4gPiArICAgICAgIGlmICgocHJpdi0+cGxh
dC0+bWF4bXR1IDwgbmRldi0+bWF4X210dSkgJiYNCj4gPiArICAgICAgICAgICAocHJpdi0+cGxh
dC0+bWF4bXR1ID49IG5kZXYtPm1pbl9tdHUpKQ0KPiA+ICAgICAgICAgICAgICAgICBuZGV2LT5t
YXhfbXR1ID0gcHJpdi0+cGxhdC0+bWF4bXR1Ow0KPiANCj4gUGVyaGFwcyBhZGQgYSB3YXJuaW5n
IG1lc3NhZ2Ugb24gZWxzZSBicmFuY2g/DQoNCk5vdGVkICYgVGhhbmtzLiBTdWJtaXR0aW5nIFYy
Lg0KDQo+IA0KPiAtLQ0KPiBXaXRoIEJlc3QgUmVnYXJkcywNCj4gQW5keSBTaGV2Y2hlbmtvDQo=
