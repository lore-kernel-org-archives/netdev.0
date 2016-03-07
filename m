From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 7 Mar 2016 13:56:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
 <CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:60668 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcCGN70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 08:59:26 -0500
In-Reply-To: <CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQogLi4uDQo+IEFjdHVhbGx5IHByb2JhYmx5IHRoZSBlYXNp
ZXN0IHdheSB0byBnbyBvbiB4ODYgaXMgdG8ganVzdCByZXBsYWNlIHRoZQ0KPiB1c2Ugb2YgbGVu
IHdpdGggKGxlbiA+PiA2KSBhbmQgdXNlIGRlY2wgb3IgaW5jbCBpbnN0ZWFkIG9mIGFkZGwgb3IN
Cj4gc3VibCwgYW5kIGxlYSBpbnN0ZWFkIG9mIGFkZHEgZm9yIHRoZSBidWZmIGFkZHJlc3MuICBO
b25lIG9mIHRob3NlDQo+IGluc3RydWN0aW9ucyBlZmZlY3QgdGhlIGNhcnJ5IGZsYWcgYXMgdGhp
cyBpcyBob3cgc3VjaCBsb29wcyB3ZXJlDQo+IGludGVuZGVkIHRvIGJlIGltcGxlbWVudGVkLg0K
PiANCj4gSSd2ZSBiZWVuIGRvaW5nIGEgYml0IG9mIHRlc3RpbmcgYW5kIHRoYXQgc2VlbXMgdG8g
d29yayB3aXRob3V0DQo+IG5lZWRpbmcgdGhlIGFkY3EgdW50aWwgYWZ0ZXIgeW91IGV4aXQgdGhl
IGxvb3AsIGJ1dCBkb2Vzbid0IGdpdmUgdGhhdA0KPiBtdWNoIG9mIGEgZ2FpbiBpbiBzcGVlZCBm
b3IgZHJvcHBpbmcgdGhlIGluc3RydWN0aW9uIGZyb20gdGhlDQo+IGhvdC1wYXRoLiAgSSBzdXNw
ZWN0IHdlIGFyZSBwcm9iYWJseSBtZW1vcnkgYm90dGxlLW5lY2tlZCBhbHJlYWR5IGluDQo+IHRo
ZSBsb29wIHNvIGRyb3BwaW5nIGFuIGluc3RydWN0aW9uIG9yIHR3byBkb2Vzbid0IGdhaW4geW91
IG11Y2guDQoNClJpZ2h0LCBhbnkgc3VwZXJzY2FsYXIgYXJjaGl0ZWN0dXJlIGdpdmVzIHlvdSBz
b21lIGluc3RydWN0aW9ucw0KJ2ZvciBmcmVlJyBpZiB0aGV5IGNhbiBleGVjdXRlIGF0IHRoZSBz
YW1lIHRpbWUgYXMgdGhvc2Ugb24gdGhlDQpjcml0aWNhbCBwYXRoIChpbiB0aGlzIGNhc2UgdGhl
IG1lbW9yeSByZWFkcyBhbmQgdGhlIGFkYykuDQpUaGlzIGlzIHdoeSBsb29wIHVucm9sbGluZyBj
YW4gYmUgcG9pbnRsZXNzLg0KDQpTbyB0aGUgbG9vcDoNCjEwOglhZGRjICVyYXgsKCVyZHgsJXJj
eCw4KQ0KCWluYyAlcmN4DQoJam56IDEwYg0KY291bGQgZWFzaWx5IGJlIGFzIGZhc3QgYXMgYW55
dGhpbmcgdGhhdCBkb2Vzbid0IHVzZSB0aGUgJ25ldycNCmluc3RydWN0aW9ucyB0aGF0IHVzZSB0
aGUgb3ZlcmZsb3cgZmxhZy4NClRoYXQgbG9vcCBtaWdodCBiZSBtZWFzdXJhYmxlIGZhc3RlciBm
b3IgYWxpZ25lZCBidWZmZXJzLg0KDQoJRGF2aWQNCg0K
