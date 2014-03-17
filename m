From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 14:29:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DF4C4@AcuExch.aculab.com>
References: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313211509.GP21124@linux.vnet.ibm.com> <53229704.1040808@gmail.com>
	 <20140314132834.GS21124@linux.vnet.ibm.com>
	 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317135101.GA8956@casper.infradead.org>
 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43212 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933259AbaCQOal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 10:30:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18264-01 for <netdev@vger.kernel.org>;
 Mon, 17 Mar 2014 14:30:39 +0000 (GMT)
In-Reply-To: <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIE1vbiwgMjAxNC0wMy0xNyBhdCAxMzo1MSArMDAwMCwg
VGhvbWFzIEdyYWYgd3JvdGU6DQo+ID4gT24gMDMvMTYvMTQgYXQgMDk6MDZhbSwgRXJpYyBEdW1h
emV0IHdyb3RlOg0KPiA+ID4gRnJvbTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29t
Pg0KPiA+ID4NCj4gPiA+IEluIGNvbW1pdCBiNGU5YjUyMGNhNWQgKCJbTkVUX1NDSEVEXTogQWRk
IG1hc2sgc3VwcG9ydCB0byBmd21hcmsNCj4gPiA+IGNsYXNzaWZpZXIiKSBQYXRyaWNrIGFkZGVk
IGFuIHUzMiBmaWVsZCBpbiBmd19oZWFkLCBtYWtpbmcgaXQgc2xpZ2h0bHkNCj4gPiA+IGJpZ2dl
ciB0aGFuIG9uZSBwYWdlLg0KPiA+ID4NCj4gPiA+IENoYW5nZSB0aGUgbGF5b3V0IG9mIHRoaXMg
c3RydWN0dXJlIGFuZCBsZXQgY29tcGlsZXIgZW1pdCBhIHJlY2lwcm9jYWwNCj4gPiA+IGRpdmlk
ZSBmb3IgZndfaGFzaCgpLCBhcyB0aGlzIG1ha2VzIHRoZSBjb3JlIG1vcmUgcmVhZGFibGUgYW5k
DQo+ID4gPiBtb3JlIGVmZmljaWVudCB0aG9zZSBkYXlzLg0KPiA+DQo+ID4gSSB0aGluayB5b3Ug
IG5lZWQgdG8gZWR1Y2F0ZSBtZSBhIGJpdCBvbiB0aGlzLiBvYmpkdW1wDQo+ID4gc3BpdHMgb3V0
IHRoZSBmb2xsb3dpbmc6DQo+ID4NCj4gPiBzdGF0aWMgdTMyIGZ3X2hhc2godTMyIGhhbmRsZSkN
Cj4gPiB7DQo+ID4gICAgICAgICByZXR1cm4gaGFuZGxlICUgSFRTSVpFOw0KPiA+ICAgMWQ6ICAg
YmYgZmYgMDEgMDAgMDAgICAgICAgICAgbW92ICAgIGVkaSwweDFmZg0KPiA+ICAgMjI6ICAgODkg
ZjAgICAgICAgICAgICAgICAgICAgbW92ICAgIGVheCxlc2kNCj4gPiAgIDI0OiAgIDMxIGQyICAg
ICAgICAgICAgICAgICAgIHhvciAgICBlZHgsZWR4DQo+ID4gICAyNjogICBmNyBmNyAgICAgICAg
ICAgICAgICAgICBkaXYgICAgZWRpDQo+ID4NCj4gPiBEb2Vzbid0IGxvb2sgbGlrZSBhIHJlY2lw
cm9jYWwgZGl2IHRvIG1lLiBXaGVyZSBkaWQgSQ0KPiA+IHNjcmV3IHVwIG9yIHdoeSBkb2Vzbid0
IGdjYyBvcHRpbWl6ZSBpdCBwcm9wZXJseT8NCj4gPiAtLQ0KPiANCj4gVGhhdHMgYmVjYXVzZSBv
biB5b3VyIGNwdSwgZ2NjIGtub3dzIHRoZSBkaXZpZGUgaXMgY2hlYXBlciB0aGFuIGFueXRoaW5n
DQo+IGVsc2UgKGEgbXVsdGlwbHkgZm9sbG93ZWQgYnkgYSBzaGlmdCkNCg0KRXNwZWNpYWxseSBm
b3IgYSBtb2R1bHVzIG9wZXJhdGlvbiAtIHdoaWNoIHJlcXVpcmVzIGEgc2Vjb25kIG11bHRpcGx5
DQphbmQgcHJvYmFibHkgaGFzIGlzc3VlcyB3aXRoIHNvbWUgbGFyZ2UgdmFsdWVzLg0KDQpGb3Ig
YSBoYXNoIHlvdSBjb3VsZCB1c2UgJyhoYW5kbGUgKiAweDFmZnVsbCkgPj4gMzInIHRvIHJlZHVj
ZSB0aGUgaGFzaC4NCg0Kb3IgdXNlIGEgJ21vZHVsbyAyXm4tMSByZWR1Y3Rpb24nOg0KCWhhbmRs
ZSA9IChoYW5kbGUgJiAweDNmZmZmKSArIChoYW5kbGUgPj4gMTgpOw0KCWRvDQoJCWhhbmRsZSA9
IChoYW5kbGUgJiAweDFmZikgKyAoaGFuZGxlID4+IDkpOw0KCXdoaWxlIChoYW5kbGUgPiAweDFm
ZnUpOw0KDQoJRGF2aWQNCg0K
