From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3.12 065/122] lib/checksum.c: fix carry in
 csum_tcpudp_nofold
Date: Wed, 18 Feb 2015 09:40:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE56AE@AcuExch.aculab.com>
References: <cover.1424099973.git.jslaby@suse.cz>
 <07707a797d6c3cd0bfe86f037d3d1eb329acbc86.1424099973.git.jslaby@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE4D1E@AcuExch.aculab.com>
 <20150217195717.GA6779@magnum.frso.rivierawaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Jiri Slaby' <jslaby@suse.cz>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: 'Karl Beldan' <karl.beldan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217195717.GA6779@magnum.frso.rivierawaves.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogS2FybCBCZWxkYW4gDQo+IE9uIFR1ZSwgRmViIDE3LCAyMDE1IGF0IDEyOjA0OjIyUE0g
KzAwMDAsIERhdmlkIExhaWdodCB3cm90ZToNCj4gPiA+ICtzdGF0aWMgaW5saW5lIHUzMiBmcm9t
NjR0bzMyKHU2NCB4KQ0KPiA+ID4gK3sNCj4gPiA+ICsJLyogYWRkIHVwIDMyLWJpdCBhbmQgMzIt
Yml0IGZvciAzMitjIGJpdCAqLw0KPiA+ID4gKwl4ID0gKHggJiAweGZmZmZmZmZmKSArICh4ID4+
IDMyKTsNCj4gPiA+ICsJLyogYWRkIHVwIGNhcnJ5Li4gKi8NCj4gPiA+ICsJeCA9ICh4ICYgMHhm
ZmZmZmZmZikgKyAoeCA+PiAzMik7DQo+ID4gPiArCXJldHVybiAodTMyKXg7DQo+ID4gPiArfQ0K
PiA+DQo+ID4gQXMgYSBtYXR0ZXIgb2YgaW50ZXJlc3QsIGRvZXMgdGhlIGNvbXBpbGVyIG9wdGlt
aXNlIGF3YXkgdGhlDQo+ID4gc2Vjb25kICh4ICYgMHhmZmZmZmZmZikgPw0KPiA+IFRoZSBjb2Rl
IGNvdWxkIGp1c3QgYmU6DQo+ID4gCXggPSAoeCAmIDB4ZmZmZmZmZmYpICsgKHggPj4gMzIpOw0K
PiA+IAlyZXR1cm4geCArICh4ID4+IDMyKTsNCj4gPg0KPg0KPiBPbiBteSBzaWRlLCBmcm9tIHdo
YXQgSSd2ZSBzZWVuIHNvIGZhciwgeW91ciB2ZXJzaW9uIHJlc3VsdHMgaW4gYmV0dGVyDQo+IGFz
c2VtYmx5LCBlc3AuIHdpdGggY2xhbmcsIGJ1dCBteSBmaXJzdCB2ZXJzaW9uDQo+IGh0dHA6Ly9h
cnRpY2xlLmdtYW5lLm9yZy9nbWFuZS5saW51eC5rZXJuZWwvMTg3NTQwNzoNCj4gICAgICAgICB4
ICs9ICh4IDw8IDMyKSArICh4ID4+IDMyKTsNCj4gCXJldHVybiAoX19mb3JjZSBfX3dzdW0pKHgg
Pj4gMzIpOw0KPiByZXN1bHRlZCBpbiBldmVuIGJldHRlciBhc3NlbWJseSwgSSBqdXN0IHZlcmlm
aWVkIHdpdGggZ2NjL2NsYW5nLA0KPiB4ODZfNjQvQVJNIGFuZCAtTzEsMiwzLg0KDQpUaGUgbGF0
dGVyIGxvb2tzIHRvIGhhdmUgYSBzaG9ydGVyIGRlcGVuZGVuY3kgY2hhaW4gYXMgd2VsbC4NCkFs
dGhvdWdoIEknZCBkZWZpbml0ZWx5IGluY2x1ZGUgYSBjb21tZW50IHNheWluZyB0aGF0IGl0IGlz
IGVxdWl2YWxlbnQNCnRvIHRoZSB0d28gbGluZXMgaW4gdGhlIGN1cnJlbnQgcGF0Y2guDQoNCkRv
ZXMgZWl0aGVyIGNvbXBpbGVyIG1hbmFnZSB0byB1c2UgYSByb3RhdGUgZm9yIHRoZSB0d28gc2hp
ZnRzPw0KVXNpbmcgJyh4IDw8IDMyKSB8ICh4ID4+IDMyKScgbWlnaHQgY29udmluY2UgaXQgdG8g
ZG8gc28uDQpUaGF0IHdvdWxkIHJlZHVjZSBpdCB0byB0aHJlZSAncmVhbCcgaW5zdHJ1Y3Rpb25z
IGFuZCBhIHJlZ2lzdGVyIHJlbmFtZS4NCg0KCURhdmlkDQoNCg==
