From: "James Kosin" <JKosin@intcomgrp.com>
Subject: [PATCH 1/2] net: at91_ether.c - Allow transmitter interrupt to be handled first in ISR
Date: Wed, 13 Jan 2010 12:25:07 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD36740289748A@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CA9475.5A6988A7"
Cc: "Linux Netdev List" <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756190Ab0AMRX0@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01CA9475.5A6988A7
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Ok,

This is an optimization to:

  Allow the transmitter to free the skb before the receiver allocates
many skbs from the system.  This should help with skb reuse and in
multi-core ARM systems allow the next transmitter to be started while we
service the receiver DMA blocks.

  This first patch is only a move of the service of the transmitter
interrupt to be first in the ISR.  This is not expensive; because the
transmitter queue to the MAC is only (1) one deep, and the receiver is
currently (9) nine deep.

James Kosin


------_=_NextPart_001_01CA9475.5A6988A7
Content-Type: application/octet-stream;
	name="ether_patch_1.patch"
Content-Transfer-Encoding: base64
Content-Description: ether_patch_1.patch
Content-Disposition: attachment;
	filename="ether_patch_1.patch"

LS0tIEM6L0RvY3VtZW50cyBhbmQgU2V0dGluZ3Mvamtvc2luL015IERvY3VtZW50cy9qdW5rL2tl
cm5lbC9Db3B5IG9mIGxpbnV4LTIuNi4zMS41L2RyaXZlcnMvbmV0L2FybS9hdDkxX2V0aGVyLmMJ
VGh1IE9jdCAyMiAxODo1Nzo1NiAyMDA5DQorKysgQzovRG9jdW1lbnRzIGFuZCBTZXR0aW5ncy9q
a29zaW4vTXkgRG9jdW1lbnRzL2p1bmsva2VybmVsL2xpbnV4LTIuNi4zMS41L2RyaXZlcnMvbmV0
L2FybS9hdDkxX2V0aGVyLmMJV2VkIEphbiAxMyAxMjowNTozOSAyMDEwDQpAQCAtOTI1LDkgKzky
NSw2IEBADQogCSAgIEl0IGlzIGF1dG9tYXRpY2FsbHkgY2xlYXJlZCBvbmNlIHJlYWQuICovDQog
CWludHN0YXR1cyA9IGF0OTFfZW1hY19yZWFkKEFUOTFfRU1BQ19JU1IpOw0KIA0KLQlpZiAoaW50
c3RhdHVzICYgQVQ5MV9FTUFDX1JDT00pCQkvKiBSZWNlaXZlIGNvbXBsZXRlICovDQotCQlhdDkx
ZXRoZXJfcngoZGV2KTsNCi0NCiAJaWYgKGludHN0YXR1cyAmIEFUOTFfRU1BQ19UQ09NKSB7CS8q
IFRyYW5zbWl0IGNvbXBsZXRlICovDQogCQkvKiBUaGUgVENPTSBiaXQgaXMgc2V0IGV2ZW4gaWYg
dGhlIHRyYW5zbWlzc2lvbiBmYWlsZWQuICovDQogCQlpZiAoaW50c3RhdHVzICYgKEFUOTFfRU1B
Q19UVU5EIHwgQVQ5MV9FTUFDX1JUUlkpKQ0KQEAgLTk0MCw2ICs5MzcsOSBAQA0KIAkJfQ0KIAkJ
bmV0aWZfd2FrZV9xdWV1ZShkZXYpOw0KIAl9DQorDQorCWlmIChpbnRzdGF0dXMgJiBBVDkxX0VN
QUNfUkNPTSkJCS8qIFJlY2VpdmUgY29tcGxldGUgKi8NCisJCWF0OTFldGhlcl9yeChkZXYpOw0K
IA0KIAkvKiBXb3JrLWFyb3VuZCBmb3IgRXJyYXRhICMxMSAqLw0KIAlpZiAoaW50c3RhdHVzICYg
QVQ5MV9FTUFDX1JCTkEpIHsNCg==

------_=_NextPart_001_01CA9475.5A6988A7--
