From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to
 unavailable interrupt
Date: Tue, 25 Apr 2017 16:26:25 -0400 (EDT)
Message-ID: <20170425.162625.941066354018174414.davem@davemloft.net>
References: <20170425.103644.75674234677063517.davem@davemloft.net>
        <B99ADC0E-A793-4334-A086-9F2CE045AB7E@gmail.com>
        <20170425200911.d7zfakqs5k5zwisg@piout.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: al.kochet@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
        rogerq@ti.com, madalin.bucur@nxp.com
To: alexandre.belloni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949636AbdDYU0s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 16:26:48 -0400
In-Reply-To: <20170425200911.d7zfakqs5k5zwisg@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZHJlIEJlbGxvbmkgPGFsZXhhbmRyZS5iZWxsb25pQGZyZWUtZWxlY3Ryb25z
LmNvbT4NCkRhdGU6IFR1ZSwgMjUgQXByIDIwMTcgMjI6MDk6MTEgKzAyMDANCg0KPiBIaSwNCj4g
DQo+IE9uIDI1LzA0LzIwMTcgYXQgMTg6MjU6MzAgKzAzMDAsIEFsZXhhbmRlciBLb2NoZXRrb3Yg
d3JvdGU6DQo+PiBIZWxsbyBEYXZpZCENCj4+IA0KPj4gPiAyNSDQsNC/0YAuIDIwMTcg0LMuLCDQ
siAxNzozNiwgRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiDQvdCw0L/QuNGB0LDQ
uyjQsCk6DQo+PiA+IA0KPj4gPiBTby4uLiB3aGF0IGFyZSB3ZSBkb2luZyBoZXJlPw0KPj4gPiAN
Cj4+ID4gTXkgdW5kZXJzdGFuZGluZyBpcyB0aGF0IHRoaXMgc2hvdWxkIGZpeCB0aGUgc2FtZSBw
cm9ibGVtIHRoYXQgY29tbWl0DQo+PiA+IDk5ZjgxYWZjMTM5YzZlZGQxNGQ3N2E5MWVlOTE2ODVh
NDE0YTFjNjYgKCJwaHk6IG1pY3JlbDogRGlzYWJsZSBhdXRvDQo+PiA+IG5lZ290aWF0aW9uIG9u
IHN0YXJ0dXAiKSBmaXhlZCBhbmQgdGhhdCB0aGlzIG1pY3JlbCBjb21taXQgc2hvdWxkIHRodXMN
Cj4+ID4gYmUgcmV2ZXJ0ZWQgdG8gaW1wcm92ZSBNQUMgc3RhcnR1cCB0aW1lcyB3aGljaCByZWdy
ZXNzZWQuDQo+PiA+IA0KPj4gPiBGbG9yaWFuLCBhbnkgZ3VpZGFuY2U/DQo+PiANCj4+IFllcywg
dGhpcyBzaG91bGQgYmUgZG9uZS4NCj4+IA0KPj4gSSBha3NlZCBBbGV4YW5kcmUgdG8gY2hlY2sg
aWYgOTlmODFhZmMxMzljNmVkZDE0ZDc3YTkxZWU5MTY4NWE0MTRhMWM2NiAoInBoeTogbWljcmVs
OiBEaXNhYmxlIGF1dG8NCj4+IG5lZ290aWF0aW9uIG9uIHN0YXJ0dXDCuykgY2FuIGJlIHJldmVy
dGVkLCBhbmQgaGUgYW5zd2VyZWQgd2hhdCBpdCBtYXkgZG8gdGhhdA0KPj4gc29tZXRpbWUgdGhp
cy9uZXh0IHdlZWsuDQo+PiANCj4gDQo+IFllcywgaXQgY2FuIGJlIHNhZmVseSByZXZlcnRlZCBh
ZnRlciBBbGV4YW5kZXIncyBwYXRjaC4gSSBoYWQgdG8gdGVzdCBvbg0KPiB2NC43IGJlY2F1c2Ug
d2UgYXJlIG5vdCB1c2luZyBpbnRlcnJ1cHRzIG9uIHRob3NlIGJvYXJkcyBzaW5jZSB2NC44DQo+
IChhbm90aGVyIGlzc3VlIHRvIGJlIGZpeGVkKS4NCj4gDQo+IEFzIEZsb3JpYW4gcG9pbnRlZCBv
dXQsIGF0IHRoZSB0aW1lIEkgc2VudCBteSBwYXRjaCwgSSBkaWRuJ3QgaGF2ZSB0aW1lDQo+IHRv
IGludmVzdGlnYXRlIHdoZXRoZXIgdGhpcyB3YXMgYWZmZWN0aW5nIG90aGVyIHBoeXMsIHNlZQ0K
PiBodHRwczovL2xrbWwub3JnL2xrbWwvMjAxNi8yLzI2Lzc2Ng0KPiANCj4gSSBjYW4gc2VuZCB0
aGUgcmV2ZXJ0IG9yIHlvdSBjYW4gZG8gaXQuDQoNCkkgY2FuIHRha2UgY2FyZSBvZiBpdCwgdGhh
bmtzIGZvciB0ZXN0aW5nLg0K
