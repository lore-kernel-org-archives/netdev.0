From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: [Patch] pktgen: refactor pg_init() code
Date: Sun, 22 May 2011 18:52:08 +0800
Message-ID: <BANLkTikd8Ft0N6ovGp8KOVksg2Rj4RxRaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e64607387c0f8604a3db25a1
Cc: David Miller <davem@davemloft.net>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53517 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab1EVKwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:52:09 -0400
Received: by iwn34 with SMTP id 34so4024795iwn.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 03:52:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e64607387c0f8604a3db25a1
Content-Type: text/plain; charset=UTF-8

This also shrinks the object size a little.

   text	   data	    bss	    dec	    hex	filename
  28834	    186	      8	  29028	   7164	net/core/pktgen.o
  28816	    186	      8	  29010	   7152	net/core/pktgen.o.AFTER


Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: "David Miller" <davem@davemloft.net>,

---

--0016e64607387c0f8604a3db25a1
Content-Type: text/x-patch; charset=US-ASCII; name="net-pktgen-refactor-pg_init.diff"
Content-Disposition: attachment; filename="net-pktgen-refactor-pg_init.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnzv6sgh0

IG5ldC9jb3JlL3BrdGdlbi5jIHwgICAxOSArKysrKysrKysrKystLS0tLS0tCiAxIGZpbGVzIGNo
YW5nZWQsIDEyIGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0
L2NvcmUvcGt0Z2VuLmMgYi9uZXQvY29yZS9wa3RnZW4uYwppbmRleCA2Nzg3MGU5Li5lYTk5NDY0
IDEwMDY0NAotLS0gYS9uZXQvY29yZS9wa3RnZW4uYworKysgYi9uZXQvY29yZS9wa3RnZW4uYwpA
QCAtMzcwOCw2ICszNzA4LDcgQEAgc3RhdGljIGludCBfX2luaXQgcGdfaW5pdCh2b2lkKQogewog
CWludCBjcHU7CiAJc3RydWN0IHByb2NfZGlyX2VudHJ5ICpwZTsKKwlpbnQgcmV0ID0gMDsKIAog
CXByX2luZm8oIiVzIiwgdmVyc2lvbik7CiAKQEAgLTM3MTgsMTEgKzM3MTksMTAgQEAgc3RhdGlj
IGludCBfX2luaXQgcGdfaW5pdCh2b2lkKQogCXBlID0gcHJvY19jcmVhdGUoUEdDVFJMLCAwNjAw
LCBwZ19wcm9jX2RpciwgJnBrdGdlbl9mb3BzKTsKIAlpZiAocGUgPT0gTlVMTCkgewogCQlwcl9l
cnIoIkVSUk9SOiBjYW5ub3QgY3JlYXRlICVzIHByb2NmcyBlbnRyeVxuIiwgUEdDVFJMKTsKLQkJ
cHJvY19uZXRfcmVtb3ZlKCZpbml0X25ldCwgUEdfUFJPQ19ESVIpOwotCQlyZXR1cm4gLUVJTlZB
TDsKKwkJcmV0ID0gLUVJTlZBTDsKKwkJZ290byByZW1vdmVfZGlyOwogCX0KIAotCS8qIFJlZ2lz
dGVyIHVzIHRvIHJlY2VpdmUgbmV0ZGV2aWNlIGV2ZW50cyAqLwogCXJlZ2lzdGVyX25ldGRldmlj
ZV9ub3RpZmllcigmcGt0Z2VuX25vdGlmaWVyX2Jsb2NrKTsKIAogCWZvcl9lYWNoX29ubGluZV9j
cHUoY3B1KSB7CkBAIC0zNzM2LDEzICszNzM2LDE4IEBAIHN0YXRpYyBpbnQgX19pbml0IHBnX2lu
aXQodm9pZCkKIAogCWlmIChsaXN0X2VtcHR5KCZwa3RnZW5fdGhyZWFkcykpIHsKIAkJcHJfZXJy
KCJFUlJPUjogSW5pdGlhbGl6YXRpb24gZmFpbGVkIGZvciBhbGwgdGhyZWFkc1xuIik7Ci0JCXVu
cmVnaXN0ZXJfbmV0ZGV2aWNlX25vdGlmaWVyKCZwa3RnZW5fbm90aWZpZXJfYmxvY2spOwotCQly
ZW1vdmVfcHJvY19lbnRyeShQR0NUUkwsIHBnX3Byb2NfZGlyKTsKLQkJcHJvY19uZXRfcmVtb3Zl
KCZpbml0X25ldCwgUEdfUFJPQ19ESVIpOwotCQlyZXR1cm4gLUVOT0RFVjsKKwkJcmV0ID0gLUVO
T0RFVjsKKwkJZ290byB1bnJlZ2lzdGVyOwogCX0KIAogCXJldHVybiAwOworCisgdW5yZWdpc3Rl
cjoKKwl1bnJlZ2lzdGVyX25ldGRldmljZV9ub3RpZmllcigmcGt0Z2VuX25vdGlmaWVyX2Jsb2Nr
KTsKKwlyZW1vdmVfcHJvY19lbnRyeShQR0NUUkwsIHBnX3Byb2NfZGlyKTsKKyByZW1vdmVfZGly
OgorCXByb2NfbmV0X3JlbW92ZSgmaW5pdF9uZXQsIFBHX1BST0NfRElSKTsKKwlyZXR1cm4gcmV0
OwogfQogCiBzdGF0aWMgdm9pZCBfX2V4aXQgcGdfY2xlYW51cCh2b2lkKQo=
--0016e64607387c0f8604a3db25a1--
