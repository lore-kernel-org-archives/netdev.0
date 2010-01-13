From: "James Kosin" <JKosin@intcomgrp.com>
Subject: [PATCH 2/2] net: at91_ether.c - Allow transmitter interrupt to be handled first in ISR
Date: Wed, 13 Jan 2010 12:46:05 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD367402897491@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CA9478.47EDFB13"
Cc: "Linux Netdev List" <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server109d.appriver.com ([72.32.253.88]:2277 "EHLO
	server109.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756041Ab0AMRoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 12:44:21 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CA9478.47EDFB13
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Ok,

This next patch is optional....

The idea is TUND should only happen on occasions when the PHY is unable
to receive the transmitter data in a timely fashion to successfully send
the data in a single burst.  This is not a hard error; so, why do we
treat it as such.

This patch allows the transmitter to resend the failed skb inside the
ISR without having to deal with the overhead of freeing the skb then
having the main task re-allocate a new skb for the failed packet.

James Kosin


------_=_NextPart_001_01CA9478.47EDFB13
Content-Type: application/octet-stream;
	name="ether_patch_2.patch"
Content-Transfer-Encoding: base64
Content-Description: ether_patch_2.patch
Content-Disposition: attachment;
	filename="ether_patch_2.patch"

LS0tIEM6L0RvY3VtZW50cyBhbmQgU2V0dGluZ3Mvamtvc2luL015IERvY3VtZW50cy9qdW5rL2tl
cm5lbC9Db3B5IG9mIGxpbnV4LTIuNi4zMS41L2RyaXZlcnMvbmV0L2FybS9hdDkxX2V0aGVyLmMJ
V2VkIEphbiAxMyAxMjoyNjoxMyAyMDEwDQorKysgQzovRG9jdW1lbnRzIGFuZCBTZXR0aW5ncy9q
a29zaW4vTXkgRG9jdW1lbnRzL2p1bmsva2VybmVsL2xpbnV4LTIuNi4zMS41L2RyaXZlcnMvbmV0
L2FybS9hdDkxX2V0aGVyLmMJV2VkIEphbiAxMyAxMjozODo1NSAyMDEwDQpAQCAtOTI3LDE1ICs5
MjcsMjQgQEANCiANCiAJaWYgKGludHN0YXR1cyAmIEFUOTFfRU1BQ19UQ09NKSB7CS8qIFRyYW5z
bWl0IGNvbXBsZXRlICovDQogCQkvKiBUaGUgVENPTSBiaXQgaXMgc2V0IGV2ZW4gaWYgdGhlIHRy
YW5zbWlzc2lvbiBmYWlsZWQuICovDQotCQlpZiAoaW50c3RhdHVzICYgKEFUOTFfRU1BQ19UVU5E
IHwgQVQ5MV9FTUFDX1JUUlkpKQ0KLQkJCWRldi0+c3RhdHMudHhfZXJyb3JzICs9IDE7DQorCQlp
ZiAoaW50c3RhdHVzICYgQVQ5MV9FTUFDX1RVTkQpIHsNCisJCQlpZiAobHAtPnNrYikgew0KKwkJ
CQkvKiBTZXQgYWRkcmVzcyBvZiB0aGUgZGF0YSBpbiB0aGUgVHJhbnNtaXQgQWRkcmVzcyByZWdp
c3RlciAqLw0KKwkJCQlhdDkxX2VtYWNfd3JpdGUoQVQ5MV9FTUFDX1RBUiwgbHAtPnNrYl9waHlz
YWRkcik7DQorCQkJCS8qIFNldCBsZW5ndGggb2YgdGhlIHBhY2tldCBpbiB0aGUgVHJhbnNtaXQg
Q29udHJvbCByZWdpc3RlciAqLw0KKwkJCQlhdDkxX2VtYWNfd3JpdGUoQVQ5MV9FTUFDX1RDUiwg
bHAtPnNrYi0+bGVuKTsNCisJCQl9DQorCQl9IGVsc2Ugew0KKwkJCWlmIChpbnRzdGF0dXMgJiBB
VDkxX0VNQUNfUlRSWSkNCisJCQkJZGV2LT5zdGF0cy50eF9lcnJvcnMgKz0gMTsNCiANCi0JCWlm
IChscC0+c2tiKSB7DQotCQkJZGV2X2tmcmVlX3NrYl9pcnEobHAtPnNrYik7DQotCQkJbHAtPnNr
YiA9IE5VTEw7DQotCQkJZG1hX3VubWFwX3NpbmdsZShOVUxMLCBscC0+c2tiX3BoeXNhZGRyLCBs
cC0+c2tiX2xlbmd0aCwgRE1BX1RPX0RFVklDRSk7DQorCQkJaWYgKGxwLT5za2IpIHsNCisJCQkJ
ZGV2X2tmcmVlX3NrYl9pcnEobHAtPnNrYik7DQorCQkJCWxwLT5za2IgPSBOVUxMOw0KKwkJCQlk
bWFfdW5tYXBfc2luZ2xlKE5VTEwsIGxwLT5za2JfcGh5c2FkZHIsIGxwLT5za2JfbGVuZ3RoLCBE
TUFfVE9fREVWSUNFKTsNCisJCQl9DQorCQkJbmV0aWZfd2FrZV9xdWV1ZShkZXYpOw0KIAkJfQ0K
LQkJbmV0aWZfd2FrZV9xdWV1ZShkZXYpOw0KIAl9DQogDQogCWlmIChpbnRzdGF0dXMgJiBBVDkx
X0VNQUNfUkNPTSkJCS8qIFJlY2VpdmUgY29tcGxldGUgKi8NCg==

------_=_NextPart_001_01CA9478.47EDFB13--
