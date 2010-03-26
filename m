From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] net: fix netlink address dumping in IPv4/IPv6
Date: Fri, 26 Mar 2010 18:13:51 +0100
Message-ID: <4BACEB4F.9060900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060506080208030900020105"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47831 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab0CZRNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 13:13:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060506080208030900020105
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------060506080208030900020105
Content-Type: application/mbox;
 name="0001-net-fix-netlink-address-dumping-in-IPv4-IPv6.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename*0="0001-net-fix-netlink-address-dumping-in-IPv4-IPv6.patch"

V2hlbiBhIGR1bXAgaXMgaW50ZXJydXB0ZWQgYXQgdGhlIGxhc3QgZGV2aWNlIGluIGEgaGFz
aCBjaGFpbiBhbmQKdGhlbiBjb250aW51ZWQsICJpZHgiIHdvbid0IGdldCBpbmNyZW1lbnRl
ZCBwYXN0IHNfaWR4LCBzbyBzX2lwX2lkeAppcyBub3QgcmVzZXQgd2hlbiBtb3Zpbmcgb24g
dG8gdGhlIG5leHQgZGV2aWNlLiBUaGlzIG1lYW5zIG9mIGFsbApmb2xsb3dpbmcgZGV2aWNl
cyBvbmx5IHRoZSBsYXN0IG4gLSBzX2lwX2lkeCBhZGRyZXNzZXMgYXJlIGR1bXBlZC4KClRl
c3RlZC1ieTogUGF3ZWwgU3Rhc3pld3NraSA8cHN0YXN6ZXdza2lAaXRjYXJlLnBsPgpTaWdu
ZWQtb2ZmLWJ5OiBQYXRyaWNrIE1jSGFyZHkgPGthYmVyQHRyYXNoLm5ldD4KLS0tCiBuZXQv
aXB2NC9kZXZpbmV0LmMgIHwgICAgMiArLQogbmV0L2lwdjYvYWRkcmNvbmYuYyB8ICAgIDIg
Ky0KIDIgZmlsZXMgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoK
ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2RldmluZXQuYyBiL25ldC9pcHY0L2RldmluZXQuYwpp
bmRleCA1MWNhOTQ2Li4zZmViMmIzIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9kZXZpbmV0LmMK
KysrIGIvbmV0L2lwdjQvZGV2aW5ldC5jCkBAIC0xMTk0LDcgKzExOTQsNyBAQCBzdGF0aWMg
aW50IGluZXRfZHVtcF9pZmFkZHIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldGxp
bmtfY2FsbGJhY2sgKmNiKQogCQlobGlzdF9mb3JfZWFjaF9lbnRyeV9yY3UoZGV2LCBub2Rl
LCBoZWFkLCBpbmRleF9obGlzdCkgewogCQkJaWYgKGlkeCA8IHNfaWR4KQogCQkJCWdvdG8g
Y29udDsKLQkJCWlmIChpZHggPiBzX2lkeCkKKwkJCWlmIChoID4gc19oIHx8IGlkeCA+IHNf
aWR4KQogCQkJCXNfaXBfaWR4ID0gMDsKIAkJCWluX2RldiA9IF9faW5fZGV2X2dldF9yY3Uo
ZGV2KTsKIAkJCWlmICghaW5fZGV2KQpkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvYWRkcmNvbmYu
YyBiL25ldC9pcHY2L2FkZHJjb25mLmMKaW5kZXggMzM4MWI0My4uN2U1NjdhZSAxMDA2NDQK
LS0tIGEvbmV0L2lwdjYvYWRkcmNvbmYuYworKysgYi9uZXQvaXB2Ni9hZGRyY29uZi5jCkBA
IC0zNjEwLDcgKzM2MTAsNyBAQCBzdGF0aWMgaW50IGluZXQ2X2R1bXBfYWRkcihzdHJ1Y3Qg
c2tfYnVmZiAqc2tiLCBzdHJ1Y3QgbmV0bGlua19jYWxsYmFjayAqY2IsCiAJCWhsaXN0X2Zv
cl9lYWNoX2VudHJ5X3JjdShkZXYsIG5vZGUsIGhlYWQsIGluZGV4X2hsaXN0KSB7CiAJCQlp
ZiAoaWR4IDwgc19pZHgpCiAJCQkJZ290byBjb250OwotCQkJaWYgKGlkeCA+IHNfaWR4KQor
CQkJaWYgKGggPiBzX2ggfHwgaWR4ID4gc19pZHgpCiAJCQkJc19pcF9pZHggPSAwOwogCQkJ
aXBfaWR4ID0gMDsKIAkJCWlmICgoaWRldiA9IF9faW42X2Rldl9nZXQoZGV2KSkgPT0gTlVM
TCkKLS0gCjEuNi41LjcKCg==
--------------060506080208030900020105--
