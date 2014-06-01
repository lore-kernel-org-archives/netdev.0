From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 6/6] net: fec: Add software TSO support
Date: Sun, 1 Jun 2014 02:25:46 +0000
Message-ID: <3f5957016fea4105ac01c3c9c34242b1@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-7-git-send-email-b38611@freescale.com>
	 <1401431422.3645.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b5c16b8cd7874a8a979c3965984f768c@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401466898.3645.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4961e71606b94f9d812f90dff0ed0ab1@BLUPR03MB373.namprd03.prod.outlook.com>
 <1401586770.3645.139.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0238.outbound.protection.outlook.com ([207.46.163.238]:3066
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750793AbaFACZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2014 22:25:49 -0400
In-Reply-To: <1401586770.3645.139.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPiBEYXRhOiBTdW5kYXks
IEp1bmUgMDEsIDIwMTQgOTo0MCBBTQ0KPlRvOiBEdWFuIEZ1Z2FuZy1CMzg2MTENCj5DYzogTGkg
RnJhbmstQjIwNTk2OyBkYXZlbUBkYXZlbWxvZnQubmV0OyBlemVxdWllbC5nYXJjaWFAZnJlZS0N
Cj5lbGVjdHJvbnMuY29tOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBzaGF3bi5ndW9AbGluYXJv
Lm9yZzsNCj5iaHV0Y2hpbmdzQHNvbGFyZmxhcmUuY29tOyBzdGVwaGVuQG5ldHdvcmtwbHVtYmVy
Lm9yZw0KPlN1YmplY3Q6IFJFOiBbUEFUQ0ggdjEgNi82XSBuZXQ6IGZlYzogQWRkIHNvZnR3YXJl
IFRTTyBzdXBwb3J0DQo+DQo+T24gU3VuLCAyMDE0LTA2LTAxIGF0IDAwOjU1ICswMDAwLCBmdWdh
bmcuZHVhbkBmcmVlc2NhbGUuY29tIHdyb3RlOg0KPj4gRnJvbTogRXJpYyBEdW1hemV0IDxlcmlj
LmR1bWF6ZXRAZ21haWwuY29tPiBEYXRhOiBTYXR1cmRheSwgTWF5IDMxLA0KPj4gMjAxNCAxMjoy
MiBBTQ0KPj4gU28gSSBjb25uZWN0IHRvIEFQUExFIE1BQyBib29rIHRvIHRlc3QgYWdhaW4sIHRl
c3QgcmVzdWx0IChhcHBsaWVkIHRoZQ0KPnBhdGNoZXMgdG8gb3VyIGludGVybmFsIGtlcm5lbCAz
LjEwLjMxKToNCj4+IEhpZ2ggbWVtIGRpc2FibGU6IHR4IGJhbmR3aWR0aCA5NDJNYnBzLCBjcHUg
bG9hZGluZyBpcyA2NSUuDQo+PiBIaWdoIG1lbSBlbmFibGU6IHR4IGJhbmR3aWR0aCA5MzBNYnBz
LCBjcHUgbG9hZGluZyBpcyAxMDAlLg0KPj4gPT4gSSBkb24ndCBrbm93IHdoeSBrZXJuZWwgaGln
aG1lbSBjb25maWcgZW5hYmxlIGNhdXNlIHNvIG11Y2gNCj5wZXJmb3JtYW5jZSBkcm9wID8/Pw0K
Pj4NCj4+IEZvciB5b3VyIGFib3ZlIHN1Z2dlc3Rpb24gInVzaW5nIG9uZSBkZXNjcmlwdG9yIHBl
ciBNU1MsIGluc3RlYWQgb2YgdHdvIjoNCj4+IFllcywgZm9yIGlteDZkbCBzb2MsIHdlIGp1c3Qg
ZG8gaXQgbGlrZSB0aGlzLiAgRm9yIGlteDZzeCBzb2MgRkVDIHRoYXQNCj5zdXBwb3J0IGJ5dGUg
YWxpZ25tZW50LCAgc28gaXQgYWxzbyB1c2Ugb25lIGRlc2NyaXB0b3IgcGVyIE1TUy4NCj4+DQo+
PiBUaGFua3MgZm9yIHlvdXIgc3VnZ2VzdGlvbiBhbmQgcmVzcG9uc2UuIERvIHlvdSBrbm93IHdo
eSBoaWdobWVtIGNhdXNlDQo+bXVjaCBwZXJmb3JtYW5jZSBkcm9wIGZvciBTVyBUU08gPw0KPg0K
PkNoZWNrIE5FVElGX0ZfSElHSERNQSA6IHlvdXIgZHJpdmVyIG1pZ2h0IGJlIGFibGUgdG8gYWR2
ZXJ0aXNlIGl0cyBzdXBwb3J0Lg0KPg0KSW5kZWVkLCBJIGdvdCB0aGUgdGVzdCByZXN1bHQgYWZ0
ZXIgYWRkICJORVRJRl9GX0hJR0hETUEiIGZlYXR1cmUsIG90aGVyd2lzZSwgdGhlIHBlcmZvcm1h
bmNlIGlzIHdvcnNlLg0KDQo+Q2hlY2sgeW91ciBjb3BpZXMsIGJlY2F1c2UgeW91IG1pZ2h0IHRo
ZW4gbmVlZCBrbWFwKCkNCj4NCj5Gb3IgYW4gZXhhbXBsZSwgcmVhZCBlZnhfc2tiX2NvcHlfYml0
c190b19waW8oKSBpbg0KPmRyaXZlcnMvbmV0L2V0aGVybmV0L3NmYy90eC5jDQo+DQpJIHdpbGwg
Y2hlY2sgaXQuDQoNClRoYW5rcywNCkFuZHkNCg==
