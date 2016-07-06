From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] net: poll tx timeout only on active tx queues
Date: Wed, 6 Jul 2016 06:42:57 +0000
Message-ID: <CO2PR11MB0088E7024FA29C309D20B655973A0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
 <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
 <CO2PR11MB00889A8F46E66124C99E43DE97250@CO2PR11MB0088.namprd11.prod.outlook.com>
 <1467350290.11238.31.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9tiqPUe=h+OhTSqaS1ULkOtG3ycaZQXGrvtbgL3deH6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0106.outbound.protection.outlook.com ([104.47.37.106]:22656
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751930AbcGFGnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 02:43:00 -0400
In-Reply-To: <CALzJLG9tiqPUe=h+OhTSqaS1ULkOtG3ycaZQXGrvtbgL3deH6g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+PiA+IGN1cnJlbnRseSBhbGwgdGhlIGRldmljZSBkcml2ZXIgY2FsbA0KPiA+PiA+IG5ldGlm
X3R4X3N0YXJ0X2FsbF9xdWV1ZXMoZGV2KSBvbiBvcGVuIHRvIFcvQSB0aGlzIGlzc3VlLiB3aGlj
aCBpcw0KPiA+PiA+IHN0cmFuZ2Ugc2luY2Ugb25seSByZWFsX251bV90eF9xdWV1ZXMgYXJlIGFj
dGl2ZS4NCj4gPj4NCj4gPj4gWW91IGNvdWxkIGFsc28gYXJndWUgdGhhdCBuZXRpZl90eF9zdGFy
dF9hbGxfcXVldWVzKCkgc2hvdWxkIG9ubHkNCj4gPj4gZW5hYmxlIHRoZSByZWFsX251bV90eF9x
dWV1ZXMuDQo+ID4+IFtBbHRob3VnaCB0aGF0IHdvdWxkIG9idmlvdXNseSBjYXVzZSBhbGwgZHJp
dmVycyB0byByZWFjaCB0aGUNCj4gPj4gJ3Byb2JsZW0nIHlvdSdyZSBjdXJyZW50bHkgZml4aW5n
XS4NCj4gPg0KPiA+IFllcC4gQmFzaWNhbGx5IHdoYXQgSSBwb2ludGVkIG91dC4NCj4gPg0KPiA+
IEl0IHNlZW1zIGluY29uc2lzdGVudCB0byBoYXZlIGxvb3BzIHVzaW5nIG51bV90eF9xdWV1ZXMs
IGFuZCBvdGhlcnMNCj4gPiB1c2luZyByZWFsX251bV90eF9xdWV1ZXMuDQo+ID4NCj4gPiBJbnN0
ZWFkIG9mICdmaXhpbmcnIG9uZSBvZiB0aGVtLCB3ZSBzaG91bGQgdGFrZSBhIGRlZXBlciBsb29r
LCBldmVuIGlmDQo+ID4gdGhlIGNoYW5nZSBsb29rcyBmaW5lLg0KPiA+DQo+ID4gbnVtX3R4X3F1
ZXVlcyBzaG91bGQgYmUgdXNlZCBpbiBjb2RlIHRoYXQgcnVucyBvbmNlLCBsaWtlDQo+ID4gbmV0
ZGV2X2xvY2tkZXBfc2V0X2NsYXNzZXMoKSwgYnV0IG90aGVyIGxvb3BzIHNob3VsZCBwcm9iYWJs
eSB1c2UNCj4gPiByZWFsX251bV90eF9xdWV1ZXMuDQo+ID4NCj4gPiBBbnl3YXkgYWxsIHRoZXNl
IGNoYW5nZXMgc2hvdWxkIGRlZmluaXRlbHkgdGFyZ2V0IG5ldC1uZXh0LCBub3QgbmV0DQo+ID4g
dHJlZS4NCj4gPg0KPiANCj4gQnV0IGZvciB0aGUgbG9uZyB0ZXJtLCB5b3UgaGF2ZSBhIHBvaW50
Lg0KPiBXZSB3aWxsIGNvbnNpZGVyIGEgZGVlcGVyIGZpeCBmb3IgbmV0LW5leHQgYXMgeW91IHN1
Z2dlc3RlZCwgYW5kIGRyb3AgdGhpcw0KPiB0ZW1wb3JhcnkgZml4Lg0KDQpJIHRoaW5rIHdlJ3Zl
IGFjdHVhbGx5IG1hbmFnZWQgdG8gaGl0IGFuIGlzc3VlIHdpdGggcWVkZSBbJiBtb2RpZmllZCBi
bngyeF0NCmR1ZSB0byBuZXRpZl90eF9zdGFydF9hbGxfcXVldWVzKCkgc3RhcnRpbmcgYWxsIFR4
LXF1ZXVlcyAtIA0KV2hpbGUgcmVkdWNpbmcgdGhlIG51bWJlciBvZiBjaGFubmVscyBvbiBhbiBp
bnRlcmZhY2UgZHJpdmVyIHJlbG9hZHMNCmZvbGxvd2luZyB3aGljaCB0aGUgeG1pdCBmdW5jdGlv
biByZWNlaXZlcyBhbiBTS0IgdXNpbmcgYSB0b28taGlnaCB0eHEuDQoNCkludmVzdGlnYXRpb24g
c2VlbSB0byBpbmRpY2F0ZSB0aGF0IHNvbWUgVENQIHRyYWZmaWMgYXJyaXZlZCBkdXJpbmcgdGhl
DQpyZWxvYWQsIGdvdCBlbnF1ZXVlZCBvbiB0aGUgcWRpc2Mgd2l0aCBoaWdoIHR4cSBhbmQgdGhl
biBnb3QgdHJhbnNtaXR0ZWQNCmFzLWlzIGFmdGVyIHJlLWVuYWJsaW5nIHR4Lg0KW1JlbW92aW5n
IHRoZSBtb2R1bG8gZnJvbSBibngyeCdzIHNlbGVjdF9xdWV1ZSgpIGxlYWQgdG8gc2FtZSBpc3N1
ZS5dDQo=
