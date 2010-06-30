From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: [PATCH] Fix b44 RX FIFO overflow recovery.
Date: Wed, 30 Jun 2010 21:11:18 +0100
Message-ID: <AANLkTik2BadzkkVcmlhgWh6rcLDm1kEu0RDqWuILnwVZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001485f45476e938bf048a44f42e
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43158 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab0F3ULT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:11:19 -0400
Received: by fxm14 with SMTP id 14so772572fxm.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 13:11:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001485f45476e938bf048a44f42e
Content-Type: text/plain; charset=UTF-8

Hi,

This patch improves the recovery after a RX FIFO overflow on the b44
Ethernet NIC.
Before it would do a complete chip reset, resulting is loss of link
for a few seconds.
This patch improves this to do recovery in about 20ms without loss of link.

Kind Regards

James

b44: Handle RX FIFO overflow better.
Signed off by: James@superbug.co.uk

--001485f45476e938bf048a44f42e
Content-Type: text/plain; charset=US-ASCII; name="b44-fix-rx-overflow.txt"
Content-Disposition: attachment; filename="b44-fix-rx-overflow.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gb2ln9nm0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2I0NC5jIGIvZHJpdmVycy9uZXQvYjQ0LmMKaW5kZXgg
NjlkOWYzZC4uNzI1MzdjMSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvYjQ0LmMKKysrIGIvZHJp
dmVycy9uZXQvYjQ0LmMKQEAgLTg1MiwxMiArODUyLDQ2IEBAIHN0YXRpYyBpbnQgYjQ0X3BvbGwo
c3RydWN0IG5hcGlfc3RydWN0ICpuYXBpLCBpbnQgYnVkZ2V0KQogCQkvKiBzcGluX3VubG9jaygm
YnAtPnR4X2xvY2spOyAqLwogCX0KIAlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZicC0+bG9jaywg
ZmxhZ3MpOworCWlmIChicC0+aXN0YXQgJiBJU1RBVF9EU0NFKQorCXsKKwkJcHJpbnRrKEtFUk5f
SU5GTyAiYjQ0X3BvbGw6IElTVEFUX0RTQ0VcbiIpOworCX0KKwlpZiAoYnAtPmlzdGF0ICYgSVNU
QVRfREFUQUUpCisJeworCQlwcmludGsoS0VSTl9JTkZPICJiNDRfcG9sbDogSVNUQVRfREFUQUVc
biIpOworCX0KKwlpZiAoYnAtPmlzdGF0ICYgSVNUQVRfRFBFKQorCXsKKwkJcHJpbnRrKEtFUk5f
SU5GTyAiYjQ0X3BvbGw6IElTVEFUX0RQRVxuIik7CisJfQorCWlmIChicC0+aXN0YXQgJiBJU1RB
VF9SRFUpCisJeworCQlwcmludGsoS0VSTl9JTkZPICJiNDRfcG9sbDogSVNUQVRfUkRVXG4iKTsK
Kwl9CisJaWYgKGJwLT5pc3RhdCAmIElTVEFUX1JGTykKKwl7CisJCXByaW50ayhLRVJOX0lORk8g
ImI0NF9wb2xsOiBJU1RBVF9SRk9cbiIpOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmYnAtPmxvY2ss
IGZsYWdzKTsKKwkJYjQ0X2Rpc2FibGVfaW50cyhicCk7CisJCS8qIFRoaXMgcmVzZXRzIHRoZSBJ
U1RBVF9SRk8gZmxhZyAqLworCQlzc2JfZGV2aWNlX2VuYWJsZShicC0+c2RldiwgMCk7CisJCWI0
NF9pbml0X3JpbmdzKGJwKTsKKwkJYjQ0X2luaXRfaHcoYnAsIEI0NF9GVUxMX1JFU0VUX1NLSVBf
UEhZKTsKKwkJbmV0aWZfd2FrZV9xdWV1ZShicC0+ZGV2KTsKKwkJc3Bpbl91bmxvY2tfaXJxcmVz
dG9yZSgmYnAtPmxvY2ssIGZsYWdzKTsKKwkJd29ya19kb25lID0gMDsKKwl9CisJaWYgKGJwLT5p
c3RhdCAmIElTVEFUX1RGVSkKKwl7CisJCXByaW50ayhLRVJOX0lORk8gImI0NF9wb2xsOiBJU1RB
VF9URlVcbiIpOworCX0KKwogCiAJd29ya19kb25lID0gMDsKIAlpZiAoYnAtPmlzdGF0ICYgSVNU
QVRfUlgpCiAJCXdvcmtfZG9uZSArPSBiNDRfcngoYnAsIGJ1ZGdldCk7CiAKLQlpZiAoYnAtPmlz
dGF0ICYgSVNUQVRfRVJST1JTKSB7CisJaWYgKChicC0+aXN0YXQgJiBJU1RBVF9FUlJPUlMpICYm
ICEoYnAtPmlzdGF0ICYgSVNUQVRfUkZPKSkgewogCQlzcGluX2xvY2tfaXJxc2F2ZSgmYnAtPmxv
Y2ssIGZsYWdzKTsKIAkJYjQ0X2hhbHQoYnApOwogCQliNDRfaW5pdF9yaW5ncyhicCk7Cg==
--001485f45476e938bf048a44f42e--
