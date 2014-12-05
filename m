From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Fri, 5 Dec 2014 11:03:44 +0100
Message-ID: <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6d8bbe6269720509753257
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34175 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbaLEKEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 05:04:06 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so431349pdi.2
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 02:04:04 -0800 (PST)
In-Reply-To: <20141204165609.GJ18045@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6d8bbe6269720509753257
Content-Type: text/plain; charset=UTF-8

On Thu, Dec 4, 2014 at 5:56 PM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> On Thu, Dec 04, 2014 at 05:41:38PM +0100, Yegor Yefremov wrote:
>> I have following problem. My systems reboots at high network load
>> after this commit (found via git bissect):
>>
>> commit 55601c9f24670ba926ebdd4d712ac3b177232330
>> Author: Felipe Balbi <balbi@ti.com>
>> Date:   Mon Sep 8 17:54:58 2014 -0700
>>
>>     arm: omap: intc: switch over to linear irq domain
>>
>>     now that we don't need to support legacy board-files,
>>     we can completely switch over to a linear irq domain
>>     and make use of irq_alloc_domain_generic_chips() to
>>     allocate all generic irq chips for us.
>>
>>     Signed-off-by: Felipe Balbi <balbi@ti.com>
>>     Signed-off-by: Tony Lindgren <tony@atomide.com>
>>
>> and I get following error messages:
>>
>> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>
> irq 0 ? Weird, that's not a valid IRQ.
>
>> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> ->action():   (null)
>>    IRQ_NOPROBE set
>>  IRQ_NOREQUEST set
>> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> ->action():   (null)
>>    IRQ_NOPROBE set
>>  IRQ_NOREQUEST set
>> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> ->action():   (null)
>>    IRQ_NOPROBE set
>>  IRQ_NOREQUEST set
>> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
>> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
>> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
>> ->action():   (null)
>>
>> My system: am335x with fast ethernet on the first slave and gigabit
>> Ethernet on second CPSW slave. This issue occurs, when I ran nuttcp
>> with default settings.
>>
>> With commit above I can at least see these messages, but 3.18-rc7 for
>> example reboots without any messages.
>>
>> Any idea?
>
> if you take v3.18-rc7 and just revert that commit, does the problem go
> away ?

git revert failed as the driver has more changes meanwhile or I'm
missing some params. I've tried to force the driver to use legacy
routines, but then I don't get pass U-Boot's "Starting kernel ..." See
attached patch.

Compiler used:

Linux version 3.18.0-rc7 (...) (gcc version 4.8.3 20140320
(prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #309 SMP Fri Dec 5
10:59:38 CET 2014

Btw, what am335x based hardware do you have? I can run tests on both
BBB and am335x-evmsk.

Yegor

--047d7b6d8bbe6269720509753257
Content-Type: application/octet-stream; name="0001-Irq-patch-revert.patch"
Content-Disposition: attachment; filename="0001-Irq-patch-revert.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i3bdq4nn1

RnJvbSA4ODlhMDU4OGU4ODQwODMzOTllNjQ0OTA5ZWMzOWU4MzRmMzdjNGQzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZZWdvciBZZWZyZW1vdiA8eWVnb3JzbGlzdHNAZ29vZ2xlbWFp
bC5jb20+CkRhdGU6IEZyaSwgNSBEZWMgMjAxNCAxMDo1NDozNyArMDEwMApTdWJqZWN0OiBbUEFU
Q0hdIElycSBwYXRjaCByZXZlcnQKCi0tLQogZHJpdmVycy9pcnFjaGlwL2lycS1vbWFwLWludGMu
YyB8ICAgMjEgKysrKysrKysrKysrKysrLS0tLS0tCiAxIGZpbGVzIGNoYW5nZWQsIDE1IGluc2Vy
dGlvbnMoKyksIDYgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9pcnFjaGlwL2ly
cS1vbWFwLWludGMuYyBiL2RyaXZlcnMvaXJxY2hpcC9pcnEtb21hcC1pbnRjLmMKaW5kZXggMjg3
MThkMy4uYTYwYTBhYyAxMDA2NDQKLS0tIGEvZHJpdmVycy9pcnFjaGlwL2lycS1vbWFwLWludGMu
YworKysgYi9kcml2ZXJzL2lycWNoaXAvaXJxLW9tYXAtaW50Yy5jCkBAIC0xODYsNiArMTg2LDcg
QEAgdm9pZCBvbWFwM19pbnRjX3N1c3BlbmQodm9pZCkKIAlvbWFwX2Fja19pcnEoTlVMTCk7CiB9
CiAKKyNpZiAwCiBzdGF0aWMgaW50IF9faW5pdCBvbWFwX2FsbG9jX2djX29mKHN0cnVjdCBpcnFf
ZG9tYWluICpkLCB2b2lkIF9faW9tZW0gKmJhc2UpCiB7CiAJaW50IHJldDsKQEAgLTIyMiw3ICsy
MjMsNyBAQCBzdGF0aWMgaW50IF9faW5pdCBvbWFwX2FsbG9jX2djX29mKHN0cnVjdCBpcnFfZG9t
YWluICpkLCB2b2lkIF9faW9tZW0gKmJhc2UpCiAKIAlyZXR1cm4gMDsKIH0KLQorI2VuZGlmCiBz
dGF0aWMgdm9pZCBfX2luaXQgb21hcF9hbGxvY19nY19sZWdhY3kodm9pZCBfX2lvbWVtICpiYXNl
LAogCQl1bnNpZ25lZCBpbnQgaXJxX3N0YXJ0LCB1bnNpZ25lZCBpbnQgbnVtKQogewpAQCAtMjQz
LDYgKzI0NCw3IEBAIHN0YXRpYyB2b2lkIF9faW5pdCBvbWFwX2FsbG9jX2djX2xlZ2FjeSh2b2lk
IF9faW9tZW0gKmJhc2UsCiAJCQlJUlFfTk9SRVFVRVNUIHwgSVJRX05PUFJPQkUsIDApOwogfQog
CisjaWYgMAogc3RhdGljIGludCBfX2luaXQgb21hcF9pbml0X2lycV9vZihzdHJ1Y3QgZGV2aWNl
X25vZGUgKm5vZGUpCiB7CiAJaW50IHJldDsKQEAgLTI2Miw2ICsyNjQsNyBAQCBzdGF0aWMgaW50
IF9faW5pdCBvbWFwX2luaXRfaXJxX29mKHN0cnVjdCBkZXZpY2Vfbm9kZSAqbm9kZSkKIAogCXJl
dHVybiByZXQ7CiB9CisjZW5kaWYKIAogc3RhdGljIGludCBfX2luaXQgb21hcF9pbml0X2lycV9s
ZWdhY3kodTMyIGJhc2UpCiB7CkBAIC0zMDEsMTMgKzMwNCwxMyBAQCBzdGF0aWMgaW50IF9faW5p
dCBvbWFwX2luaXRfaXJxKHUzMiBiYXNlLCBzdHJ1Y3QgZGV2aWNlX25vZGUgKm5vZGUpCiB7CiAJ
aW50IHJldDsKIAotCWlmIChub2RlKQorCS8qaWYgKG5vZGUpCiAJCXJldCA9IG9tYXBfaW5pdF9p
cnFfb2Yobm9kZSk7Ci0JZWxzZQorCWVsc2UqLwogCQlyZXQgPSBvbWFwX2luaXRfaXJxX2xlZ2Fj
eShiYXNlKTsKIAotCWlmIChyZXQgPT0gMCkKLQkJb21hcF9pcnFfZW5hYmxlX3Byb3RlY3Rpb24o
KTsKKwkvKmlmIChyZXQgPT0gMCkKKwkJb21hcF9pcnFfZW5hYmxlX3Byb3RlY3Rpb24oKTsqLwog
CiAJcmV0dXJuIHJldDsKIH0KQEAgLTM3Niw2ICszNzksNyBAQCBzdGF0aWMgaW50IF9faW5pdCBp
bnRjX29mX2luaXQoc3RydWN0IGRldmljZV9ub2RlICpub2RlLAogCQkJICAgICBzdHJ1Y3QgZGV2
aWNlX25vZGUgKnBhcmVudCkKIHsKIAlpbnQgcmV0OworCXN0cnVjdCByZXNvdXJjZSByZXM7CiAK
IAlvbWFwX25yX3BlbmRpbmcgPSAzOwogCW9tYXBfbnJfaXJxcyA9IDk2OwpAQCAtMzgzLDEyICsz
ODcsMTcgQEAgc3RhdGljIGludCBfX2luaXQgaW50Y19vZl9pbml0KHN0cnVjdCBkZXZpY2Vfbm9k
ZSAqbm9kZSwKIAlpZiAoV0FSTl9PTighbm9kZSkpCiAJCXJldHVybiAtRU5PREVWOwogCisJaWYg
KG9mX2FkZHJlc3NfdG9fcmVzb3VyY2Uobm9kZSwgMCwgJnJlcykpIHsKKyAgICAgICAgICAgICAg
ICBXQVJOKDEsICJ1bmFibGUgdG8gZ2V0IGludGMgcmVnaXN0ZXJzXG4iKTsKKyAgICAgICAgICAg
ICAgICByZXR1cm4gLUVJTlZBTDsKKyAgICAgICAgfQorCiAJaWYgKG9mX2RldmljZV9pc19jb21w
YXRpYmxlKG5vZGUsICJ0aSxhbTMzeHgtaW50YyIpKSB7CiAJCW9tYXBfbnJfaXJxcyA9IDEyODsK
IAkJb21hcF9ucl9wZW5kaW5nID0gNDsKIAl9CiAKLQlyZXQgPSBvbWFwX2luaXRfaXJxKC0xLCBv
Zl9ub2RlX2dldChub2RlKSk7CisJcmV0ID0gb21hcF9pbml0X2lycShyZXMuc3RhcnQsIG9mX25v
ZGVfZ2V0KG5vZGUpKTsKIAlpZiAocmV0IDwgMCkKIAkJcmV0dXJuIHJldDsKIAotLSAKMS43LjcK
Cg==
--047d7b6d8bbe6269720509753257--
