From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Fri, 21 Oct 2016 14:57:54 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D22588579@eusaamb103.ericsson.se>
References: <20161019021654.GD2773@decadent.org.uk>
         <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
         <1476967585.2709.52.camel@decadent.org.uk>
         <A2BAEFC30C8FD34388F02C9B3121859D22587ADA@eusaamb103.ericsson.se>
 <1476981609.2709.56.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Ben Hutchings <ben@decadent.org.uk>, Ying Xue <ying.xue0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usplmg21.ericsson.net ([198.24.6.65]:63568 "EHLO
        usplmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933459AbcJUO56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:57:58 -0400
In-Reply-To: <1476981609.2709.56.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQmVuIEh1dGNoaW5ncyBb
bWFpbHRvOmJlbkBkZWNhZGVudC5vcmcudWtdDQo+IFNlbnQ6IFRodXJzZGF5LCAyMCBPY3RvYmVy
LCAyMDE2IDEyOjQwDQo+IFRvOiBKb24gTWFsb3kgPGpvbi5tYWxveUBlcmljc3Nvbi5jb20+OyBZ
aW5nIFh1ZSA8eWluZy54dWUwQGdtYWlsLmNvbT4NCj4gQ2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5v
cmc7IFFpYW4gWmhhbmcgPHpoYW5ncWlhbi1jQDM2MC5jbj47IEVyaWMgRHVtYXpldA0KPiA8ZWR1
bWF6ZXRAZ29vZ2xlLmNvbT4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXRdIHRpcGM6IEd1YXJk
IGFnYWluc3QgdGlueSBNVFUgaW4gdGlwY19tc2dfYnVpbGQoKQ0KPiANCj4gT24gVGh1LCAyMDE2
LTEwLTIwIGF0IDE0OjUxICswMDAwLCBKb24gTWFsb3kgd3JvdGU6DQo+IFsuLi5dDQo+ID4gPiBB
dCB0aGlzIHBvaW50IHdlJ3JlIGFib3V0IHRvIGNvcHkgSU5UX0hfU0laRSArIG1oc3ogYnl0ZXMg
aW50byB0aGUNCj4gPiA+IGZpcnN0IGZyYWdtZW50LiDCoElmIHRoYXQncyBhbHJlYWR5IGxpbWl0
ZWQgdG8gYmUgbGVzcyB0aGFuIG9yIGVxdWFsIHRvDQo+ID4gPiBNQVhfSF9TSVpFLCBjb21wYXJp
bmcgd2l0aCBNQVhfSF9TSVpFIHdvdWxkIGJlIGZpbmUuIMKgQnV0IGlmDQo+IE1BWF9IX1NJWkUN
Cj4gPiA+IGlzIHRoZSBtYXhpbXVtIHZhbHVlIG9mIG1oc3osIHRoYXQgd29uJ3QgYmUgZ29vZCBl
bm91Z2guDQo+ID4NCj4gPg0KPiA+IE1BWF9IX1NJWkUgaXMgNjAgYnl0ZXMsIGJ1dCBpbiBwcmFj
dGljZSB5b3Ugd2lsbCBuZXZlciBzZWUgYW4gbWhzeiBsYXJnZXIgdGhhbg0KPiB0aGUgYmlnZ2Vz
dCBoZWFkZXIgd2UgYXJlIGFjdHVhbGx5IHVzaW5nLCB3aGljaCBpcyBNQ0FTVF9IX1NJWkUgKD09
NDQgYnl0ZXMpLg0KPiA+IElOVF9IX1NJWkUgaXMgNDAgYnl0ZXMsIHNvIHlvdSBhcmUgaW4gcmVh
bGl0eSB0ZXN0aW5nIGZvciB3aGV0aGVyIHdlIGhhdmUgYW4gbXR1DQo+IDwgODQgYnl0ZXMuDQo+
ID4gWW91IHdvbid0IGZpbmQgYW55IGludGVyZmFjZXMgb3IgcHJvdG9jb2xzIHRoYXQgY29tZSBl
dmVuIGNsb3NlIHRvIHRoaXMNCj4gbGltaXRhdGlvbiwgc28gdG8gbWUgdGhpcyB0ZXN0IGlzIHJl
ZHVuZGFudC4NCj4gDQo+IEJ1dCBJIGNhbiBlYXNpbHkgY3JlYXRlIHN1Y2ggYW4gaW50ZXJmYWNl
Og0KPiANCj4gJCB1bnNoYXJlIC1uIC1VIC1yDQo+ICMgaXAgbCBzZXQgbG8gbXR1IDENCj4gDQo+
IEJlbi4NCg0KSXQgd29uJ3QgYmUgdmVyeSB1c2VmdWwgdGhvdWdoLiBCdXQgSSBhc3N1bWUgeW91
IG1lYW4gaXQgY291bGQgYmUgYSBwb3NzaWJsZSBleHBsb2l0LCBhbmQgSSBzdXNwZWN0IGEgZmV3
IG90aGVyIHRoaW5ncyB3b3VsZCBicmVhayBib3RoIGluIFRJUEMgYW5kIGluIG90aGVyIHN0YWNr
cyBpZiB5b3UgZG8gYW55dGhpbmcgbGlrZSB0aGF0LiBJIHRoaW5rIHRoZSBzb2x1dGlvbiB0byB0
aGlzIGlzIG5vdCB0byBmaXggYWxsIHBvc3NpYmxlIHBsYWNlcyBpbiB0aGUgY29kZSB3aGVyZSB0
aGlzIGNhbiBnbyB3cm9uZywgYnV0IHJhdGhlciB0byBoYXZlIGEgZ2VuZXJpYyB0ZXN0IHdoZXJl
IHdlIHJlZnVzZSB0byBhdHRhY2ggYmVhcmVycy9pbnRlcmZhY2VzIG9mZmVyaW5nIGFuIG10dSA8
IGUuZy4gMTAwMCBieXRlcy4gVGhpcyBjYW4gZWFzaWx5IGJlIGRvbmUgaW4gdGlwY19lbmFibGVf
bDJfbWVkaWEoKS4NCg0KLy8vam9uDQoNCj4gDQo+IC0tDQo+IEJlbiBIdXRjaGluZ3MNCj4gTmV2
ZXIgcHV0IG9mZiB0aWxsIHRvbW9ycm93IHdoYXQgeW91IGNhbiBhdm9pZCBhbGwgdG9nZXRoZXIu
DQoNCg==
