From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 16:30:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C863E@AcuExch.aculab.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	 <20141010035840.21428.359.stgit@ahduyck-workstation.home>
	 <20141010.004708.1975127853551765914.davem@davemloft.net>
	 <5437F072.5060502@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
 <1412955219.9362.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "'alexander.h.duyck@redhat.com'" <alexander.h.duyck@redhat.com>,
	"David Miller" <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39756 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751622AbaJJQcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 12:32:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24376-03 for <netdev@vger.kernel.org>;
 Fri, 10 Oct 2014 17:32:22 +0100 (BST)
In-Reply-To: <1412955219.9362.13.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2Vu
dDogMTAgT2N0b2JlciAyMDE0IDE2OjM0DQo+IFRvOiBEYXZpZCBMYWlnaHQNCj4gQ2M6ICdhbGV4
YW5kZXIuaC5kdXlja0ByZWRoYXQuY29tJzsgRGF2aWQgTWlsbGVyOyBhbGV4YW5kZXIuZHV5Y2tA
Z21haWwuY29tOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hd
IGZsb3ctZGlzc2VjdG9yOiBGaXggYWxpZ25tZW50IGlzc3VlIGluIF9fc2tiX2Zsb3dfZ2V0X3Bv
cnRzDQo+IA0KPiBPbiBGcmksIDIwMTQtMTAtMTAgYXQgMTQ6NTcgKzAwMDAsIERhdmlkIExhaWdo
dCB3cm90ZToNCj4gDQo+ID4gSSB0aGluayB0aGVyZSBpcyBjb2RlIHRvIGNvcHkgdGhlIElQIGFu
ZCBUQ1AgaGVhZGVycyB0byBhbGlnbmVkIG1lbW9yeQ0KPiA+IGJlZm9yZSB0aGV5IGFyZSBwYXJz
ZWQuDQo+IA0KPiBUaGVyZSBpcyBubyBzdWNoIHRoaW5nLiBZb3UgYXJlIGhlcmUgb24gbmV0ZGV2
IGxpc3QsIHBsZWFzZSByZWFkIHRoZQ0KPiBjb2RlIGJlZm9yZSBkb2luZyBzdWNoIGNsYWltcy4N
Cg0KSSBkaWQgc2F5ICdJIHRoaW5rJy4uLg0KSSBtdXN0IGJlIHRoaW5raW5nIG9mIHNvbWUgc2lt
aWxhciBjb2RlIHNvbWV3aGVyZSBlbHNlLg0KUG9zc2libHkganVzdCB0aGUgY29kZSB0aGF0IGVu
c3VyZXMgdGhlIGhlYWRlciBpc24ndCBmcmFnbWVudGVkLg0KDQo+ID4gPiBUaGUgcHJvYmxlbSBp
cyB0aGUgaWdiIC8gaXhnYmUgLyBmbTEwayBoYXJkd2FyZSBkb2Vzbid0IGhhdmUgYSBtZWFucyBv
Zg0KPiA+ID4gaW5zZXJ0aW5nIHBhZGRpbmcgZnJvbSBpdHMgc2lkZS4uLg0KPiA+DQo+ID4gU2hv
b3QgdGhlIGhhcmR3YXJlIGVuZ2luZWVycy4NCj4gPg0KPiA+IFlvdSBhcmVuJ3QgZ29pbmcgdG8g
Z2V0IHRoZSBwZXJmb3JtYW5jZSB5b3UgZXhwZWN0IGZyb20gYSAxMEdlIGNhcmQNCj4gPiB1bmxl
c3MgdGhlIHJ4IGJ1ZmZlcnMgYXJlICdjb3JyZWN0bHknIGFsaWduZWQuDQo+IA0KPiBUaGF0IGlz
IHNpbXBseSBub3QgdHJ1ZSBvbiBjdXJyZW50IHg4NiBjcHVzLiBUaGV5IHNpbXBseSBkb250IGNh
cmUgYXQNCj4gYWxsLg0KDQpJIHdhcyByZWZlcnJpbmcgdG8gdXNpbmcgdGhlbSBvbiBzcGFyYzY0
LCBub3QgeDg2Lg0KDQpJIGtub3cgdGhhdCBjdXJyZW50IGludGVsIHg4NiBjcHUgaGF2ZSBzdXBw
b3J0IGZvciBtaXNhbGlnbmVkICdyZXAgbW92c2QnLA0KYnV0IEkgdGhvdWdodCB0aGVyZSB3YXMg
c3RpbGwgYSBzbWFsbCBjb3N0IChtYXliZSBvbmUgY2xvY2spIGZvcg0Kc2luZ2xlIHdvcmQgdHJh
bnNmZXJzLg0KU28gbWF5YmUgdGhleSBjYXJlICdqdXN0IGEgbGl0dGxlIGJpdCcuDQoNCj4gWW91
IGNhbm5vdCBibGFtZSBJbnRlbCBmb3Igb3RoZXIgYXJjaGVzLg0KDQpUcnVlLCBidXQgdGhpcyBk
b2VzIG1lYW4gdGhhdCB5b3UgZG9uJ3QgcmVhbGx5IHdhbnQgdG8gdXNlIHRoZXNlIGFkYXB0ZXJz
DQpvbiBhIHN5c3RlbSB0aGF0IGNhbid0IHRvIHVuYWxpZ25lZCBhY2Nlc3Nlcy4NCg0KCURhdmlk
DQoNCg==
