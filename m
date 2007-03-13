From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 13/15] [SK_BUFF]: More skb_reset_transport_header conversions
Date: Tue, 13 Mar 2007 18:47:01 -0300
Message-ID: <39e6f6c70703131447m383203bajb3957bfcda78cb5c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_31321_33287616.1173822421912"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:26287 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933730AbXCMVrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 17:47:03 -0400
Received: by wr-out-0506.google.com with SMTP id i28so1523891wra
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2007 14:47:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_31321_33287616.1173822421912
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

These are a bit more subtle, they are of this type:

-       skb->h.raw = payload;
        __skb_pull(skb, payload - skb->data);
+       skb_reset_transport_header(skb);

__skb_pull results in:

skb->data = skb->data + payload - skb->data;
skb->data = payload;

So after __skb_pull we have skb->data pointing to payload and we can
just call skb_reset_transport_header(skb), that will do:

skb->h.raw = payload;

The others are similar, allowing us to get rid of some more cases where a
pointer was being attributed to the layer headers.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ip_sockglue.c |   12 +++++++-----
 net/ipv6/datagram.c    |    4 ++--
 2 files changed, 9 insertions(+), 7 deletions(-)

------=_Part_31321_33287616.1173822421912
Content-Type: text/x-patch;
	name=0013-SK_BUFF-More-skb_reset_transport_header-conversio.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez8vhypq
Content-Disposition: attachment; filename="0013-SK_BUFF-More-skb_reset_transport_header-conversio.patch"

RnJvbSA3Njg0YTI0Y2IwMzI4ZTUxOTI5OGEzNjc0ZTA4ZGI0YmNhNjg2MWMzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogVHVlLCAxMyBNYXIgMjAwNyAxNzoxMDo0MyAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTMvMTVdIFtTS19CVUZGXTogTW9yZSBza2JfcmVzZXRfdHJhbnNwb3J0X2hlYWRlciBjb252
ZXJzaW9ucwoKVGhlc2UgYXJlIGEgYml0IG1vcmUgc3VidGxlLCB0aGV5IGFyZSBvZiB0aGlzIHR5
cGU6CgotICAgICAgIHNrYi0+aC5yYXcgPSBwYXlsb2FkOwogICAgICAgIF9fc2tiX3B1bGwoc2ti
LCBwYXlsb2FkIC0gc2tiLT5kYXRhKTsKKyAgICAgICBza2JfcmVzZXRfdHJhbnNwb3J0X2hlYWRl
cihza2IpOwoKX19za2JfcHVsbCByZXN1bHRzIGluOgoKc2tiLT5kYXRhID0gc2tiLT5kYXRhICsg
cGF5bG9hZCAtIHNrYi0+ZGF0YTsKc2tiLT5kYXRhID0gcGF5bG9hZDsKClNvIGFmdGVyIF9fc2ti
X3B1bGwgd2UgaGF2ZSBza2ItPmRhdGEgcG9pbnRpbmcgdG8gcGF5bG9hZCBhbmQgd2UgY2FuCmp1
c3QgY2FsbCBza2JfcmVzZXRfdHJhbnNwb3J0X2hlYWRlcihza2IpLCB0aGF0IHdpbGwgZG86Cgpz
a2ItPmgucmF3ID0gcGF5bG9hZDsKClRoZSBvdGhlcnMgYXJlIHNpbWlsYXIsIGFsbG93aW5nIHVz
IHRvIGdldCByaWQgb2Ygc29tZSBtb3JlIGNhc2VzIHdoZXJlIGEKcG9pbnRlciB3YXMgYmVpbmcg
YXR0cmlidXRlZCB0byB0aGUgbGF5ZXIgaGVhZGVycy4KClNpZ25lZC1vZmYtYnk6IEFybmFsZG8g
Q2FydmFsaG8gZGUgTWVsbyA8YWNtZUByZWRoYXQuY29tPgotLS0KIG5ldC9pcHY0L2lwX3NvY2tn
bHVlLmMgfCAgIDEyICsrKysrKystLS0tLQogbmV0L2lwdjYvZGF0YWdyYW0uYyAgICB8ICAgIDQg
KystLQogMiBmaWxlcyBjaGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbmV0L2lwdjQvaXBfc29ja2dsdWUuYyBiL25ldC9pcHY0L2lwX3NvY2tnbHVl
LmMKaW5kZXggY2NkYzU5ZC4uZmNiMzVjZCAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvaXBfc29ja2ds
dWUuYworKysgYi9uZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jCkBAIC0yNzgsMTAgKzI3OCwxMiBAQCB2
b2lkIGlwX2ljbXBfZXJyb3Ioc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBp
bnQgZXJyLAogCQkJCSAgIHNrYl9uZXR3b3JrX2hlYWRlcihza2IpOwogCXNlcnItPnBvcnQgPSBw
b3J0OwogCi0Jc2tiLT5oLnJhdyA9IHBheWxvYWQ7Ci0JaWYgKCFza2JfcHVsbChza2IsIHBheWxv
YWQgLSBza2ItPmRhdGEpIHx8Ci0JICAgIHNvY2tfcXVldWVfZXJyX3NrYihzaywgc2tiKSkKLQkJ
a2ZyZWVfc2tiKHNrYik7CisJaWYgKHNrYl9wdWxsKHNrYiwgcGF5bG9hZCAtIHNrYi0+ZGF0YSkg
IT0gTlVMTCkgeworCQlza2JfcmVzZXRfdHJhbnNwb3J0X2hlYWRlcihza2IpOworCQlpZiAoc29j
a19xdWV1ZV9lcnJfc2tiKHNrLCBza2IpID09IDApCisJCQlyZXR1cm47CisJfQorCWtmcmVlX3Nr
Yihza2IpOwogfQogCiB2b2lkIGlwX2xvY2FsX2Vycm9yKHN0cnVjdCBzb2NrICpzaywgaW50IGVy
ciwgX19iZTMyIGRhZGRyLCBfX2JlMTYgcG9ydCwgdTMyIGluZm8pCkBAIC0zMTQsOCArMzE2LDgg
QEAgdm9pZCBpcF9sb2NhbF9lcnJvcihzdHJ1Y3Qgc29jayAqc2ssIGludCBlcnIsIF9fYmUzMiBk
YWRkciwgX19iZTE2IHBvcnQsIHUzMiBpbmYKIAlzZXJyLT5hZGRyX29mZnNldCA9ICh1OCAqKSZp
cGgtPmRhZGRyIC0gc2tiX25ldHdvcmtfaGVhZGVyKHNrYik7CiAJc2Vyci0+cG9ydCA9IHBvcnQ7
CiAKLQlza2ItPmgucmF3ID0gc2tiLT50YWlsOwogCV9fc2tiX3B1bGwoc2tiLCBza2ItPnRhaWwg
LSBza2ItPmRhdGEpOworCXNrYl9yZXNldF90cmFuc3BvcnRfaGVhZGVyKHNrYik7CiAKIAlpZiAo
c29ja19xdWV1ZV9lcnJfc2tiKHNrLCBza2IpKQogCQlrZnJlZV9za2Ioc2tiKTsKZGlmZiAtLWdp
dCBhL25ldC9pcHY2L2RhdGFncmFtLmMgYi9uZXQvaXB2Ni9kYXRhZ3JhbS5jCmluZGV4IGZlYmE2
YjEuLmYxNmY0ZjAgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2RhdGFncmFtLmMKKysrIGIvbmV0L2lw
djYvZGF0YWdyYW0uYwpAQCAtMjMxLDggKzIzMSw4IEBAIHZvaWQgaXB2Nl9pY21wX2Vycm9yKHN0
cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW50IGVyciwKIAkJCQkgIHNrYl9u
ZXR3b3JrX2hlYWRlcihza2IpOwogCXNlcnItPnBvcnQgPSBwb3J0OwogCi0Jc2tiLT5oLnJhdyA9
IHBheWxvYWQ7CiAJX19za2JfcHVsbChza2IsIHBheWxvYWQgLSBza2ItPmRhdGEpOworCXNrYl9y
ZXNldF90cmFuc3BvcnRfaGVhZGVyKHNrYik7CiAKIAlpZiAoc29ja19xdWV1ZV9lcnJfc2tiKHNr
LCBza2IpKQogCQlrZnJlZV9za2Ioc2tiKTsKQEAgLTI2OCw4ICsyNjgsOCBAQCB2b2lkIGlwdjZf
bG9jYWxfZXJyb3Ioc3RydWN0IHNvY2sgKnNrLCBpbnQgZXJyLCBzdHJ1Y3QgZmxvd2kgKmZsLCB1
MzIgaW5mbykKIAlzZXJyLT5hZGRyX29mZnNldCA9ICh1OCAqKSZpcGgtPmRhZGRyIC0gc2tiX25l
dHdvcmtfaGVhZGVyKHNrYik7CiAJc2Vyci0+cG9ydCA9IGZsLT5mbF9pcF9kcG9ydDsKIAotCXNr
Yi0+aC5yYXcgPSBza2ItPnRhaWw7CiAJX19za2JfcHVsbChza2IsIHNrYi0+dGFpbCAtIHNrYi0+
ZGF0YSk7CisJc2tiX3Jlc2V0X3RyYW5zcG9ydF9oZWFkZXIoc2tiKTsKIAogCWlmIChzb2NrX3F1
ZXVlX2Vycl9za2Ioc2ssIHNrYikpCiAJCWtmcmVlX3NrYihza2IpOwotLSAKMS41LjAuMgoK
------=_Part_31321_33287616.1173822421912--
