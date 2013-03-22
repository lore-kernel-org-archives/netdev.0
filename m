From: =?UTF-8?B?SsOhbiBTdGFuxI1law==?= <jan.stancek@gmail.com>
Subject: Re: NULL pointer deref, selinux_socket_unix_may_send+0x34/0x90
Date: Fri, 22 Mar 2013 16:48:32 +0100
Message-ID: <CAMpz-8bzjyBzk+mkaR-hHndtRZVyTb0LX8idEvypRV-itdSRYw@mail.gmail.com>
References: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com>
	<2355680.noQDWa4NlY@sifl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e89a8fb2030228f42b04d8856303
Cc: netdev@vger.kernel.org, eparis@redhat.com, sds@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:45718 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933594Ab3CVPsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:48:33 -0400
Received: by mail-ob0-f173.google.com with SMTP id dn14so4069136obc.4
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 08:48:32 -0700 (PDT)
In-Reply-To: <2355680.noQDWa4NlY@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--e89a8fb2030228f42b04d8856303
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 22, 2013 at 4:24 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Thursday, March 21, 2013 11:19:22 PM J=C3=A1n Stan=C4=8Dek wrote:
>> Hi,
>>
>> I'm occasionally seeing a panic early after system booted and while
>> systemd is starting other services.
>>
>> I made a reproducer which is quite reliable on my system (32 CPU Intel)
>> and can usually trigger this issue within a minute or two. I can reprodu=
ce
>> this issue with 3.9.0-rc3 as root or unprivileged user (see call trace
>> below).
>>
>> I'm attaching my reproducer and (experimental) patch, which fixes the
>> issue for me.
>
> Hi Jan,
>
> I've heard some similar reports over the past few years but I've never be=
en
> able to reproduce the problem and the reporters have never show enough
> interest to be able to help me diagnose the problem.  Your information ab=
out
> the size of the machine and the reproducer may help, thank you!
>
> I'll try your reproducer but since I don't happen to have a machine handy=
 that
> is the same size as yours would you mind trying the attached (also pasted
> inline for others to comment on) patch?  I can't promise it will solve yo=
ur
> problem but it was the best idea I could come up with a few years ago whe=
n I
> first became aware of the problem.  I think you are right in that there i=
s a
> race condition somewhere with the AF_UNIX sockets shutting down, I'm just=
 not
> yet certain where it is ...

Hi Paul,

thanks for reply, I'll try your patch and let you know.

I'm not certain about cause either, but patch I sent in last email
makes it go away,
so maybe that can help in some way.

I made a v2 of the reproducer (attached), which triggers the issue a lot fa=
ster
on 2 systems I tried (32 CPU and 4 CPU systems) - just in couple of seconds=
.

Regards,
Jan

--e89a8fb2030228f42b04d8856303
Content-Type: text/x-csrc; charset=US-ASCII; name="selinux_socket_unix_may_send_v2.c"
Content-Disposition: attachment;
	filename="selinux_socket_unix_may_send_v2.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_helic9761

LyogCiAqIHJlcHJvZHVjZXIgZm9yIEJ1ZyA4ODc2ODMgdjIKICogICB1bmFibGUgdG8gaGFuZGxl
IGtlcm5lbCBOVUxMIGluIHNlbGludXhfc29ja2V0X3VuaXhfbWF5X3NlbmQKICoKICogVGhpcyBy
ZXByb2R1Y2VyIGlzIGJhc2VkIG9uIHN5c3RlbWQvam91cm5hbGQgc291cmNlcywKICogaXQncyBw
b3NzaWJsZSB0aGVyZSBpcyB3YXkgdG8gbWFrZSBpdCBldmVuIG1vcmUgc2ltcGxlLCBidXQKICog
c2luY2UgSSB3YXMgYWJsZSB0byB0cmlnZ2VyIHRoZSBCdWcsIEkgcmF0aGVyIGtlcHQgaXQgYXMg
aXQgaXMuCiAqCiAqIGpzdGFuY2VrQHJlZGhhdC5jb20KICoKICogZ2NjIHNlbGludXhfc29ja2V0
X3VuaXhfbWF5X3NlbmQuYzsgLi9hLm91dAogKi8KCiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2lu
Y2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy91bi5oPgojaW5jbHVkZSA8c3RkaW8u
aD4KI2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5jbHVkZSA8ZXJybm8uaD4KI2luY2x1ZGUgPHNpZ25h
bC5oPgojaW5jbHVkZSA8bmV0L2lmLmg+CiNpbmNsdWRlIDxuZXRpbmV0L2luLmg+CiNpbmNsdWRl
IDxsaW51eC9uZXRsaW5rLmg+CiNpbmNsdWRlIDx1bmlzdGQuaD4KCiNkZWZpbmUgb2Zmc2V0b2Yo
dHlwZSwgbWVtYmVyKSAgX19idWlsdGluX29mZnNldG9mICh0eXBlLCBtZW1iZXIpCiNkZWZpbmUg
U05EQlVGX1NJWkUgKDgqMTAyNCoxMDI0KQoKaW50IHBpcGVmZFsyXTsKCnVuaW9uIHNvY2thZGRy
X3VuaW9uIHsKCXN0cnVjdCBzb2NrYWRkciBzYTsKCXN0cnVjdCBzb2NrYWRkcl9pbiBpbjQ7Cglz
dHJ1Y3Qgc29ja2FkZHJfaW42IGluNjsKCXN0cnVjdCBzb2NrYWRkcl91biB1bjsKCXN0cnVjdCBz
b2NrYWRkcl9ubCBubDsKCXN0cnVjdCBzb2NrYWRkcl9zdG9yYWdlIHN0b3JhZ2U7Cn07CgppbnQg
ZmRfaW5jX3NuZGJ1ZihpbnQgZmQsIHNpemVfdCBuKSB7CglpbnQgciwgdmFsdWU7Cglzb2NrbGVu
X3QgbCA9IHNpemVvZih2YWx1ZSk7CgoJciA9IGdldHNvY2tvcHQoZmQsIFNPTF9TT0NLRVQsIFNP
X1NOREJVRiwgJnZhbHVlLCAmbCk7CglpZiAociA+PSAwICYmCgkJCWwgPT0gc2l6ZW9mKHZhbHVl
KSAmJgoJCQkoc2l6ZV90KSB2YWx1ZSA+PSBuKjIpCgkJcmV0dXJuIDA7CgoJdmFsdWUgPSAoaW50
KSBuOwoJciA9IHNldHNvY2tvcHQoZmQsIFNPTF9TT0NLRVQsIFNPX1NOREJVRiwgJnZhbHVlLCBz
aXplb2YodmFsdWUpKTsKCWlmIChyIDwgMCkKCQlyZXR1cm4gLWVycm5vOwoKCXJldHVybiAxOwp9
CgppbnQgY2xpZW50KGludCBpZCwgaW50IGxvb3BzKQp7CglpbnQgZmQ7CgljaGFyIGRhdGFbMTAy
NF0gPSAiMTIzNDU2Nzg5IjsKCXN0cnVjdCBpb3ZlYyAqdzsKCWludCBpOwoJaW50IGogPSAwOwoJ
aW50IG4gPSAxOwoJaW50IHJldDsKCWludCBkdW1teTsKCXN0cnVjdCBzb2NrYWRkcl91biBzYTsK
CXN0cnVjdCBtc2doZHIgbWg7Cgl1bmlvbiB7CgkJc3RydWN0IGNtc2doZHIgY21zZ2hkcjsKCQl1
aW50OF90IGJ1ZltDTVNHX1NQQUNFKHNpemVvZihpbnQpKV07Cgl9IGNvbnRyb2w7CgoKCW1lbXNl
dCgmc2EsIDAsIHNpemVvZihzYSkpOwoJc2Euc3VuX2ZhbWlseSA9IEFGX1VOSVg7CglzbnByaW50
ZihzYS5zdW5fcGF0aCwgc2l6ZW9mKHNhLnN1bl9wYXRoKSwgIi90bXAvc29ja2V0X3Rlc3QlZCIs
IGlkKTsKCgl3ID0gbWFsbG9jKHNpemVvZihzdHJ1Y3QgaW92ZWMpICogbiAqIDUgKyAzKTsKCXdb
al0uaW92X2Jhc2UgPSBkYXRhOwoJd1tqXS5pb3ZfbGVuID0gMTA7CglqKys7CgoJbWVtc2V0KCZj
b250cm9sLCAwLCBzaXplb2YoY29udHJvbCkpOwoJbWgubXNnX2NvbnRyb2wgPSAmY29udHJvbDsK
CW1oLm1zZ19jb250cm9sbGVuID0gc2l6ZW9mKGNvbnRyb2wpOwoKCW1lbXNldCgmbWgsIDAsIHNp
emVvZihtaCkpOwoJbWgubXNnX25hbWUgPSAmc2E7CgltaC5tc2dfbmFtZWxlbiA9IG9mZnNldG9m
KHN0cnVjdCBzb2NrYWRkcl91biwgc3VuX3BhdGgpICsgc3RybGVuKHNhLnN1bl9wYXRoKTsKCW1o
Lm1zZ19pb3YgPSB3OwoJbWgubXNnX2lvdmxlbiA9IDE7CgoJZm9yIChpID0gMDsgaSA8IGxvb3Bz
OyBpKyspIHsKCQlmZCA9IHNvY2tldChBRl9VTklYLCBTT0NLX0RHUkFNfFNPQ0tfQ0xPRVhFQywg
MCk7CgkJaWYgKGZkIDwgMCkKCQkJcmV0dXJuIC1lcnJubzsKCgkJcmV0ID0gZmRfaW5jX3NuZGJ1
ZihmZCwgU05EQlVGX1NJWkUpOwoJCWlmIChyZXQgPCAwKQoJCQlwZXJyb3IoImZkX2luY19zbmRi
dWYiKTsKCgkJd3JpdGUocGlwZWZkWzFdLCAmZHVtbXksIDEpOwoJCXJldCA9IHNlbmRtc2coZmQs
ICZtaCwgTVNHX05PU0lHTkFMKTsKCQkvKmlmIChyZXQgPCAwKQoJCQlwZXJyb3IoInJldDoiKTsK
CQllbHNlCgkJCXByaW50ZigicmV0OiAlZFxuIiwgcmV0KTsqLwoKCQljbG9zZShmZCk7Cgl9Cn0K
CmludCBzZXJ2ZXIoaW50IGlkLCBpbnQgbG9vcHMpCnsKCWludCBmZCwgcmV0LCBzdGF0dXM7Cgl1
bmlvbiBzb2NrYWRkcl91bmlvbiBzYTsKCWludCBkdW1teTsKCWludCBpOwoKCXNhLnVuLnN1bl9m
YW1pbHkgPSBBRl9VTklYOwoJc25wcmludGYoc2EudW4uc3VuX3BhdGgsIHNpemVvZihzYS51bi5z
dW5fcGF0aCksICIvdG1wL3NvY2tldF90ZXN0JWQiLCBpZCk7CgoJZm9yIChpID0gMDsgaSA8IGxv
b3BzOyBpKyspIHsKCQl1bmxpbmsoc2EudW4uc3VuX3BhdGgpOwoJCWZkID0gc29ja2V0KEFGX1VO
SVgsIFNPQ0tfREdSQU18U09DS19DTE9FWEVDfFNPQ0tfTk9OQkxPQ0ssIDApOwoJCWlmIChmZCA8
IDApCgkJCXBlcnJvcigic29ja2V0Iik7CgoJCWludCBvbmUgPSAxOwoJCXJldCA9IHNldHNvY2tv
cHQoZmQsIFNPTF9TT0NLRVQsIFNPX1BBU1NDUkVELCAmb25lLCBzaXplb2Yob25lKSk7CgkJaWYg
KHJldCA8IDApCgkJCXBlcnJvcigic2V0c29ja29wdCAxIik7CgkKCQlyZXQgPSBzZXRzb2Nrb3B0
KGZkLCBTT0xfU09DS0VULCBTT19QQVNTU0VDLCAmb25lLCBzaXplb2Yob25lKSk7CgkJaWYgKHJl
dCA8IDApCgkJCXBlcnJvcigic2V0c29ja29wdCAyIik7CgkKCQlyZXQgPSBzZXRzb2Nrb3B0KGZk
LCBTT0xfU09DS0VULCBTT19USU1FU1RBTVAsICZvbmUsIHNpemVvZihvbmUpKTsKCQlpZiAocmV0
IDwgMCkKCQkJcGVycm9yKCJzZXRzb2Nrb3B0IDMiKTsKCQoJCXJldCA9IGJpbmQoZmQsICZzYS5z
YSwgb2Zmc2V0b2YodW5pb24gc29ja2FkZHJfdW5pb24sIHVuLnN1bl9wYXRoKSArIHN0cmxlbihz
YS51bi5zdW5fcGF0aCkpOwoJCWlmIChyZXQgPCAwKQoJCQlwZXJyb3IoImJpbmQiKTsKCQoJCXJl
YWQocGlwZWZkWzBdLCAmZHVtbXksIDEpOwoJCWNsb3NlKGZkKTsKCX0KfQoKCnZvaWQgY2hpbGQo
aW50IGxvb3BzKQp7CglpbnQgaTsKCWludCBteXBpZCA9IGdldHBpZCgpOwoKCWlmIChwaXBlKHBp
cGVmZCkgPCAwKSB7CgkJcGVycm9yKCJwaXBlIik7CgkJcmV0dXJuOwoJfQoKCWlmIChmb3JrKCkg
PT0gMCkgewoJCWNsaWVudChteXBpZCwgbG9vcHMpOwoJCWV4aXQoMCk7Cgl9IGVsc2UgewoJCXNl
cnZlcihteXBpZCwgbG9vcHMpOwoJfQp9CgppbnQgbWFpbigpCnsKCWludCBpID0gMDsKCWludCBj
cHVzID0gc3lzY29uZihfU0NfTlBST0NFU1NPUlNfT05MTikqNDsKCWludCBzdGF0dXM7CgkKCWZv
ciAoaSA9IDA7IGkgPCBjcHVzOyBpKyspIHsKCQlpZiAoZm9yaygpID09IDApIHsKCQkJY2hpbGQo
MTAwMDAwKTsKCQkJZXhpdCgwKTsKCQl9Cgl9CgoJZm9yIChpID0gMDsgaSA8IGNwdXM7IGkrKykg
ewoJCXdhaXQoJnN0YXR1cyk7Cgl9CgoJcHJpbnRmKCJEb25lLlxuIik7CglyZXR1cm4gMDsKfQoK
--e89a8fb2030228f42b04d8856303--
