From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Fri, 26 Sep 2014 13:16:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1749E538@AcuExch.aculab.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D1749E380@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	=?utf-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42124 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753782AbaIZNRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 09:17:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24413-04 for <netdev@vger.kernel.org>;
 Fri, 26 Sep 2014 14:17:26 +0100 (BST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1749E380@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTGFpZ2h0DQo+IEZyb206IEVyaWMgRHVtYXpldA0KPiA+IE9uIFdlZCwgMjAx
NC0wOS0yNCBhdCAxOToxMiAtMDcwMCwgRXJpYyBEdW1hemV0IHdyb3RlOg0KPiAuLi4NCj4gPiBJ
dCB0dXJuZWQgb3V0IHRoZSBwcm9ibGVtIEkgbm90aWNlZCB3YXMgY2F1c2VkIGJ5IGNvbXBpbGVy
IHRyeWluZyB0byBiZQ0KPiA+IHNtYXJ0LCBidXQgaW52b2x2aW5nIGEgYmFkIE1FU0kgdHJhbnNh
Y3Rpb24uDQo+ID4NCj4gPiAgIDAuMDUgICBtb3YgICAgMHhjMCglcmF4KSwlZWRpICAgIC8vIExP
QUQgZHFsLT5udW1fcXVldWVkDQo+ID4gICAwLjQ4ICAgbW92ICAgICVlZHgsMHhjOCglcmF4KSAg
ICAvLyBTVE9SRSBkcWwtPmxhc3Rfb2JqX2NudCA9IGNvdW50DQo+ID4gIDU4LjIzICAgYWRkICAg
ICVlZHgsJWVkaQ0KPiA+ICAgMC41OCAgIGNtcCAgICAlZWRpLDB4YzQoJXJheCkNCj4gPiAgIDAu
NzYgICBtb3YgICAgJWVkaSwweGMwKCVyYXgpICAgIC8vIFNUT1JFIGRxbC0+bnVtX3F1ZXVlZCAr
PSBjb3VudA0KPiA+ICAgMC43MiAgIGpzICAgICBiZDgNCj4gPg0KPiA+DQo+ID4gSSBnZXQgYW4g
aW5jcmVkaWJsZSAxMCAlIGdhaW4gYnkgbWFraW5nIHN1cmUgY3B1IHdvbnQgZ2V0IHRoZSBjYWNo
ZSBsaW5lDQo+ID4gaW4gU2hhcmVkIG1vZGUuDQo+IA0KPiBUaGF0IGlzIGEgc3R1bm5pbmcgZGlm
ZmVyZW5jZSBiZXR3ZWVuIHJlcXVlc3RpbmcgJ2V4Y2x1c2l2ZScgYWNjZXNzDQo+IGFuZCB1cGdy
YWRpbmcgJ3NoYXJlZCcgdG8gZXhjbHVzaXZlLg0KPiBTdGlua3Mgb2YgYSBjcHUgYnVnPw0KPiAN
Cj4gT3IgaXMgdGhlIHJlcG9ydGVkIHN0YWxsIGEgc2lkZSBlZmZlY3Qgb2Ygd2FpdGluZyBmb3Ig
dGhlIGVhcmxpZXINCj4gJ2NhY2hlIGxpbmUgcmVhZCcgdG8gY29tcGxldGUgaW4gb3JkZXIgdG8g
aXNzdWUgdGhlICd1cGdyYWRlIHRvIGV4Y2x1c2l2ZScuDQo+IEluIHdoaWNoIGNhc2UgZ2NjJ3Mg
aW5zdHJ1Y3Rpb24gc2NoZWR1bGVyIHByb2JhYmx5IG5lZWRzIHRvIGJlIHRhdWdodA0KPiB0byBz
Y2hlZHVsZSB3cml0ZXMgYmVmb3JlIHJlYWRzLg0KDQpUaGlua2luZyBmdXJ0aGVyLg0KZ2NjIGlz
IHByb2JhYmx5IG1vdmluZyBtZW1vcnkgcmVhZHMgYmVmb3JlIHdyaXRlcyB1bmRlciB0aGUgYXNz
dW1wdGlvbiB0aGF0DQp0aGUgY3B1IG1pZ2h0IHN0YWxsIHdhaXRpbmcgZm9yIHRoZSByZWFkIHRv
IGNvbXBsZXRlIGJ1dCB0aGF0IHRoZSB3cml0ZQ0KY2FuIGJlIGJ1ZmZlcmVkIGJ5IHRoZSBoYXJk
d2FyZS4NCg0KVGhhdCBhc3N1bXB0aW9uIGlzIHRydWUgZm9yIHNpbXBsZSBjcHVzIChsaWtlIHRo
ZSBOaW9zMiksIGJ1dCBmb3IgeDg2IHdpdGgNCml0cyBtdWx0aXBsZSBpbnN0cnVjdGlvbnMgaW4g
ZmxpZ2h0IChldGMpIG1heSBtYWtlIGxpdHRsZSBkaWZmZXJlbmNlIGlmDQp0aGUgbWVtb3J5IGlz
IGluIHRoZSBjYWNoZS4NCg0KT1RPSCBpdCBsb29rcyBhcyB0aG91Z2ggdGhlcmUgaXMgYSBiaWcg
aGl0IGlmIHlvdSByZWFkIHRoZW4gd3JpdGUNCmEgbm9uLXByZXNlbnQgY2FjaGUgbGluZS4NCihU
aGlzIG1heSBldmVuIGRlcGVuZCBvbiB3aGljaCBpbnN0cnVjdGlvbnMgZ2V0IGV4ZWN1dGVkIGlu
IHBhcmFsbGVsLA0KbWlub3IgY2hhbmdlcyB0byB0aGUgY29kZSBjb3VsZCBlYXNpbHkgY2hhbmdl
IHRoYXQuKQ0KDQpJIHdvbmRlciBob3cgZWFzeSBpdCB3b3VsZCBiZSB0byBtb2RpZnkgZ2NjIHRv
IHJlbW92ZSAob3IgZXZlbiByZXZlcnNlKQ0KdGhhdCBtZW1vcnkgb3JkZXJpbmcgJ29wdGltaXNh
dGlvbicuDQoNCglEYXZpZA0KDQoNCg==
