From: Raimonds Cicans <ray@apollo.lv>
Subject: r8169: Fix receive buffer length when MTU is between 1515 and 1536
 (Was: r8169: fix driver drop incoming packets >= 1515 ...)
Date: Fri, 13 Nov 2009 22:52:19 +0200
Message-ID: <4AFDC703.10902@apollo.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070504030607070600070206"
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.apollo.lv ([80.232.168.211]:35483 "EHLO smtp1.apollo.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199AbZKMUwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 15:52:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070504030607070600070206
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


--------------070504030607070600070206
Content-Type: text/plain;
 name="r8169-mtu1536-v2.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="r8169-mtu1536-v2.patch"

SW4gcjgxNjkgZHJpdmVyIE1UVSBpcyB1c2VkIHRvIGNhbGN1bGF0ZSByZWNlaXZlIGJ1ZmZl
ciBzaXplLgpSZWNlaXZlIGJ1ZmZlciBzaXplIGlzIHVzZWQgdG8gY29uZmlndXJlIGhhcmR3
YXJlIGluY29taW5nIHBhY2tldCBmaWx0ZXIuCgpGb3IganVtYm8gZnJhbWVzOgpSZWNlaXZl
IGJ1ZmZlciBzaXplID0gTWF4IGZyYW1lIHNpemUgPSBNVFUgKyAxNCAoZXRoZXJuZXQgaGVh
ZGVyKSArIDQKKHZsYW4gaGVhZGVyKSArIDQgKGV0aGVybmV0IGNoZWNrc3VtKSA9IE1UVSAr
IDIyCgpCdWc6CmRyaXZlciBmb3IgYWxsIE1UVSB1cCB0byAxNTM2IHVzZSByZWNlaXZlIGJ1
ZmZlciBzaXplIDE1MzYKCkFzIHlvdSBjYW4gc2VlIGZyb20gZm9ybXVsYSwgdGhpcyBtZWFu
IGFsbCBJUCBwYWNrZXRzID4gMTUzNiAtIDIyCihmb3IgdmxhbiB0YWdnZWQsIDE1MzYgLSAx
OCBmb3Igbm90IHRhZ2dlZCkgYXJlIGRyb3BwZWQgYnkgaGFyZHdhcmUKZmlsdGVyLgoKRXhh
bXBsZToKCmhvc3RfZ29vZD4gIGlmY29uZmlnIGV0aDAgbXR1IDE1MzYKaG9zdF9yODE2OT4g
aWZjb25maWcgZXRoMCBtdHUgMTUzNgpob3N0X2dvb2Q+ICBwaW5nIGhvc3RfcjgxNjkKT2sK
aG9zdF9nb29kPiAgcGluZyAtcyAxNTAwIGhvc3RfcjgxNjkKRmFpbApob3N0X2dvb2Q+ICBp
ZmNvbmZpZyBldGgwIG10dSA3MDAwCmhvc3RfcjgxNjk+IGlmY29uZmlnIGV0aDAgbXR1IDcw
MDAKaG9zdF9nb29kPiAgcGluZyAtcyAxNTAwIGhvc3RfcjgxNjkKT2sKCgpCb251czogZ290
IHJpZCBvZiBtYWdpYyBudW1iZXIgOAoKU2lnbmVkLW9mZi1ieTogUmFpbW9uZHMgQ2ljYW5z
IDxyYXlAYXBvbGxvLmx2PgoKLS0tCgotLS0gbGludXgtMi42LjMxL2RyaXZlcnMvbmV0L3I4
MTY5LmMub3JpZwkyMDA5LTExLTA2IDIxOjUyOjEyLjcyMjMyNjYwMSArMDIwMAorKysgbGlu
dXgtMi42LjMxL2RyaXZlcnMvbmV0L3I4MTY5LmMJMjAwOS0xMS0wNiAyMjowOToxNy4yNDIy
MjQwMTQgKzAyMDAKQEAgLTIyMjksOSArMjIyOSw5IEBAIHN0YXRpYyB2b2lkIF9fZGV2ZXhp
dCBydGw4MTY5X3JlbW92ZV9vbmUKIHN0YXRpYyB2b2lkIHJ0bDgxNjlfc2V0X3J4YnVmc2l6
ZShzdHJ1Y3QgcnRsODE2OV9wcml2YXRlICp0cCwKIAkJCQkgIHN0cnVjdCBuZXRfZGV2aWNl
ICpkZXYpCiB7Ci0JdW5zaWduZWQgaW50IG10dSA9IGRldi0+bXR1OworCXVuc2lnbmVkIGlu
dCBtYXhfZnJhbWUgPSBkZXYtPm10dSArIFZMQU5fRVRIX0hMRU4gKyBFVEhfRkNTX0xFTjsK
IAotCXRwLT5yeF9idWZfc3ogPSAobXR1ID4gUlhfQlVGX1NJWkUpID8gbXR1ICsgRVRIX0hM
RU4gKyA4IDogUlhfQlVGX1NJWkU7CisJdHAtPnJ4X2J1Zl9zeiA9IChtYXhfZnJhbWUgPiBS
WF9CVUZfU0laRSkgPyBtYXhfZnJhbWUgOiBSWF9CVUZfU0laRTsKIH0KIAogc3RhdGljIGlu
dCBydGw4MTY5X29wZW4oc3RydWN0IG5ldF9kZXZpY2UgKmRldikK
--------------070504030607070600070206--
