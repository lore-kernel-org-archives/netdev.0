From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 16:43:18 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7349@saturn3.aculab.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com> <878uyu6xjm.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"Oliver Neukum" <oneukum@suse.de>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, "Oliver Neukum" <oliver@neukum.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"Ming Lei" <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35542 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752189Ab3IRPpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 11:45:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00807-10 for <netdev@vger.kernel.org>;
 Wed, 18 Sep 2013 16:45:52 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <878uyu6xjm.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJIGFsc28gYmVsaWV2ZSBpdCB3b3VsZCBiZSBuaWNlIHRvIG1vdmUgdGhlIGluaXRpYWxpc2F0
aW9uIG9mIGNhbl9kbWFfc2cNCj4gYXdheSBmcm9tIHRoZSBtaW5pZHJpdmVyIGFuZCBpbnRvIHVz
Ym5ldF9wcm9iZS4gIEl0J3MgY29uZnVzaW5nIHRoYXQNCj4gdGhpcyBmaWVsZCBpcyB1c2VkICJ1
bmluaXRpYWxpemVkIiAod2VsbCwgZGVmYXVsdGluZyB0byB6ZXJvKSBpbiBhbGwgYnV0DQo+IG9u
ZSBtaW5pZHJpdmVyLiAgSXQgd291bGQgbXVjaCBuaWNlciBpZiB0aGUgbG9naWMgd2FzIG1vcmUg
bGlrZQ0KPiANCj4gdXNibmV0X3Byb2JlOg0KPiAgaWYgKC4uLikNCj4gICAgIGRldi0+Y2FuX2Rt
YV9zZyA9IDE7DQo+IA0KPiBtaW5pZHJpdmVyX2JpbmQ6DQo+ICAgaWYgKGRldi0+Y2FuX2RtYV9z
Zykgew0KPiAgICAgIGRldi0+bmV0LT5mZWF0dXJlcyB8PSBORVRJRl9GX1NHIHwgTkVUSUZfRl9U
U087DQo+ICAgICAgZGV2LT5uZXQtPmh3X2ZlYXR1cmVzIHw9IE5FVElGX0ZfU0cgfCBORVRJRl9G
X1RTTzsNCj4gICB9DQoNCkFjdHVhbGx5IGl0IHdvdWxkIHByb2JhYmx5IGJlIG5pY2VyIGlmIHRo
ZSBtaW5pZHJpdmVyIHNldA0KYSBmbGFnIHRvIGluZGljYXRlIHRoYXQgaXQgY291bGQgc3VwcG9y
dCBmcmFnbWVudGVkIHNrYg0KKGEgbG90IGNhbid0IGJlY2F1c2Ugb2YgdGhlIHdheSB0aGV5IGFk
ZCB0cmFpbGVycykNCmFuZCBhbHNvIHByb3ZpZGVkIHRoZSBsZW5ndGggb2YgdGhlIGhlYWRlciBp
dCB3aWxsIGFkZC4NCg0KVGhlIHVzYm5ldCBjb2RlIGNvdWxkIHRoZW4gYWxsb2NhdGUgdGhlIGhl
YWRlciBzcGFjZS4NCklmIHNjYXR0ZXItZ2F0aGVyIGRtYSBpcyBhdmFpbGFibGUgKGEgaG9zdCBm
ZWF0dXJlKSB0aGVuDQp0aGUgaGVhZGVyIGNhbiBiZSBhbGxvY2F0ZWQgb3V0c2lkZSB0aGUgc2ti
IGRhdGEgYXJlYQ0KdG8gYXZvaWQgaGF2aW5nIHRvIGNvcHkgdGhlIGVudGlyZSBza2IgZGF0YS4N
ClRoZSBjaGVjayBmb3IgWkxQIGF2b2lkYW5jZSBjb3VsZCB0aGVuIGJlIGRvbmUgb25jZSBvbmx5
DQoobm90IHN1cmUgaG93IHRoZSBpbmZvIHdvdWxkIGJlIHBhc3NlZCB0byB0ZWggbWluaWRyaXZl
ciBhcGFydA0KZnJvbSBhZGRpbmcgbW9yZSBhZGRpdGlvbmFsIHBhcmFtZXRlcnMgdG8gdGVoIHR4
X2ZpeHVwIGZ1bmN0aW9uKS4NCg0KSSBkaWQgYSBxdWljayBzY2FuIG9mIHRoZSBtaW5pZHJpdmVy
cywgc29tZSBvZiB0aGVtIGRvbid0DQpzZWVtIHRvIGhhdmUgdGhlIGNvcnJlY3QgY2hlY2tzIGZv
ciBmcmFnbWVudGVkIHNrYiAoZXRjKS4NCg0KTW9zdCBvZiB0aGVtIG9ubHkgYWRkIGEgaGVhZGVy
Lg0KDQoJRGF2aWQNCg0KDQo=
