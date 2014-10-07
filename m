From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 7 Oct 2014 14:23:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C60B1@AcuExch.aculab.com>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	<063D6719AE5E284EB5DD2968C1650D6D174C6025@AcuExch.aculab.com>
 <20141007161702.7cd1e800@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?utf-8?B?J0xvdGhhciBXYcOfbWFubic=?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49851 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752904AbaJGOYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 10:24:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28820-07 for <netdev@vger.kernel.org>;
 Tue,  7 Oct 2014 15:24:23 +0100 (BST)
In-Reply-To: <20141007161702.7cd1e800@ipc1.ka-ro>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTG90aGFyDQo+IERhdmlkIExhaWdodCB3cm90ZToNCj4gPiBGcm9tOiBMb3RoYXIgV2HD
n21hbm4NCj4gPiA+IGNvbW1pdCAxYjdiZGU2ZDY1OWQgKCJuZXQ6IGZlYzogaW1wbGVtZW50IHJ4
X2NvcHlicmVhayB0byBpbXByb3ZlIHJ4IHBlcmZvcm1hbmNlIikNCj4gPiA+IGludHJvZHVjZWQg
YSByZWdyZXNzaW9uIGZvciBpLk1YMjguIFRoZSBzd2FwX2J1ZmZlcigpIGZ1bmN0aW9uIGRvaW5n
DQo+ID4gPiB0aGUgZW5kaWFuIGNvbnZlcnNpb24gb2YgdGhlIHJlY2VpdmVkIGRhdGEgb24gaS5N
WDI4IG1heSBhY2Nlc3MgbWVtb3J5DQo+ID4gPiBiZXlvbmQgdGhlIGFjdHVhbCBwYWNrZXQgc2l6
ZSBpbiB0aGUgRE1BIGJ1ZmZlci4gZmVjX2VuZXRfY29weWJyZWFrKCkNCj4gPiA+IGRvZXMgbm90
IGNvcHkgdGhvc2UgYnl0ZXMsIHNvIHRoYXQgdGhlIGxhc3QgYnl0ZXMgb2YgYSBwYWNrZXQgbWF5
IGJlDQo+ID4gPiBmaWxsZWQgd2l0aCBpbnZhbGlkIGRhdGEgYWZ0ZXIgc3dhcHBpbmcuDQo+ID4g
PiBUaGlzIHdpbGwgbGlrZWx5IGxlYWQgdG8gY2hlY2tzdW0gZXJyb3JzIG9uIHJlY2VpdmVkIHBh
Y2tldHMuDQo+ID4gPiBFLmcuIHdoZW4gdHJ5aW5nIHRvIG1vdW50IGFuIE5GUyByb290ZnM6DQo+
ID4gPiBVRFA6IGJhZCBjaGVja3N1bS4gRnJvbSAxOTIuMTY4LjEuMjI1OjExMSB0byAxOTIuMTY4
LjEwMC43Mzo0NDY2MiB1bGVuIDM2DQo+ID4gPg0KPiA+ID4gRG8gdGhlIGJ5dGUgc3dhcHBpbmcg
YW5kIGNvcHlpbmcgdG8gdGhlIG5ldyBza2IgaW4gb25lIGdvIGlmDQo+ID4gPiBuZWNlc3Nhcnku
DQo+ID4NCj4gPiBJU1RNIHRoYXQgaWYgeW91IG5lZWQgdG8gZG8gdGhlICdzd2FwJyB5b3Ugc2hv
dWxkIGNvcHkgdGhlIGRhdGEgcmVnYXJkbGVzcw0KPiA+IG9mIHRoZSBsZW5ndGguDQo+ID4NCj4g
VGhlIHN3YXAgZnVuY3Rpb24gaGFzIHRvIGxvb2sgYXQgYXQgbW9zdCAzIGJ5dGVzIGJleW9uZCB0
aGUgYWN0dWFsDQo+IHBhY2tldCBsZW5ndGguIFRoYXQgaXMgd2hhdCB0aGUgb3JpZ2luYWwgc3dh
cF9idWZmZXIoKSBmdW5jdGlvbiBkb2VzIGFuZA0KPiB3aGF0IHRoZSBuZXcgZnVuY3Rpb24gc3dh
cF9idWZmZXIyKCksIHRoYXQgZG9lcyB0aGUgZW5kaWFuIHN3YXBwaW5nDQo+IHdoaWxlIGNvcHlp
bmcgdG8gdGhlIG5ldyBidWZmZXIsIGFsc28gZG9lcy4NCg0KSSB1bmRlcnN0b29kIHRoZSBidWcu
DQoNClRoZSBwb2ludCBJIHdhcyBtYWtpbmcgaXMgdGhhdCBpZiB5b3UgaGF2ZSB0byBkbyBhIHJl
YWQtd3JpdGUgb2YgdGhlIHJlY2VpdmVkDQpkYXRhICh0byBieXRlc3dhcCBpdCkgdGhlbiB5b3Ug
bWlnaHQgYXMgd2VsbCBhbHdheXMgY29weSBpdCBpbnRvIGEgbmV3IHNrYiB0aGF0DQppcyBqdXN0
IGJpZyBlbm91Z2ggZm9yIHRoZSBhY3R1YWwgcmVjZWl2ZSBmcmFtZS4NCg0KCURhdmlkDQoNCg==
