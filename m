From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: fix a success return may hide an error
Date: Tue, 16 Aug 2016 16:01:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00E036B@AcuExch.aculab.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net>
 <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
 <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"Marcelo Ricardo Leitner" <marcelo.leitner@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: 'Xin Long' <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:55642 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbcHPQET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 12:04:19 -0400
In-Reply-To: <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWGluIExvbmcNCj4gU2VudDogMTYgQXVndXN0IDIwMTYgMTI6MzQNCj4NCj4gPj4gQm90
aCBzY3RwX291dHFfZmx1c2hfcnR4IGFuZCBzY3RwX3BhY2tldF90cmFuc21pdCBjYW4gT05MWQ0K
PiA+PiByZXR1cm4gb25lIGVycm9yICgtRU5PTUVNKSwgYXMgc2N0cF9vdXRxX2ZsdXNoX3J0eCBh
bHNvIGNhbGxzDQo+ID4+IHNjdHBfcGFja2V0X3RyYW5zbWl0Lg0KPiA+DQo+ID4gV2hhdCBpcyB0
aGUgZWZmZWN0IG9mIHRoZSBlcnJvcj8NCj4gPiBJZiBpdCBpcyAnanVzdCcgZXF1aXZhbGVudCB0
byBhIGxvc3QgZXRoZXJuZXQgcGFja2V0IChhbmQgdGhlIHNrYiAoZXRjKQ0KPiA+IGlzIGZyZWVk
KSB0aGVuIHRoZSBwcm90b2NvbCB3aWxsIHJlY292ZXIuDQo+ID4gSWYgaXQgaXMgYW55dGhpbmcg
ZWxzZSB0aGVuIHRoZSBlcnJvciBwYXRoIGlzIHByb2JhYmx5IHdyb25nLg0KPg0KPiBUaGlzIGVy
ciByZXR1cm5zIGJhY2sgdG8gc2N0cF9zZW5kbXNnLCB0aGVyZSBzY3RwIHdpbGwgYWJvcnQgYXNv
Yy4NCg0KVGhhdCBkb2Vzbid0IHNlZW0gYSBnb29kIGlkZWEuDQpZb3UgZG9uJ3Qgd2FudCB0byBh
Ym9ydCB0aGUgYXNzb2NpYXRpb24gaWYgdGhlcmUgaXMgYSB0cmFuc2llbnQNCm1lbW9yeSBhbGxv
Y2F0aW9uIGZhaWx1cmUuDQpZb3UgYWxzbyBjYW4ndCBkcm9wIGRhdGEgY2h1bmtzLg0KDQo+IGlu
IHRoaXMgZnVuY3Rpb24sIHNjdHAgdHJpZXMgdG8gZG8gMyB0aGluZ3M6DQo+IDEuIGZsdXNoIHJ0
eCBxdWV1ZQ0KPiAyLiB0cmFuc21pdCB0aGUgcGFja2V0IG9mIGN1cnJlbnQgdHJhbnNwb3J0DQo+
IDMuIGZsdXNoIGFsbCB0aGUgdHJhbnNwb3J0cy4NCj4gTm93IHNjdHAgd291bGQgZG8gdGhlbSBv
bmUgYnkgb25lLCBldmVuIGlmIG9uZSBvZiB0aGVtIHJldHVybnMgZXJyLg0KDQpZb3UgcHJvYmFi
bHkgbmVlZCB0byBleHBsYWluIHdoYXQgJ2ZsdXNoJyBtZWFucyBoZXJlLg0KSSB0aGluayBpdCBt
ZWFucyAncHJvY2VzcyBhbmQgc2VuZCcsIGJ1dCBpdCBtaWdodCBtZWFuICdkaXNjYXJkIHRoZQ0K
Y29udGVudHMgb2YnLg0KDQpMYXN0IHRpbWUgSSBsb29rZWQgYXQgdGhlIHNjdHAgY29kZSBteSBo
ZWFkIGV4cGxvZGVkLg0KSVNUUiBpdCBpcyBhIG1lc3Mgb2YgdGltaW5nIGVycm9ycyB3YWl0aW5n
IHRvIGhhcHBlbg0KKGFuZCBJIHdyaXRlIGNvbW1zIHByb3RvY29sIHN0YWNrIGNvZGUgZm9yIGEg
bGl2aW5nKS4NCg0KCURhdmlkDQoNCg==
