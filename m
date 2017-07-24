From: "liujian (CE)" <liujian56@huawei.com>
Subject: RE: af_packet: use after free in prb_retire_rx_blk_timer_expired
Date: Mon, 24 Jul 2017 10:29:59 +0000
Message-ID: <4F88C5DDA1E80143B232E89585ACE27D018CDC49@DGGEMA502-MBS.china.huawei.com>
References: <20170410190350.ngfw435zzr7gpw7e@sasha-lappy>
 <20170410192309.35x7ddya2cyyv4y6@codemonkey.org.uk>
 <CAF=yD-+MiyTvC=F=ApyF=+bCUgWWDT_4dTxPXsGRziuVTqQSiw@mail.gmail.com>
 <4F88C5DDA1E80143B232E89585ACE27D018C33F1@DGGEMA502-MBX.china.huawei.com>
 <CAM_iQpWHfUZGpf6dzT2kJ3fgtAiMeGbuwKYQ5ekGMxEOzm7ihQ@mail.gmail.com>
 <aa4874ba-3eaf-bf19-ea60-c7b76a972833@huawei.com>
 <CAM_iQpXdyNeeojLfh0ZPMy1LQwOoQZfV7Az2=Q5WALM00Za9SA@mail.gmail.com>
 <4F88C5DDA1E80143B232E89585ACE27D018CB6E0@DGGEMA502-MBS.china.huawei.com>
 <CAM_iQpXJZwFC3gG40UpCvt9GTcJ+ETaCKRvN7A=z7NB2CVtPRA@mail.gmail.com>
 <8f6c2fec-0ac4-1414-69da-462114a4481f@huawei.com>
 <b1e9ee12-1f81-28ea-e872-d1133ce37288@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        "alexander.levin@verizon.com" <alexander.levin@verizon.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dingtianhong <dingtianhong@huawei.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:9408 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752799AbdGXKkM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 06:40:12 -0400
In-Reply-To: <b1e9ee12-1f81-28ea-e872-d1133ce37288@huawei.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgV2FuZyBjb25nLA0KDQpBZnRlciBhcHBseSB0aGUgcGF0Y2gsIEkgZGlkIG5vdCBoaXQgdGhl
IGlzc3VlIGFnYWluLg0KVGhhbmsgeW91fg0KDQoNCkJlc3QgUmVnYXJkcywNCmxpdWppYW4NCg0K
PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBEaW5ndGlhbmhvbmcNCj4gU2Vu
dDogTW9uZGF5LCBKdWx5IDI0LCAyMDE3IDk6MjkgQU0NCj4gVG86IENvbmcgV2FuZzsgbGl1amlh
biAoQ0UpDQo+IENjOiBXaWxsZW0gZGUgQnJ1aWpuOyBEYXZlIEpvbmVzOyBhbGV4YW5kZXIubGV2
aW5AdmVyaXpvbi5jb207DQo+IGRhdmVtQGRhdmVtbG9mdC5uZXQ7IGVkdW1hemV0QGdvb2dsZS5j
b207IHdpbGxlbWJAZ29vZ2xlLmNvbTsNCj4gZGFuaWVsQGlvZ2VhcmJveC5uZXQ7IG5ldGRldkB2
Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDog
UmU6IGFmX3BhY2tldDogdXNlIGFmdGVyIGZyZWUgaW4gcHJiX3JldGlyZV9yeF9ibGtfdGltZXJf
ZXhwaXJlZA0KPiANCj4gDQo+IA0KPiBPbiAyMDE3LzcvMjQgOTowOSwgRGluZyBUaWFuaG9uZyB3
cm90ZToNCj4gPg0KPiA+DQo+ID4gT24gMjAxNy83LzI0IDE6MDMsIENvbmcgV2FuZyB3cm90ZToN
Cj4gPj4gT24gU3VuLCBKdWwgMjMsIDIwMTcgYXQgNTo0OCBBTSwgbGl1amlhbiAoQ0UpIDxsaXVq
aWFuNTZAaHVhd2VpLmNvbT4gd3JvdGU6DQo+ID4+PiBIaQ0KPiA+Pj4NCj4gPj4+IEkgZmluZCBp
dCBjYXVzZWQgYnkgYmVsb3cgc3RlcHM6DQo+ID4+PiAxLiBzZXQgdHBfdmVyc2lvbiB0byBUUEFD
S0VUX1YzIGFuZCByZXEtPnRwX2Jsb2NrX25yIHRvIDEgMi4gc2V0DQo+ID4+PiB0cF9ibG9ja19u
ciB0byAwIFRoZW4gcGdfdmVjIHdhcyBmcmVlZCwgYW5kIHdlIGRpZCBub3QgZGVsZXRlIHRoZQ0K
PiA+Pj4gdGltZXI/DQo+ID4+DQo+ID4+IFRoYW5rcyBmb3IgdGVzdGluZyENCj4gPj4NCj4gPj4g
QWgsIEkgb3Zlcmxvb2sgdGhlIGluaXRpYWxpemF0aW9uIGNhc2UgaW4gbXkgcHJldmlvdXMgcGF0
Y2guDQo+ID4+DQo+ID4+IEhvdyBhYm91dCB0aGUgZm9sbG93aW5nIG9uZT8gRG9lcyBpdCBjb3Zl
ciBhbGwgdGhlIGNhc2VzPw0KPiA+Pg0KPiA+Pg0KPiA+PiBkaWZmIC0tZ2l0IGEvbmV0L3BhY2tl
dC9hZl9wYWNrZXQuYyBiL25ldC9wYWNrZXQvYWZfcGFja2V0LmMgaW5kZXgNCj4gPj4gMDA4YmIz
NGVlMzI0Li4wNjE1YzJhOTUwZmEgMTAwNjQ0DQo+ID4+IC0tLSBhL25ldC9wYWNrZXQvYWZfcGFj
a2V0LmMNCj4gPj4gKysrIGIvbmV0L3BhY2tldC9hZl9wYWNrZXQuYw0KPiA+PiBAQCAtNDMyOSw3
ICs0MzI5LDcgQEAgc3RhdGljIGludCBwYWNrZXRfc2V0X3Jpbmcoc3RydWN0IHNvY2sgKnNrLA0K
PiA+PiB1bmlvbiB0cGFja2V0X3JlcV91ICpyZXFfdSwNCj4gPj4gICAgICAgICAgICAgICAgIHJl
Z2lzdGVyX3Byb3RfaG9vayhzayk7DQo+ID4+ICAgICAgICAgfQ0KPiA+PiAgICAgICAgIHNwaW5f
dW5sb2NrKCZwby0+YmluZF9sb2NrKTsNCj4gPj4gLSAgICAgICBpZiAoY2xvc2luZyAmJiAocG8t
PnRwX3ZlcnNpb24gPiBUUEFDS0VUX1YyKSkgew0KPiA+PiArICAgICAgIGlmIChwZ192ZWMgJiYg
KHBvLT50cF92ZXJzaW9uID4gVFBBQ0tFVF9WMikpIHsNCj4gPj4gICAgICAgICAgICAgICAgIC8q
IEJlY2F1c2Ugd2UgZG9uJ3Qgc3VwcG9ydCBibG9jay1iYXNlZCBWMyBvbiB0eC1yaW5nDQo+ICov
DQo+ID4+ICAgICAgICAgICAgICAgICBpZiAoIXR4X3JpbmcpDQo+ID4+ICAgICAgICAgICAgICAg
ICAgICAgICAgIHByYl9zaHV0ZG93bl9yZXRpcmVfYmxrX3RpbWVyKHBvLA0KPiByYl9xdWV1ZSk7
DQo+ID4+DQo+ID4+IC4NCj4gPg0KPiA+IEhpLCBDb25nOg0KPiA+DQo+ID4gSXQgbG9va3MgbGlr
ZSBjb3VsZCBub3QgY292ZXIgdGhlIGNhc2U6IHJlcS0+dHBfYmxvY2tfbnIgPSAyIC0+DQo+IHJl
Zy0+dHBfYmxvY2tfbnIgPSAxIC4NCj4gPg0KPiANCj4gT2gsIGxvb2tzIGxpa2UgdGhpcyBjYXNl
IHdvdWxkIG5ldmVyIGhhcHBlbiwgc28gSSB0aGluayB5b3VyIHNvbHV0aW9uIGlzIG9rLg0KPiAN
Cj4gPiB3aGF0IGFib3V0IHRoaXMgd2F5Og0KPiA+IC0tLSBhL25ldC9wYWNrZXQvYWZfcGFja2V0
LmMNCj4gPiArKysgYi9uZXQvcGFja2V0L2FmX3BhY2tldC5jDQo+ID4gQEAgLTQzMzEsMTMgKzQz
MzEsMTcgQEAgc3RhdGljIGludCBwYWNrZXRfc2V0X3Jpbmcoc3RydWN0IHNvY2sgKnNrLCB1bmlv
bg0KPiB0cGFja2V0X3JlcV91ICpyZXFfdSwNCj4gPiAgICAgICAgICAgICAgICAgcmVnaXN0ZXJf
cHJvdF9ob29rKHNrKTsNCj4gPiAgICAgICAgIH0NCj4gPiAgICAgICAgIHNwaW5fdW5sb2NrKCZw
by0+YmluZF9sb2NrKTsNCj4gPiAtICAgICAgIGlmIChjbG9zaW5nICYmIChwby0+dHBfdmVyc2lv
biA+IFRQQUNLRVRfVjIpKSB7DQo+ID4gKyAgICAgICBpZiAoKGNsb3NpbmcgfHwgKHBnX3ZlYyAm
JiAhcmVnLT50cF9ibG9ja19ucikpJiYNCj4gPiArIChwby0+dHBfdmVyc2lvbiA+IFRQQUNLRVRf
VjIpKSB7DQo+ID4gICAgICAgICAgICAgICAgIC8qIEJlY2F1c2Ugd2UgZG9uJ3Qgc3VwcG9ydCBi
bG9jay1iYXNlZCBWMyBvbiB0eC1yaW5nICovDQo+ID4gICAgICAgICAgICAgICAgIGlmICghdHhf
cmluZykNCj4gPiAgICAgICAgICAgICAgICAgICAgICAgICBwcmJfc2h1dGRvd25fcmV0aXJlX2Js
a190aW1lcihwbywNCj4gcmJfcXVldWUpOw0KPiA+DQo+ID4NCj4gDQo+ID4+DQo+ID4NCj4gPg0K
PiA+IC4NCj4gPg0KDQo=
