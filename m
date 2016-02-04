From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 17:09:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD6923@AcuExch.aculab.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
	<CAKgT0UcuJWmpwO4hu34qBWhrhqQ5GQMU_dWHF-Dd10+Y9aCH=g@mail.gmail.com>
 <CALx6S35X08W3ugsc0w_0RT6XdHOH_SF5g2u1z2yvhXL_uvDmNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Tom Herbert' <tom@herbertland.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:58422 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbcBDRNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 12:13:19 -0500
In-Reply-To: <CALx6S35X08W3ugsc0w_0RT6XdHOH_SF5g2u1z2yvhXL_uvDmNw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIEhlcmJlcnQNCi4uLg0KPiA+IElmIG5vdGhpbmcgZWxzZSByZWR1Y2luZyB0aGUg
c2l6ZSBvZiB0aGlzIG1haW4gbG9vcCBtYXkgYmUgZGVzaXJhYmxlLg0KPiA+IEkga25vdyB0aGUg
bmV3ZXIgeDg2IGlzIHN1cHBvc2VkIHRvIGhhdmUgYSBsb29wIGJ1ZmZlciBzbyB0aGF0IGl0IGNh
bg0KPiA+IGJhc2ljYWxseSBsb29wIG9uIGFscmVhZHkgZGVjb2RlZCBpbnN0cnVjdGlvbnMuICBO
b3JtYWxseSBpdCBpcyBvbmx5DQo+ID4gc29tZXRoaW5nIGxpa2UgNjQgb3IgMTI4IGJ5dGVzIGlu
IHNpemUgdGhvdWdoLiAgWW91IG1pZ2h0IGZpbmQgdGhhdA0KPiA+IHJlZHVjaW5nIHRoaXMgbG9v
cCB0byB0aGF0IHNtYWxsZXIgc2l6ZSBtYXkgaW1wcm92ZSB0aGUgcGVyZm9ybWFuY2UNCj4gPiBm
b3IgbGFyZ2VyIHBheWxvYWRzLg0KPg0KPiBJIHNhdyAxMjggdG8gYmUgYmV0dGVyIGluIG15IHRl
c3RpbmcuIEZvciBsYXJnZSBwYWNrZXRzIHRoaXMgbG9vcCBkb2VzDQo+IGFsbCB0aGUgd29yay4g
SSBzZWUgcGVyZm9ybWFuY2UgZGVwZW5kZW50IG9uIHRoZSBhbW91bnQgb2YgbG9vcA0KPiBvdmVy
aGVhZCwgaS5lLiB3ZSBnb3QgaXQgZG93biB0byB0d28gbm9uLWFkY3EgaW5zdHJ1Y3Rpb25zIGJ1
dCBpdCBpcw0KPiBzdGlsbCBub3RpY2VhYmxlLiBBbHNvLCB0aGlzIGhlbHBzIGEgbG90IG9uIHNp
emVzIHVwIHRvIDEyOCBieXRlcw0KPiBzaW5jZSB3ZSBvbmx5IG5lZWQgdG8gZG8gc2luZ2xlIGNh
bGwgaW4gdGhlIGp1bXAgdGFibGUgYW5kIG5vIHRyaXANCj4gdGhyb3VnaCB0aGUgbG9vcC4NCg0K
QnV0IG9uZSBvZiB5b3VyICdsb29wIG92ZXJoZWFkJyBpbnN0cnVjdGlvbnMgaXMgJ2xvb3AnLg0K
TG9vayBhdCBodHRwOi8vd3d3LmFnbmVyLm9yZy9vcHRpbWl6ZS9pbnN0cnVjdGlvbl90YWJsZXMu
cGRmDQp5b3UgZG9uJ3Qgd2FudCB0byBiZSB1c2luZyAnbG9vcCcgb24gaW50ZWwgY3B1cy4NCg0K
WW91IG1pZ2h0IGdldCBzb21lIGJlbmVmaXQgZnJvbSBwaXBlbGluaW5nIHRoZSBsb29wIChzbyB5
b3UgZG8NCmEgcmVhZCB0byByZWdpc3RlciBpbiBvbmUgaXRlcmF0aW9uIGFuZCBhIHJlZ2lzdGVy
LXJlZ2lzdGVyIGFkYw0KdGhlIG5leHQpLg0KDQoJRGF2aWQNCg0K
