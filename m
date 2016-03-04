From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 4 Mar 2016 10:38:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
 <CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Linus Torvalds' <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:62683 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759223AbcCDKlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:41:18 -0500
In-Reply-To: <CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTGludXMgVG9ydmFsZHMNCj4gU2VudDogMDMgTWFyY2ggMjAxNiAxODo0NA0KPiANCj4g
T24gVGh1LCBNYXIgMywgMjAxNiBhdCA4OjEyIEFNLCBEYXZpZCBMYWlnaHQgPERhdmlkLkxhaWdo
dEBhY3VsYWIuY29tPiB3cm90ZToNCj4gPg0KPiA+IERpZCB5b3UgdHJ5IHRoZSBhc20gbG9vcCB0
aGF0IHVzZWQgJ2xlYXggJXJjeC4uLiwgamN4ei4uLiBqbXBzLi4nDQo+ID4gd2l0aG91dCBhbnkg
dW5yb2xsaW5nPw0KPiANCj4gSXMgdGhhdCBhY3R1YWxseSBzdXBwb3NlZCB0byB3b3JrIG9rIHRo
ZXNlIGRheXM/IGpjeHogdXNlZCB0byBiZSBxdWl0ZQ0KPiBzbG93LCBhbmQgaXMgaGlzdG9yaWNh
bGx5ICpuZXZlciogdXNlZC4NCj4gDQo+IE5vdywgaW4gdGhlb3J5LCBsb29wIGNvbnN0cnVjdHMg
Y2FuIGFjdHVhbGx5IGRvIGJldHRlciBvbiBicmFuY2gNCj4gcHJlZGljdGlvbiBldGMsIGJ1dCBJ
bnRlbCBzZWVtcyB0byBoYXZlIG5ldmVyIHJlYWxseSB0cmllZCB0byBwdXNoDQo+IHRoZW0sIGFu
ZCBoYXMgaW5zdGVhZCBwcmV0dHkgbXVjaCBkaXNjb3VyYWdlZCB0aGVtIGluIGZhdm9yIG9mIG1h
a2luZw0KPiB0aGUgbm9ybWFsIGp1bXBzIGdvIGZhc3RlciAoaW5jbHVkaW5nIGFsbCB0aGUgaW5z
dHJ1Y3Rpb24gZnVzaW9uIGV0YykNCg0KWWVzLCB0aGV5J3ZlIGV2ZW4gYWRkZWQgdGhlICdhZGMg
dXNpbmcgdGhlIG92ZXJmbG93IGZsYWcnIGJ1dCBub3QgbWFkZQ0KaXQgcG9zc2libGUgdG8gcHV0
IHRoYXQgaW50byBhIGxvb3AuDQoNCj4gRnJvbSB3aGF0IEkgaGF2ZSBzZWVuLCB0aGUgd2hvbGUg
ImRvbid0IHVzZSBMT09QIG9yIEpSQ1haIiBoYXMgbm90IGNoYW5nZWQuDQoNCkxPT1AgaXMgc3Rp
bGwgc2xvdyBvbiBpbnRlbCBjcHVzIChidXQgaXMgc2luZ2xlIGNsb2NrIG9uIHJlY2VudGlzaCBh
bWQgb25lcykuDQoNCkpDWFogaXMgcmVhc29uYWJsZSBvbiBtb3N0IGNwdXMsIGNlcnRhaW5seSBh
bGwgdGhlIG9uZXMgd2UgY2FyZSBhYm91dCB0aGVzZSBkYXlzLg0KT24gaW50ZWwgY3B1cyBKQ1ha
IGlzIHN0aWxsIDIgY2xvY2tzLCBidXQgaXQgcmVtb3ZlcyB0aGUgZGVwZW5kZW5jeSBvbiBhbnkN
CmZsYWdzICh3aGljaCBhbGwgb3RoZXIgY29uZGl0aW9uYWwgaW5zdHJ1Y3Rpb25zIGhhdmUpLg0K
VGhlIGRpZmZpY3VsdHkgaXMgdXNpbmcgaXQgZm9yIGEgbG9vcCAoeW91IG5lZWQgSkNYTlogb3Ig
YSBmYXN0IExPT1ApLg0KQW4gYWx0ZXJuYXRpdmUgdG8gdGhlICdKQ1haLCBKTVBTJyBwYWlyIHdv
dWxkIGJlIHRvIG1vdmUgdGhlIGhpZ2ggYml0cw0Kb2YgdGhlIGNvdW50ZXIgaW50byB0aGUgbG93
IGJpdHMgb2YgY3ggc28gdGhhdCBjeCB3b3VsZCBiZWNvbWUgbm9uLXplcm8NCm9uIHRoZSBsYXN0
IGl0ZXJhdGlvbi4NCg0KCURhdmlkDQoNCg==
