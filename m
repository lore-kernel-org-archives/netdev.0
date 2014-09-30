From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] tun: make sure interface usage can not overflow
Date: Tue, 30 Sep 2014 11:18:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174A0ECF@AcuExch.aculab.com>
References: <20140928232753.GA31180@www.outflux.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1749FC70@AcuExch.aculab.com>
	 <CAGXu5jKL13qdCBet3yqpc3vLYh_LifBACzL+NP8n-A+E8RMZXw@mail.gmail.com>
	 <1412021098.14757.6.camel@localhost>
	 <063D6719AE5E284EB5DD2968C1650D6D174A0C5C@AcuExch.aculab.com>
 <1412075023.7155.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Kees Cook <keescook@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	"stephen hemminger" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Hannes Frederic Sowa' <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52937 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751105AbaI3LUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 07:20:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12978-07 for <netdev@vger.kernel.org>;
 Tue, 30 Sep 2014 12:20:39 +0100 (BST)
In-Reply-To: <1412075023.7155.21.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIA0KPiBPbiBEaSwgMjAxNC0wOS0zMCBhdCAwODoyMCArMDAw
MCwgRGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiA+IEZyb206IEhhbm5lcyBGcmVkZXJpYw0KPiA+ID4g
T24gTW8sIDIwMTQtMDktMjkgYXQgMTI6NDEgLTA3MDAsIEtlZXMgQ29vayB3cm90ZToNCj4gPiA+
ID4gT24gTW9uLCBTZXAgMjksIDIwMTQgYXQgNDowNCBBTSwgRGF2aWQgTGFpZ2h0IDxEYXZpZC5M
YWlnaHRAYWN1bGFiLmNvbT4gd3JvdGU6DQo+ID4gPiA+ID4gRnJvbTogS2VlcyBDb29rDQo+ID4g
PiA+ID4+IFRoaXMgbWFrZXMgdGhlIHNpemUgYXJndW1lbnQgYSBjb25zdCwgc2luY2UgaXQgaXMg
YWx3YXlzIHBvcHVsYXRlZCBieQ0KPiA+ID4gPiA+PiB0aGUgY2FsbGVyLg0KPiA+ID4gPiA+DQo+
ID4gPiA+ID4gVGhlcmUgaXMgYWxtb3N0IG5vIHBvaW50IG1ha2luZyBwYXJhbWV0ZXJzICdjb25z
dC4NCj4gPiA+ID4gPiAoJ2NvbnN0IGZvbyAqJyBtYWtlcyBzZW5zZSkuDQo+ID4gPiA+ID4NCj4g
PiA+ID4gPj4gQWRkaXRpb25hbGx5IGRvdWJsZS1jaGVja3MgdG8gbWFrZSBzdXJlIHRoZSBjb3B5
X2Zyb21fdXNlcg0KPiA+ID4gPiA+PiBjYW4gbmV2ZXIgb3ZlcmZsb3csIGtlZXBpbmcgQ09ORklH
X0RFQlVHX1NUUklDVF9VU0VSX0NPUFlfQ0hFQ0tTIGhhcHB5Og0KPiA+ID4gPiA+Pg0KPiA+ID4g
PiA+PiAgICBJbiBmdW5jdGlvbiAnY29weV9mcm9tX3VzZXInLA0KPiA+ID4gPiA+PiAgICAgICAg
aW5saW5lZCBmcm9tICdfX3R1bl9jaHJfaW9jdGwnIGF0IGRyaXZlcnMvbmV0L3R1bi5jOjE4NzE6
NzoNCj4gPiA+ID4gPj4gICAgICAgIC4uLiBjb3B5X2Zyb21fdXNlcigpIGJ1ZmZlciBzaXplIGlz
IG5vdCBwcm92YWJseSBjb3JyZWN0DQo+ID4gPiA+ID4NCj4gPiA+ID4gPiBJZiAnaWZyZXFfbGVu
JyBjb3VsZCBiZSB0b28gYmlnIHRoZW4geW91IHdhbnQgdG8gZXJyb3IgdGhlIGlvY3RsLCBub3Qg
cGFuaWMuDQo+ID4gPiA+ID4gSWYgaXQgY2FuJ3QgYmUgdG9vIGJpZyB5b3UgZG9uJ3QgbmVlZCB0
aGUgY2hlY2suDQo+ID4gPiA+DQo+ID4gPiA+IFRoZSBpZnJlcV9sZW4gY29tZXMgZnJvbSB0aGUg
Y2FsbGVycywgYW5kIGlzIHRoZSBvdXRwdXQgb2YgInNpemVvZiINCj4gPiA+ID4gd2hpY2ggaXMg
Y29uc3QuIENoYW5naW5nIHRoZSBmdW5jdGlvbiBwYXJhbWV0ZXIgdG8gImNvbnN0IiBtZWFucyBh
bnkNCj4gPiA+ID4gY2hhbmdlcyBtYWRlIGluIHRoZSBmdXR1cmUgd2hlcmUgdGhlIGluY29taW5n
IHZhbHVlIGlzbid0IGNvbnN0LCB0aGUNCj4gPiA+ID4gY29tcGlsZXIgd2lsbCB0aHJvdyBhIHdh
cm5pbmcuDQo+ID4gPg0KPiA+ID4gSG1tbSwgSSB0aGluayB5b3Ugd2FudCBzb21ldGhpbmcgbGlr
ZSBCVUlMRF9CVUdfT04oIQ0KPiA+ID4gX19idWlsdGluX2NvbnN0YW50X3AodmFyKSkuIGNvbnN0
IGluIGZ1bmN0aW9uIGFyZ3VtZW50IG9ubHkgZW5zdXJlcyB0aGF0DQo+ID4gPiB0aGUgdmFsdWUg
Y2Fubm90IGJlIG1vZGlmaWVkIGluIHRoZSBmdW5jdGlvbi4NCj4gPg0KPiA+IFlvdSdkIGhhdmUg
dG8gZG8gc29tZXRoaW5nIGluIHRoZSBoZWFkZXIgZmlsZSAtIG5vdGhpbmcgaW4gdGhlIGZ1bmN0
aW9uDQo+ID4gYm9keSBjYW4gZG8gdGhhdCBjaGVjay4NCj4gDQo+IFN1cmUsIGl0IHNob3VsZCB3
b3JrLiBZb3Ugb25seSBuZWVkIHRvIG1ha2Ugc3VyZSB0aGF0IGdjYyBpbmxpbmVzIHRoZQ0KPiBm
dW5jdGlvbiwgc28gdGhlIHZhbHVlIGlzIGNvbnN0YW50IChpdCBpcyBub3QgZW5vdWdoIHRoYXQg
Z2NjIGtub3dzIHRoZQ0KPiB2YWx1ZSByYW5nZSwgb25lIHNwZWNpZmljIGNvbnN0YW50IGlzIG5l
ZWRlZCkuIFNvIHRoZSBzaW1wbGVzdCBmaXggZm9yDQo+IHRoaXMgaXMgdG8gc3BlY2lmeSBfX3R1
bl9jaHJfaW9jdGwgYXMgX19hbHdheXNfaW5saW5lLiA7KQ0KDQpZb3UgYXJlIGpva2luZyBhcmVu
J3QgeW91Pz8/DQoNCkxvb2sgYXQgdGhlIGNvZGUuDQoNCkknZCBzdWdnZXN0IGZpeGluZyB3aGF0
ZXZlciBpbXBsZW1lbnRzIENPTkZJR19ERUJVR19TVFJJQ1RfVVNFUl9DT1BZX0NIRUNLUw0KdG8g
YmUgbGVzcyBwaWNreS4NCg0KCURhdmlkDQoNCg==
