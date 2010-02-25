From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 5/7] TCPCT part 2e: accept SYNACK data
Date: Thu, 25 Feb 2010 15:56:37 -0500
Message-ID: <4B86E405.1090503@gmail.com>
References: <4B86DDCB.50608@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020400010902070303060606"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B86DDCB.50608@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020400010902070303060606
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

When accompanied by cookie option, Initiator (client) queues incoming
SYNACK transaction data.

This is a straightforward re-implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  The patch was previously reviewed:

    http://thread.gmane.org/gmane.linux.network/102586

This function will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1g: Responder Cookie => Initiator
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_input.c |   26 +++++++++++++++++++++++++-
  1 files changed, 25 insertions(+), 1 deletions(-)

--------------020400010902070303060606
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2e3+2.6.33.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="TCPCT+2e3+2.6.33.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9pbnB1dC5jIGIvbmV0L2lwdjQvdGNwX2lucHV0
LmMKaW5kZXggZThmOWUzYi4uMDhhMWJiNCAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwX2lu
cHV0LmMKKysrIGIvbmV0L2lwdjQvdGNwX2lucHV0LmMKQEAgLTUzOTcsNiArNTM5NywxMiBA
QCBkaXNjYXJkOgogCXJldHVybiAwOwogfQogCisvKgorICogUmV0dXJuczoKKyAqCSsxIG9u
IHJlc2V0LAorICoJMCBzdWNjZXNzIGFuZC9vciBTWU5BQ0sgZGF0YSwKKyAqCS0xIG9uIGRp
c2NhcmQuCisgKi8KIHN0YXRpYyBpbnQgdGNwX3Jjdl9zeW5zZW50X3N0YXRlX3Byb2Nlc3Mo
c3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJCQkgc3RydWN0IHRj
cGhkciAqdGgpCiB7CkBAIC01NDA1LDYgKzU0MTEsNyBAQCBzdGF0aWMgaW50IHRjcF9yY3Zf
c3luc2VudF9zdGF0ZV9wcm9jZXNzKHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYg
KnNrYiwKIAlzdHJ1Y3QgdGNwX3NvY2sgKnRwID0gdGNwX3NrKHNrKTsKIAlzdHJ1Y3QgdGNw
X2Nvb2tpZV92YWx1ZXMgKmN2cCA9IHRwLT5jb29raWVfdmFsdWVzOwogCWludCBzYXZlZF9j
bGFtcCA9IHRwLT5yeF9vcHQubXNzX2NsYW1wOworCWludCBxdWV1ZWQgPSAwOwogCiAJdGNw
X3BhcnNlX29wdGlvbnMoc2tiLCAmdHAtPnJ4X29wdCwgJmhhc2hfbG9jYXRpb24sIDApOwog
CkBAIC01NTExLDYgKzU1MTgsNyBAQCBzdGF0aWMgaW50IHRjcF9yY3Zfc3luc2VudF9zdGF0
ZV9wcm9jZXNzKHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYiwKIAkJCQkJ
LSBUQ1BPTEVOX0NPT0tJRV9CQVNFOwogCQkJaW50IGNvb2tpZV9wYWlyX3NpemUgPSBjb29r
aWVfc2l6ZQogCQkJCQkgICAgICsgY3ZwLT5jb29raWVfZGVzaXJlZDsKKwkJCWludCB0Y3Bf
aGVhZGVyX2xlbiA9IHRjcF9oZWFkZXJfbGVuX3RoKHRoKTsKIAogCQkJLyogQSBjb29raWUg
ZXh0ZW5zaW9uIG9wdGlvbiB3YXMgc2VudCBhbmQgcmV0dXJuZWQuCiAJCQkgKiBOb3RlIHRo
YXQgZWFjaCBpbmNvbWluZyBTWU5BQ0sgcmVwbGFjZXMgdGhlCkBAIC01NTI2LDYgKzU1MzQs
MTkgQEAgc3RhdGljIGludCB0Y3BfcmN2X3N5bnNlbnRfc3RhdGVfcHJvY2VzcyhzdHJ1Y3Qg
c29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IsCiAJCQkJICAgICAgIGhhc2hfbG9jYXRp
b24sIGNvb2tpZV9zaXplKTsKIAkJCQljdnAtPmNvb2tpZV9wYWlyX3NpemUgPSBjb29raWVf
cGFpcl9zaXplOwogCQkJfQorCisJCQlxdWV1ZWQgPSBza2ItPmxlbiAtIHRjcF9oZWFkZXJf
bGVuOworCQkJaWYgKHF1ZXVlZCA+IDApIHsKKwkJCQkvKiBRdWV1ZSBpbmNvbWluZyB0cmFu
c2FjdGlvbiBkYXRhLiAqLworCQkJCV9fc2tiX3B1bGwoc2tiLCB0Y3BfaGVhZGVyX2xlbik7
CisJCQkJX19za2JfcXVldWVfdGFpbCgmc2stPnNrX3JlY2VpdmVfcXVldWUsIHNrYik7CisJ
CQkJc2tiX3NldF9vd25lcl9yKHNrYiwgc2spOworCQkJCXNrLT5za19kYXRhX3JlYWR5KHNr
LCAwKTsKKwkJCQljdnAtPnNfZGF0YV9pbiA9IDE7IC8qIHRydWUgKi8KKwkJCQl0cC0+cmN2
X254dCA9IFRDUF9TS0JfQ0Ioc2tiKS0+ZW5kX3NlcTsKKwkJCQl0cC0+cmN2X3d1cCA9IFRD
UF9TS0JfQ0Ioc2tiKS0+ZW5kX3NlcTsKKwkJCQl0cC0+Y29waWVkX3NlcSA9IFRDUF9TS0Jf
Q0Ioc2tiKS0+c2VxICsgMTsKKwkJCX0KIAkJfQogCiAJCXNtcF9tYigpOwpAQCAtNTU3OSwx
MSArNTYwMCwxNCBAQCBzdGF0aWMgaW50IHRjcF9yY3Zfc3luc2VudF9zdGF0ZV9wcm9jZXNz
KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYiwKIAkJCQkJCSAgVENQX0RF
TEFDS19NQVgsIFRDUF9SVE9fTUFYKTsKIAogZGlzY2FyZDoKLQkJCV9fa2ZyZWVfc2tiKHNr
Yik7CisJCQlpZiAocXVldWVkIDw9IDApCisJCQkJX19rZnJlZV9za2Ioc2tiKTsKIAkJCXJl
dHVybiAwOwogCQl9IGVsc2UgewogCQkJdGNwX3NlbmRfYWNrKHNrKTsKIAkJfQorCQlpZiAo
cXVldWVkID4gMCkKKwkJCXJldHVybiAwOwogCQlyZXR1cm4gLTE7CiAJfQogCi0tIAoxLjYu
My4zCgo=
--------------020400010902070303060606--
