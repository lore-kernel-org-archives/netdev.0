From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 1 Dec 2010 15:36:13 +0800
Message-ID: <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
 <1291109699.2904.11.camel@edumazet-laptop> <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
 <1291127670.2904.96.camel@edumazet-laptop> <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636c5b5a251faba0496545d60
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63351 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab0LAHgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 02:36:35 -0500
Received: by fxm8 with SMTP id 8so1949018fxm.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 23:36:34 -0800 (PST)
In-Reply-To: <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636c5b5a251faba0496545d60
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 1, 2010 at 11:48 AM, Rui <wirelesser@gmail.com> wrote:
> one more question is
>
> if =A0RPS can spread the load into 4 separate cpus, how about the
> "packet_rcv(or tpacket_rcv)" ? will they run in parallel?
>

You mentioned RPS. But the current bpf doesn't have an instruction to
get the current CPU number. You can try this patch attached.

Maybe we can leverage the bpf and SO_REUSEPORT to direct the traffic
to the socket instance on the local CPU.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

--001636c5b5a251faba0496545d60
Content-Type: text/plain; charset=US-ASCII; name="bpf_cpu.diff"
Content-Disposition: attachment; filename="bpf_cpu.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gh5wivuz0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZmlsdGVyLmggYi9pbmNsdWRlL2xpbnV4L2ZpbHRl
ci5oCmluZGV4IDQ0N2E3NzUuLjM1ZGI0NGEgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvZmls
dGVyLmgKKysrIGIvaW5jbHVkZS9saW51eC9maWx0ZXIuaApAQCAtMTI0LDcgKzEyNCw4IEBAIHN0
cnVjdCBzb2NrX2Zwcm9nIHsJLyogUmVxdWlyZWQgZm9yIFNPX0FUVEFDSF9GSUxURVIuICovCiAj
ZGVmaW5lIFNLRl9BRF9NQVJLIAkyMAogI2RlZmluZSBTS0ZfQURfUVVFVUUJMjQKICNkZWZpbmUg
U0tGX0FEX0hBVFlQRQkyOAotI2RlZmluZSBTS0ZfQURfTUFYCTMyCisjZGVmaW5lIFNLRl9BRF9D
UFUJMzIKKyNkZWZpbmUgU0tGX0FEX01BWAkzNgogI2RlZmluZSBTS0ZfTkVUX09GRiAgICgtMHgx
MDAwMDApCiAjZGVmaW5lIFNLRl9MTF9PRkYgICAgKC0weDIwMDAwMCkKIApkaWZmIC0tZ2l0IGEv
bmV0L2NvcmUvZmlsdGVyLmMgYi9uZXQvY29yZS9maWx0ZXIuYwppbmRleCBhNDRkMjdmLi4zYmFh
M2Y3IDEwMDY0NAotLS0gYS9uZXQvY29yZS9maWx0ZXIuYworKysgYi9uZXQvY29yZS9maWx0ZXIu
YwpAQCAtNDEwLDYgKzQxMCw5IEBAIGxvYWRfYjoKIAkJCQlBID0gMDsKIAkJCWNvbnRpbnVlOwog
CQl9CisJCWNhc2UgU0tGX0FEX0NQVToKKwkJCUEgPSByYXdfc21wX3Byb2Nlc3Nvcl9pZCgpOwor
CQkJY29udGludWU7CiAJCWRlZmF1bHQ6CiAJCQlyZXR1cm4gMDsKIAkJfQo=
--001636c5b5a251faba0496545d60--
