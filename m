From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] {iproute2, xfrm}: Use memcpy to suppress gcc phony buffer overflow warning
Date: Mon, 30 Sep 2013 10:29:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7368@saturn3.aculab.com>
References: <524411AE.7000404@linux.vnet.ibm.com> <52447DAC.2060701@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com> <5246D88F.7090906@linux.vnet.ibm.com> <52478710.702@windriver.com> <52479CA0.4050505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: "Sohny Thomas" <sthomas@linux.vnet.ibm.com>,
	"Fan Du" <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53984 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752801Ab3I3JbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 05:31:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17961-07 for <netdev@vger.kernel.org>;
 Mon, 30 Sep 2013 10:31:08 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <52479CA0.4050505@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoaXMgaXMgYSBmYWxzZSBwb3NpdGl2ZSB3YXJuaW5nIGFzIHRoZSBkZXN0aW5hdGlvbiBw
b2ludGVyICJidWYiDQo+ID4gcG9pbnRlcnMgdG8NCj4gPiBhbiBaRVJPIGxlbmd0aCBhcnJheSwg
d2hpY2ggYWN0dWFsbHkgd2lsbCBvY2N1cHkgYWxnLmJ1ZiBtb3N0bHkuDQo+ID4gRml4IHRoaXMg
YnkgdXNpbmcgbWVtY3B5Lg0KPiA+DQo+ID4gc3RydWN0IHhmcm1fYWxnbyB7DQo+ID4gICAgICAg
ICAgY2hhciAgICAgICAgICAgIGFsZ19uYW1lWzY0XTsNCj4gPiAgICAgICAgICB1bnNpZ25lZCBp
bnQgICAgYWxnX2tleV9sZW47ICAgIC8qIGluIGJpdHMgKi8NCj4gPiAgICAgICAgICBjaGFyICAg
ICAgICAgICAgYWxnX2tleVswXTsNCj4gPiB9Ow0KPiA+DQo+ID4gc3RydWN0IHsNCj4gPiAgICAg
ICAgICB1bmlvbiB7DQo+ID4gICAgICAgICAgICAgICAgICBzdHJ1Y3QgeGZybV9hbGdvIGFsZzsN
Cj4gPiAgICAgICAgICAgICAgICAgIHN0cnVjdCB4ZnJtX2FsZ29fYWVhZCBhZWFkOw0KPiA+ICAg
ICAgICAgICAgICAgICAgc3RydWN0IHhmcm1fYWxnb19hdXRoIGF1dGg7DQo+ID4gICAgICAgICAg
fSB1Ow0KPiA+ICAgICAgICAgIGNoYXIgYnVmW1hGUk1fQUxHT19LRVlfQlVGX1NJWkVdOw0KPiA+
IH0gYWxnID0ge307DQo+ID4NCj4gPiBidWYgPSBhbGcudS5hbGcuYWxnX2tleTsNCg0KVGhhdCBp
cyB3b3JzZSB0aGFuIGhvcnJpZC4uLg0KVGhlIHRvb2xzIGhhdmUgZXZlcnkgcmlnaHQgdG8gY29t
cGxhaW4gYWJvdXQgYW55IGFjY2Vzc2VzIHRvIGFsZ19rZXlbXS4NCg0KPiA+IC0tLQ0KPiA+ICAg
aXAveGZybV9zdGF0ZS5jIHwgICAgMiArLQ0KPiA+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0
aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+ID4NCj4gPiBkaWZmIC0tZ2l0IGEvaXAveGZybV9zdGF0
ZS5jIGIvaXAveGZybV9zdGF0ZS5jDQo+ID4gaW5kZXggMGQ5OGU3OC4uNWNjODdkMyAxMDA2NDQN
Cj4gPiAtLS0gYS9pcC94ZnJtX3N0YXRlLmMNCj4gPiArKysgYi9pcC94ZnJtX3N0YXRlLmMNCj4g
PiBAQCAtMTU5LDcgKzE1OSw3IEBAIHN0YXRpYyBpbnQgeGZybV9hbGdvX3BhcnNlKHN0cnVjdCB4
ZnJtX2FsZ28gKmFsZywNCj4gPiBlbnVtIHhmcm1fYXR0cl90eXBlX3QgdHlwZSwNCj4gPiAgICAg
ICAgICAgICAgIGlmIChsZW4gPiBtYXgpDQo+ID4gICAgICAgICAgICAgICAgICAgaW52YXJnKCJc
IkFMR08tS0VZXCIgbWFrZXMgYnVmZmVyIG92ZXJmbG93XG4iLCBrZXkpOw0KDQpJIHByZXN1bWUg
dGhlcmUgaXMgYSByZXR1cm4gaGlkaW5nIGluIGludmFyZygpLg0KDQo+ID4NCj4gPiAtICAgICAg
ICAgICAgc3RybmNweShidWYsIGtleSwgbGVuKTsNCj4gPiArICAgICAgICAgICAgbWVtY3B5KGJ1
Ziwga2V5LCBsZW4pOw0KDQpQYXNzaW5nIHRoZSBsZW5ndGggb2YgdGhlIFNPVVJDRSB0byBzdHJu
Y3B5KCkgaXMgYWxtb3N0IGFsd2F5cyB3cm9uZy4NCllvdSBhcmUgc3RpbGwgbm90IHRlcm1pbmF0
aW5nIHRoZSBjb3BpZWQgc3RyaW5nLg0KDQoJRGF2aWQNCg0KDQo=
