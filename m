From: michael-dev <michael-dev@fami-braun.de>
Subject: [PATCH] Notify userspace about bridge learning MAC on new port
Date: Mon, 15 Apr 2013 12:29:10 +0200
Message-ID: <7a31d9fe5bc9b65d4ffe6e03cbd2823f@fami-braun.de>
Reply-To: <projekt-wlan@fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_8c1278b61f2227e21bbb3a7ae3ef6627"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <projekt-wlan@fem.tu-ilmenau.de>
To: <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_8c1278b61f2227e21bbb3a7ae3ef6627
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8;
 format=flowed

Hi,

currently, the userspace is informed about the port the MAC is learned 
on a bridge and about the bridge removing the MAC from its forwarding 
table, but not when the MAC is learned on a different port. This is 
inconsistent and makes it difficult for applications to keep track of 
all MACs learned by a bridge on a subset of its ports.

Please find attached a patch that fixes this by sending an RTM_NEWNEIGH 
message when the forwarding destination port changes.

Regards,
  M. Braun
--=_8c1278b61f2227e21bbb3a7ae3ef6627
Content-Transfer-Encoding: base64
Content-Type: text/plain;
 name=999-make-bridge-notify-switched-port.diff
Content-Disposition: attachment;
 filename=999-make-bridge-notify-switched-port.diff;
 size=1213

Tm90aWZ5IHVzZXJzcGFjZSBhYm91dCBicmlkZ2UgbGVhcm5pbmcgTUFDIG9uIG5ldyBwb3J0CgpD
dXJyZW50bHksIHRoZSB1c2Vyc3BhY2UgaXMgaW5mb3JtZWQgYWJvdXQgdGhlIHBvcnQgdGhlIE1B
QyBpcyBsZWFybmVkIG9uIGEKYnJpZGdlIGFuZCBhYm91dCB0aGUgYnJpZGdlIHJlbW92aW5nIHRo
ZSBNQUMgZnJvbSBpdHMgZm9yd2FyZGluZyB0YWJsZSwgYnV0IG5vdAp3aGVuIHRoZSBNQUMgaXMg
bGVhcm5lZCBvbiBhIGRpZmZlcmVudCBwb3J0LgpUaGlzIGlzIGluY29uc2lzdGVudCBhbmQgbWFr
ZXMgaXQgZGlmZmljdWx0IGZvciBhcHBsaWNhdGlvbnMgdG8ga2VlcCB0cmFjawpvZiBhbGwgTUFD
cyBsZWFybmVkIGJ5IGEgYnJpZGdlIG9uIGEgc3Vic2V0IG9mIGl0cyBwb3J0cy4KClNpZ25lZC1v
ZmYtYnk6IE1pY2hhZWwgQnJhdW4gPG1pY2hhZWwtZGV2QGZhbWktYnJhdW4uZGU+CgotLS0gYS9u
ZXQvYnJpZGdlL2JyX2ZkYi5jCTIwMTMtMDQtMTUgMTE6MjE6NTEuNjM4OTYzNjY4ICswMjAwCisr
KyBiL25ldC9icmlkZ2UvYnJfZmRiLmMJMjAxMy0wNC0xNSAxMToyMzo1NS45NDExNjYzMTkgKzAy
MDAKQEAgLTQwOCw2ICs0MDgsNyBAQCBzdGF0aWMgaW50IGZkYl9pbnNlcnQoc3RydWN0IG5ldF9i
cmlkZ2UKIHsKIAlzdHJ1Y3QgaGxpc3RfaGVhZCAqaGVhZCA9ICZici0+aGFzaFticl9tYWNfaGFz
aChhZGRyLCB2aWQpXTsKIAlzdHJ1Y3QgbmV0X2JyaWRnZV9mZGJfZW50cnkgKmZkYjsKKwlzdHJ1
Y3QgbmV0X2JyaWRnZV9wb3J0ICpvcmlnc3JjOwogCiAJaWYgKCFpc192YWxpZF9ldGhlcl9hZGRy
KGFkZHIpKQogCQlyZXR1cm4gLUVJTlZBTDsKQEAgLTQ3MSw4ICs0NzIsMTIgQEAgdm9pZCBicl9m
ZGJfdXBkYXRlKHN0cnVjdCBuZXRfYnJpZGdlICpicgogCQkJCQlzb3VyY2UtPmRldi0+bmFtZSk7
CiAJCX0gZWxzZSB7CiAJCQkvKiBmYXN0cGF0aDogdXBkYXRlIG9mIGV4aXN0aW5nIGVudHJ5ICov
CisJCQlvcmlnc3JjID0gZmRiLT5kc3Q7CiAJCQlmZGItPmRzdCA9IHNvdXJjZTsKIAkJCWZkYi0+
dXBkYXRlZCA9IGppZmZpZXM7CisJCQkvKiBub3RpZnkgYXBwbGljYXRpb25zIG9mIG1vZGlmaWVk
IHNsYXZlIGRldmljZSAqLworCQkJaWYgKG9yaWdzcmMgIT0gc291cmNlKQorCQkJCWZkYl9ub3Rp
ZnkoYnIsIGZkYiwgUlRNX05FV05FSUdIKTsKIAkJfQogCX0gZWxzZSB7CiAJCXNwaW5fbG9jaygm
YnItPmhhc2hfbG9jayk7Cg==
--=_8c1278b61f2227e21bbb3a7ae3ef6627--
