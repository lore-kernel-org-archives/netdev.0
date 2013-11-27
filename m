From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Wed, 27 Nov 2013 13:56:52 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7449@saturn3.aculab.com>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com> <20131002212720.GA30492@elgon.mountain> <20131127113218.GB1612@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<security@kernel.org>,
	=?utf-8?B?SsO8cmkgQWVkbGE=?= <juri.aedla@gmail.com>,
	<stable@kernel.org>
To: "Eric Wong" <normalperson@yhbt.net>,
	"Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38771 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751276Ab3K0OBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 09:01:10 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18008-08 for <netdev@vger.kernel.org>;
 Wed, 27 Nov 2013 14:01:07 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131127113218.GB1612@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBFcmljIFdvbmcNCj4gRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUu
Y29tPiB3cm90ZToNCj4gPiAtLS0gYS9uZXQvc29ja2V0LmMNCj4gPiArKysgYi9uZXQvc29ja2V0
LmMNCj4gPiBAQCAtMTk2NCw2ICsxOTY0LDE2IEBAIHN0cnVjdCB1c2VkX2FkZHJlc3Mgew0KPiA+
ICAJdW5zaWduZWQgaW50IG5hbWVfbGVuOw0KPiA+ICB9Ow0KPiA+DQo+ID4gK3N0YXRpYyBpbnQg
Y29weV9tc2doZHJfZnJvbV91c2VyKHN0cnVjdCBtc2doZHIgKmttc2csDQo+ID4gKwkJCQkgc3Ry
dWN0IG1zZ2hkciBfX3VzZXIgKnVtc2cpDQo+ID4gK3sNCj4gPiArCWlmIChjb3B5X2Zyb21fdXNl
cihrbXNnLCB1bXNnLCBzaXplb2Yoc3RydWN0IG1zZ2hkcikpKQ0KPiA+ICsJCXJldHVybiAtRUZB
VUxUOw0KPiA+ICsJaWYgKGttc2ctPm1zZ19uYW1lbGVuID4gc2l6ZW9mKHN0cnVjdCBzb2NrYWRk
cl9zdG9yYWdlKSkNCj4gPiArCQlyZXR1cm4gLUVJTlZBTDsNCj4gPiArCXJldHVybiAwOw0KPiAN
Cj4gQ3JhcCwgdGhpcyBzZWVtcyB0byBicmVhayBSdWJ5IHRydW5rIDp4DQo+IGh0dHBzOi8vYnVn
cy5ydWJ5LWxhbmcub3JnL2lzc3Vlcy85MTI0DQo+IA0KPiBJJ20gaW5jbGluZWQgdG8gdGhpbmsg
UnVieSBpcyB3cm9uZyB0byB1c2UgYSBnaWdhbnRpYyBidWZmZXIsIGJ1dCB0aGlzDQo+IG1heSBh
bHNvIGJyZWFrIHNvbWUgb3RoZXIgZXhpc3RpbmcgdXNlcnNwYWNlIGNvZGUuICBJJ20gbm90IHN1
cmUgd2hhdA0KPiB0aGUgYmVzdCBvcHRpb24gc2luY2UgYnJlYWtpbmcgdXNlcnNwYWNlIChldmVu
IGJ1Z2d5IHVzZXJzcGFjZT8pIGlzIG5vdA0KPiB0YWtlbiBsaWdodGx5Lg0KDQpXZWxsLCAnc3Ry
dWN0IHNvY2thZGRyX3N0b3JhZ2UnIGlzIGEgaG9ycmlkIGl0ZW0uDQpJIHRoaW5rIHRoZXJlIGFy
ZSBwZW9wbGUgd2hvJ2xsIHNheSB0aGF0IGl0IHNob3VsZCBuZXZlciBiZSB1c2VkDQp0byBhbGxv
Y2F0ZSBhbiBhY3R1YWwgYnVmZmVyLg0KDQpJZiB0aGUga2VybmVsIGlzIGdvaW5nIHRvIHdyaXRl
IGFuIGFkZHJlc3MgaW50byB0aGUgYnVmZmVyLCBpdCBvbmx5DQpuZWVkcyBhIGJ1ZmZlciB0aGF0
IGlzIGxvbmcgZW5vdWdoLg0KSWYgdGhlIGtlcm5lbCBpcyBnb2luZyB0byByZWFkIGFuIGFkZHJl
c3MsIHRoZSBsZW5ndGggbmVlZHMgdG8gYmUNCmFwcHJvcHJpYXRlIGZvciB0aGUgYWN0dWFsIHBy
b3RvY29sLg0KDQpWZXJ5IHBvcnRhYmxlIGNvZGUsIGFuZCBjb2RlIHRoYXQgd2FudHMgdG8gYmUg
J2Z1dHVyZSBwcm9vZicgYWdhaW5zdA0KbmV3IHByb3RvY29scyBtaWdodCB3ZWxsIHVzZSBhIGxv
bmcgYnVmZmVyLg0KDQoJRGF2aWQNCg0K
