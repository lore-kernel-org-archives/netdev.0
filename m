From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/5] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Tue, 1 Apr 2014 08:33:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6ED8F6@AcuExch.aculab.com>
References: <1396070947-17721-1-git-send-email-maheshb@google.com>
	 <1396281158.29410.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6ECFA7@AcuExch.aculab.com>
 <1396282964.29410.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Eric Dumazet" <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49309 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751077AbaDAIeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 04:34:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21465-09 for <netdev@vger.kernel.org>;
 Tue,  1 Apr 2014 09:34:12 +0100 (BST)
In-Reply-To: <1396282964.29410.53.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyANCj4gT24gTW9uLCAyMDE0LTAzLTMxIGF0IDE2OjAwICswMDAwLCBEYXZpZCBM
YWlnaHQgd3JvdGU6DQo+IA0KPiA+IFdoaWNoIG1heSBvciBub3QgYmUgZmFzdGVyLi4uDQo+IA0K
PiBXZSBkb24ndCBjYXJlIG9mIHRoaXMga2luZCBvZiBhc3NlcnRpb25zLg0KPiANCj4gQnJpbmcg
dXMgcmVhbCBkYXRhLCBvciBqdXN0IHNheSBub3RoaW5nLiBUaGlzIGlzIGEgd2FzdGUgb2YgdGlt
ZS4NCj4gDQo+ID4gQXMgY29kZWQgdGhlIGNhc2UgbGFiZWxzIG1heSBiZSBkZW5zZSBlbm91Z2gg
dG8gZ2VuZXJhdGUgYSBqdW1wIHRhYmxlLg0KPiA+IElmIGJ5dGUgcmV2ZXJzZWQgdGhlIGdlbmVy
YXRlZCBjb2RlIHdpbGwgYmUgYSBicmFuY2ggdHJlZS4NCj4gPg0KPiA+IEEgZGVlcCBicmFuY2gg
dHJlZSB3aWxsIGJlIHdvcnNlLCBhIG1hdGNoIG9uIHRoZSBmaXJzdCBpdGVtIG9mIGEgYnJhbmNo
DQo+ID4gdHJlZSB3aWxsIGFsbW9zdCBjZXJ0YWlubHkgYmUgYmV0dGVyLg0KPiA+IEknbSBub3Qg
Z29pbmcgdG8gZ3Vlc3Mgd2hlcmUgdGhlIGJyZWFrZXZlbiBwb2ludCBpcyBmb3IgYW55IG1vZGVy
biBjcHVzLg0KPiANCj4gVGhpcyBpcyByaWRpY3Vsb3VzLCB0aGVyZSBpcyBubyBqdW1wdGFibGUg
Zm9yIEVUSF9QX0lQLCBFVEhfUF9JUFgsDQo+IEVUSF9QX0lQVjYuDQo+IA0KPiBJdHMgbm90IGxp
a2UgdGhlaXIgdmFsdWUgd2lsbCBldmVyIGJlIDEgLCAyIGFuZCAzDQo+IA0KPiBJIHN1Z2dlc3Qg
eW91IHRha2UgYSBsb29rIGF0IHRoZSBleGlzdGluZyBjb2RlIGluIHdob2xlIG5ldHdvcmtpbmcN
Cj4gc3RhY2suIFRoaXMgaXMgaG93IHdlIGNvZGVkIHRoaW5ncywgYmVjYXVzZSB0aGVyZSBpcyBu
byBuZWVkIHRvIGRvDQo+IG50b2hzKHZhcmlhYmxlKSB3aGVuIHdlIGNhbiBzaW1wbHkgd3JpdGUg
aHRvbnMoY29uc3RhbnQpIHdoaWNoIGV2ZW4gYQ0KPiBkdW1iIGNvbXBpbGVyIGNhbiB1bmRlcnN0
YW5kLiAoV2UgdXNlZCB0byBoYXZlIF9fY29uc3RhbnRfaHRvbnMoKSBidXQgaXQNCj4gbG9va3Mg
aXRzIG5vdCBuZWVkZWQgdGhlc2UgZGF5cy4pDQoNCkkgYW0gZnVsbHkgYXdhcmUgb2YgdGhlIGdl
bmVyYWwgYWR2YW50YWdlIG9mIGRvaW5nIGh0b25zKGNvbnN0YW50KQ0KaW4gYSBjb21wYXJpc29u
LCByYXRoZXIgdGhhbiBjb252ZXJ0aW5nIHRoZSB2YXJpYWJsZS4NCg0KSSBhbSBhbHNvIGF3YXJl
IG9mIHRoZSBkaWZmZXJlbnQgd2F5cyB0aGUgY29tcGlsZXIgY2FuIGNvbXBpbGUNCmEgc3dpdGNo
IHN0YXRlbWVudCwgYW5kIG1hbnkgb2YgdGhlIHByb2JsZW1zIHdpdGggZWFjaC4NCg0KSSdsbCBh
ZG1pdCB0byBub3QgbG9va2luZyBhdCB0aGUgdmFsdWVzIG9mIHRob3NlIGNvbnN0YW50cywgc28N
Cm1heSBoYXZlIGFzc3VtZWQgdGhleSB3ZXJlIHNtYWxsIGludGVnZXJzIChJIHdhcyBwcm9iYWJs
eSB0aGlua2luZw0KdGhleSB3ZXJlIHRoZSB2YWx1ZXMgdGhhdCBhcHBlYXIgaW4gc29ja2FkZHIp
Lg0KDQpIb3dldmVyIEkgc3RhbmQgYnkgbXkgYXNzZXJ0aW9uIHRoYXQgZ2l2ZW4gYSBzd2l0Y2gg
c3RhdGVtZW50IHRoYXQNCmlzIGxpa2VseSB0byBoYXZlIGRlbnNlIGNhc2UgbGFiZWxzIHlvdSBw
cm9iYWJseSBkb24ndCB3YW50IHRvDQpieXRlc3dhcCB0aGUgdmFsdWUgc28gdGhhdCB0aGUgY29t
cGlsZXIgZ2VuZXJhdGVzIGEgYnJhbmNoIHRyZWUuDQpUaGUgJ3Byb2JsZW0nIGlzIHRoYXQgdGhl
IGp1bXAgdGFibGUgaXMgbGlrZWx5IHRvIGJlIGEgZGF0YSBjYWNoZQ0KbWlzcywgYnV0IHRoZSBi
cmFuY2ggdHJlZSBtaWdodCBwcmVkaWN0IHRoZSBjb3JyZWN0IG91dGNvbWUgLSBzbw0KdGhlIGJy
YW5jaCB0cmVlIG1pZ2h0IGJlIGZhc3RlciBmb3Igc29tZSB2YWx1ZXMgb2YgdGhlIGV4cHJlc3Np
b24uDQoNCglEYXZpZA0KDQo=
