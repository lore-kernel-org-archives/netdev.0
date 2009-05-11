From: "Luc Goria" <Luc.Goria@adept-telecom.fr>
Subject: [PATCH 2.6.27.2] datagram handling routines : mapping/unmapping paged data in soft IRQ
Date: Mon, 11 May 2009 15:32:21 +0200
Message-ID: <54466B0E862D654998371DCA86B6FE2F4B6D47@adept-srv2.adept.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C9D23C.E9828EF6"
Cc: <linux-kernel@vger.kernel.org>, <alan@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from green.ailair.fr ([91.121.209.168]:3776 "EHLO green.ailair.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbZEKNo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 09:44:29 -0400
content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C9D23C.E9828EF6
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


Kernel crashes when a network module tries to copy a datagram to iovec =
in soft IRQ with paged data.
The problem is that kunmap function can't be called in IRQ.
All calls to kmap/kunmap fonctions are replaced by calls to =
kmap_skb_frag/kunmap_skb_frag when paged data are involved.

 <<datagram.c.patch>>=20
Signed-off-by: Luc GORIA <luc.goria@adept-telecom.fr>

------_=_NextPart_001_01C9D23C.E9828EF6
Content-Type: application/octet-stream;
	name="datagram.c.patch"
Content-Transfer-Encoding: base64
Content-Description: datagram.c.patch
Content-Disposition: attachment;
	filename="datagram.c.patch"

LS0tIGxpbnV4LTIuNi4yNy4yL25ldC9jb3JlL2RhdGFncmFtLmMJMjAwOS0wNS0wNiAxNzo0Mzow
OC4wMDAwMDAwMDAgKzAyMDAKKysrIG15LWxpbnV4LTIuNi4yNy4yL25ldC9jb3JlL2RhdGFncmFt
LmMJMjAwOS0wNS0wNiAxNzo1Mjo0NC4wMDAwMDAwMDAgKzAyMDAKQEAgLTU2LDYgKzU2LDggQEAK
ICNpbmNsdWRlIDxuZXQvc29jay5oPgogI2luY2x1ZGUgPG5ldC90Y3Bfc3RhdGVzLmg+CiAKKyNp
bmNsdWRlICJrbWFwX3NrYi5oIgorCiAvKgogICoJSXMgYSBzb2NrZXQgJ2Nvbm5lY3Rpb24gb3Jp
ZW50ZWQnID8KICAqLwpAQCAtMjkyLDE0ICsyOTQsMTMgQEAKIAkJCWludCBlcnI7CiAJCQl1OCAg
KnZhZGRyOwogCQkJc2tiX2ZyYWdfdCAqZnJhZyA9ICZza2Jfc2hpbmZvKHNrYiktPmZyYWdzW2ld
OwotCQkJc3RydWN0IHBhZ2UgKnBhZ2UgPSBmcmFnLT5wYWdlOwogCiAJCQlpZiAoY29weSA+IGxl
bikKIAkJCQljb3B5ID0gbGVuOwotCQkJdmFkZHIgPSBrbWFwKHBhZ2UpOworCQkJdmFkZHIgPSBr
bWFwX3NrYl9mcmFnKGZyYWcpOwogCQkJZXJyID0gbWVtY3B5X3RvaW92ZWModG8sIHZhZGRyICsg
ZnJhZy0+cGFnZV9vZmZzZXQgKwogCQkJCQkgICAgIG9mZnNldCAtIHN0YXJ0LCBjb3B5KTsKLQkJ
CWt1bm1hcChwYWdlKTsKKwkJCWt1bm1hcF9za2JfZnJhZyh2YWRkcik7CiAJCQlpZiAoZXJyKQog
CQkJCWdvdG8gZmF1bHQ7CiAJCQlpZiAoIShsZW4gLT0gY29weSkpCkBAIC0zNzcsMTQgKzM3OCwx
MyBAQAogCQkJaW50IGVycjsKIAkJCXU4ICAqdmFkZHI7CiAJCQlza2JfZnJhZ190ICpmcmFnID0g
JnNrYl9zaGluZm8oc2tiKS0+ZnJhZ3NbaV07Ci0JCQlzdHJ1Y3QgcGFnZSAqcGFnZSA9IGZyYWct
PnBhZ2U7CiAKIAkJCWlmIChjb3B5ID4gbGVuKQogCQkJCWNvcHkgPSBsZW47Ci0JCQl2YWRkciA9
IGttYXAocGFnZSk7CisJCQl2YWRkciA9IGttYXBfc2tiX2ZyYWcoZnJhZyk7CiAJCQllcnIgPSBt
ZW1jcHlfZnJvbWlvdmVjKHZhZGRyICsgZnJhZy0+cGFnZV9vZmZzZXQgKwogCQkJCQkgICAgICAg
b2Zmc2V0IC0gc3RhcnQsIGZyb20sIGNvcHkpOwotCQkJa3VubWFwKHBhZ2UpOworCQkJa3VubWFw
X3NrYl9mcmFnKHZhZGRyKTsKIAkJCWlmIChlcnIpCiAJCQkJZ290byBmYXVsdDsKIApAQCAtNDYx
LDE2ICs0NjEsMTUgQEAKIAkJCWludCBlcnIgPSAwOwogCQkJdTggICp2YWRkcjsKIAkJCXNrYl9m
cmFnX3QgKmZyYWcgPSAmc2tiX3NoaW5mbyhza2IpLT5mcmFnc1tpXTsKLQkJCXN0cnVjdCBwYWdl
ICpwYWdlID0gZnJhZy0+cGFnZTsKIAogCQkJaWYgKGNvcHkgPiBsZW4pCiAJCQkJY29weSA9IGxl
bjsKLQkJCXZhZGRyID0ga21hcChwYWdlKTsKKwkJCXZhZGRyID0ga21hcF9za2JfZnJhZyhmcmFn
KTsKIAkJCWNzdW0yID0gY3N1bV9hbmRfY29weV90b191c2VyKHZhZGRyICsKIAkJCQkJCQlmcmFn
LT5wYWdlX29mZnNldCArCiAJCQkJCQkJb2Zmc2V0IC0gc3RhcnQsCiAJCQkJCQkgICAgICB0bywg
Y29weSwgMCwgJmVycik7Ci0JCQlrdW5tYXAocGFnZSk7CisJCQlrdW5tYXBfc2tiX2ZyYWcodmFk
ZHIpOwogCQkJaWYgKGVycikKIAkJCQlnb3RvIGZhdWx0OwogCQkJKmNzdW1wID0gY3N1bV9ibG9j
a19hZGQoKmNzdW1wLCBjc3VtMiwgcG9zKTsK

------_=_NextPart_001_01C9D23C.E9828EF6--
