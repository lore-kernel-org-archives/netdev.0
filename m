From: Pascal <pascal@pascalhp.net>
Subject: [PATCH] Temporary patch for arpd
Date: Wed, 12 Oct 2016 05:50:36 +0800
Message-ID: <1006734637.20161012055036@pascalhp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="----------07805C23E328CB6AE"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20p.cmail.yandex.net ([77.88.31.15]:45251 "EHLO
        forward20p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754277AbcJKV7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 17:59:48 -0400
Received: from smtp3m.mail.yandex.net (smtp3m.mail.yandex.net [IPv6:2a02:6b8:0:2519::125])
        by forward20p.cmail.yandex.net (Yandex) with ESMTP id 09A2020E6B
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 00:50:00 +0300 (MSK)
Received: from smtp3m.mail.yandex.net (localhost.localdomain [127.0.0.1])
        by smtp3m.mail.yandex.net (Yandex) with ESMTP id D7C882840B16
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 00:49:59 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------------07805C23E328CB6AE
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello. I found wonderful bug in arpd daemon of iproute2 package.
Somehow arpd is absolute unworkable if run program with -f flag. On my
amd64 server i got "Segmentation fault" regardless -f mac-list.txt file
content.
The source of misc/arpd.c is not hard and i found that cause of
this bug is commit dd50247dba85255538d659551305b4bb75bcae62. I'm not
c++ developer, but i suppose segfault occured because argument of
dbase->put() has non-initialized dbdat.data argument.
Also arpd.c has strange condition "if (do_load || do_list)" that not
allows to run program with -f argument.
I did pull out the hexstring_a2n function from utils.c of previous commit
aeb199d5ce86c6c72decaac333cad5a7d7b38b3a and used it to populate
dbdat.data value after which program works fine.
I hurriedly make the patch that makes program alive. Please inspect
this problem, fix this bug and test program with -f key.
PS: sorry for my english =)
------------07805C23E328CB6AE
Content-Type: application/octet-stream;
 name="0001-Temporary-patch-for-arpd.patch"
Content-transfer-encoding: base64
Content-Disposition: attachment;
 filename="0001-Temporary-patch-for-arpd.patch"

RnJvbSA0MzMxNDdhNzMwM2M0MTg4NDViZGI1NjY4OTEwY2FhYmFiZjc5NDUzIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBQYXNjYWwgPHBhc2NhbEBwYXNjYWxocC5uZXQ+CkRh
dGU6IFdlZCwgMTIgT2N0IDIwMTYgMDM6MTM6NTMgKzA4MDAKU3ViamVjdDogW1BBVENIXSBU
ZW1wb3JhcnkgcGF0Y2ggZm9yIGFycGQKCi0tLQogbWlzYy9hcnBkLmMgfCA0NCArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKystLQogMSBmaWxlIGNoYW5nZWQs
IDQyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbWlzYy9h
cnBkLmMgYi9taXNjL2FycGQuYwppbmRleCBiZmFiNDQ1Li41NjdkZjViIDEwMDY0NAotLS0g
YS9taXNjL2FycGQuYworKysgYi9taXNjL2FycGQuYwpAQCAtNTg0LDYgKzU4NCw0MyBAQCBz
dGF0aWMgdm9pZCBzZW5kX3N0YXRzKHZvaWQpCiAJZG9fc3RhdHMgPSAwOwogfQogCitfX3U4
KiBoZXhzdHJpbmdfYTJuX29sZChjb25zdCBjaGFyICpzdHIsIF9fdTggKmJ1ZiwgaW50IGJs
ZW4pCit7CisJaW50IGNudCA9IDA7CisKKwlmb3IgKDs7KSB7CisJCXVuc2lnbmVkIGFjYzsK
KwkJY2hhciBjaDsKKworCQlhY2MgPSAwOworCisJCXdoaWxlICgoY2ggPSAqc3RyKSAhPSAn
OicgJiYgY2ggIT0gMCkgeworCQkJaWYgKGNoID49ICcwJyAmJiBjaCA8PSAnOScpCisJCQkJ
Y2ggLT0gJzAnOworCQkJZWxzZSBpZiAoY2ggPj0gJ2EnICYmIGNoIDw9ICdmJykKKwkJCQlj
aCAtPSAnYSctMTA7CisJCQllbHNlIGlmIChjaCA+PSAnQScgJiYgY2ggPD0gJ0YnKQorCQkJ
CWNoIC09ICdBJy0xMDsKKwkJCWVsc2UKKwkJCQlyZXR1cm4gTlVMTDsKKwkJCWFjYyA9IChh
Y2M8PDQpICsgY2g7CisJCQlzdHIrKzsKKwkJfQorCisJCWlmIChhY2MgPiAyNTUpCisJCQly
ZXR1cm4gTlVMTDsKKwkJaWYgKGNudCA8IGJsZW4pIHsKKwkJCWJ1ZltjbnRdID0gYWNjOwor
CQkJY250Kys7CisJCX0KKwkJaWYgKGNoID09IDApCisJCQlicmVhazsKKwkJKytzdHI7CisJ
fQorCWlmIChjbnQgPCBibGVuKQorCQltZW1zZXQoYnVmK2NudCwgMCwgYmxlbi1jbnQpOwor
CXJldHVybiBidWY7Cit9CiAKIGludCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJndikKIHsK
QEAgLTcxNSw4ICs3NTIsMTEgQEAgaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQog
CQkJCWdvdG8gZG9fYWJvcnQ7CiAJCQl9CiAKLQkJCWlmIChsbF9hZGRyX2EybigoY2hhciAq
KSBiMSwgNiwgbWFjYnVmKSAhPSA2KQorCQkJZGJkYXQuZGF0YSA9IGhleHN0cmluZ19hMm5f
b2xkKG1hY2J1ZiwgYjEsIDYpOworCQkJaWYgKGRiZGF0LmRhdGEgPT0gTlVMTCkgeworCQkJ
CWZwcmludGYoc3RkZXJyLCAiSW52YWxpZCBNQUMgYWRkcmVzczogXCIlc1wiXG4iLCBtYWNi
dWYpOwogCQkJCWdvdG8gZG9fYWJvcnQ7CisJCQl9CiAJCQlkYmRhdC5zaXplID0gNjsKIAog
CQkJaWYgKGRiYXNlLT5wdXQoZGJhc2UsICZkYmtleSwgJmRiZGF0LCAwKSkgewpAQCAtNzU0
LDcgKzc5NCw3IEBAIGludCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJndikKIAkJfQogCX0K
IAotCWlmIChkb19sb2FkIHx8IGRvX2xpc3QpCisJaWYgKGRvX2xpc3QpCiAJCWdvdG8gb3V0
OwogCiAJcHNldFswXS5mZCA9IHNvY2tldChQRl9QQUNLRVQsIFNPQ0tfREdSQU0sIDApOwot
LSAKMi43LjAud2luZG93cy4yCgo=
------------07805C23E328CB6AE--
