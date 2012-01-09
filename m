From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 10:36:44 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
	 <20120105.132637.2130515220408371607.davem@davemloft.net>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
 <1326095038.2627.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:58428 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab2AIJhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 04:37:05 -0500
In-Reply-To: <1326095038.2627.4.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NClNlbnQ6
IE1vbmRheSwgSmFudWFyeSAwOSwgMjAxMiAwODo0NA0KDQo+TGUgbHVuZGkgMDkgamFudmllciAy
MDEyIMOgIDA4OjE2ICswMTAwLCBNYW5mcmVkIFJ1ZGlnaWVyIGEgw6ljcml0IDoNCj4+IEZyb206
IERhdmlkIE1pbGxlciBbbWFpbHRvOmRhdmVtQGRhdmVtbG9mdC5uZXRdDQo+PiBTZW50OiBUaHVy
c2RheSwgSmFudWFyeSAwNSwgMjAxMiAxOToyNw0KPj4NCj4+ID5Gcm9tOiBNYW5mcmVkIFJ1ZGln
aWVyIDxtYW5mcmVkLnJ1ZGlnaWVyQG9taWNyb24uYXQ+DQo+PiA+RGF0ZTogVGh1LCA1IEphbiAy
MDEyIDE1OjUwOjIxICswMTAwDQo+PiA+DQo+PiA+PiArDQo+PiA+PiArCQkvKiBLZWVwIHNvY2sg
aWYgd2UgbXVzdCByZXR1cm4gYSB0aW1lIHN0YW1wIG9uIHRoZSBlcnIgcXVldWUgKi8NCj4+ID4+
ICsJCXNrYl9uZXctPnNrID0gc2tiLT5zazsNCj4+ID4NCj4+ID5XaGVuIEkgc2VlIHNvbWV0aGlu
ZyBsaWtlIHRoaXMgd2l0aG91dCBhbnkga2luZCBvZiByZWZlcmVuY2UgY291bnRpbmcNCj4+ID5v
ciBzaW1pbGFyLCBJIGFtIGdyYXZlbHkgY29uY2VybmVkLg0KPj4NCj4+IFRoZSBza2JfdHN0YW1w
X3R4IGZ1bmN0aW9uIGNhbGxlZCBkdXJpbmcgZ2Zhcl9jbGVhbl90eF9yaW5nIHJlcXVpcmVzDQo+
PiB0aGUgc2tiLT5zayBwb2ludGVyIHRvIGJlIHNldC4gT3RoZXJ3aXNlIG5vIHRpbWUgc3RhbXAg
Y2FuIGJlIHF1ZXVlZA0KPj4gb24gdGhlIHNvY2tldCBlcnJvciBxdWV1ZS4NCj4+IFdoYXQgd291
bGQgYmUgdGhlIGNvcnJlY3Qgd2F5IGZvciBkb2luZyB0aGlzPw0KPg0KPkkgcmVhbGx5IHdvbmRl
ciBob3cgeW91ciBjb2RlIHdhcyBwb3NzaWJseSB3b3JraW5nLi4uDQoNCldlbGwsIGl0IHdhcyB3
b3JraW5nIDotKQ0KDQo+QSBjb3JyZWN0IHN0ZWFsIHNlcXVlbmNlIG1heWJlDQo+DQo+CXNrYl9u
ZXctPnNrID0gc2tiLT5zazsNCj4Jc2tiLT5zayA9IE5VTEw7DQo+CWtmcmVlX3NrYihza2IpOw0K
Pg0KPk9yIGVsc2UsIGtmcmVlX3NrYigpIHJlbGVhc2VzIHNrIHJlZmVyZW5jZSBhbmQgZXZlbnR1
YWxseSBzb2NrZXQgaXMgZnJlZWQNCj5iZWZvcmUgc2tiX3RzdGFtcF90eCgpDQoNCkkgaGF2ZSB0
cmllZCB5b3VyIHN1Z2dlc3RlZCBzdGVhbCBzZXF1ZW5jZSwgYnV0IGl0IGNyYXNoZWQuIA0KSSBz
ZWUgdGhhdCB0aGVyZSBpcyBhbHNvIGEgZGVzdHJ1Y3RvciAtIHdoZW4gSSB1c2UgdGhlIHNrYl9v
cnBoYW4gZnVuY3Rpb24gKHdoaWNoIGNhbGxzIHRoZSBkZXN0cnVjdG9yKSBsaWtlIHRoaXMgaXQg
d29ya3M6DQoNCglza2JfbmV3LT5zayA9IHNrYi0+c2s7DQoJc2tiX29ycGhhbihza2IpOw0KCWtm
cmVlX3NrYihza2IpOw0KDQpJcyB0aGlzIHRoZSBjb3JyZWN0IHNvbHV0aW9uPw0KDQpSZWdhcmRz
LA0KTWFuZnJlZA0K
