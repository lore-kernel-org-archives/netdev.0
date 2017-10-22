From: Wei Wei <dotweiba@gmail.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Sat, 21 Oct 2017 21:56:49 -0400
Message-ID: <D2AD6D5B-3A05-48E7-A999-DECAB18A4649@gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
 <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
 <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:56788 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932295AbdJVB46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:56:58 -0400
In-Reply-To: <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have uploaded the VM core dump [1]. And I don=E2=80=99t know if these =
logs are helpful in the case of=20
failing to get the C reproducer currently.

[1] =
https://github.com/dotweiba/skb_clone_atomic_inc_bug/blob/master/vmcore.gz=


2017/10/21 20:24:32 reproducing crash 'unable to handle kernel paging =
request in __skb_clone': testing program (duration=3D24s, {Threaded:true =
Collide:true Repeat:true Procs:8 Sandb
ox:setuid Fault:false FaultCall:-1 FaultNth:0 EnableTun:true =
UseTmpDir:true HandleSegv:true WaitRepeat:true Debug:false Repro:true}): =
mmap-socket$inet_tcp-bind$inet-sendto$inet-se
ndto$inet-syz_emit_ethernet
2017/10/21 20:24:49 reproducing crash 'unable to handle kernel paging =
request in __skb_clone': program crashed: unable to handle kernel paging =
request in __skb_clone
2017/10/21 20:24:49 reproducing crash 'unable to handle kernel paging =
request in __skb_clone': extracting C reproducer
2017/10/21 20:24:49 reproducing crash 'unable to handle kernel paging =
request in __skb_clone': reproducing took 1h47m5.070207729s
2017/10/21 20:24:49 reproduction failed: no target compiler

Thanks,
Wei
> On 20 Oct 2017, at 11:39 AM, Willem de Bruijn =
<willemdebruijn.kernel@gmail.com> wrote:
>=20
> On Fri, Oct 20, 2017 at 11:14 AM, Dmitry Vyukov <dvyukov@google.com> =
wrote:
>> On Fri, Oct 20, 2017 at 4:40 PM, Wei Wei <dotweiba@gmail.com> wrote:
>>> Sadly, the syzkaller characterized it as a non-reproducible bug and =
there were empty
>>> repro files. But if manually executing in VM like this =
=E2=80=9C./syz-execprog -executor=3D
>>> ./syz-executor -repeat=3D0 -procs=3D16 -cover=3D0 crash-log=E2=80=9D, =
it crashed when executing exactly
>>> program 1056 using log0 provided.
>>>=20
>>> I failed to generate the C reproducer with syz-repro as it said =
=E2=80=9Cno target compiler=E2=80=9D
>>> in the final step. I would appreciate if you could give some hints.
>>=20
>> syzkaller tries to use aarch64-linux-gnu-gcc when cross-compiling to =
arm64:
>> =
https://github.com/google/syzkaller/blob/master/sys/targets/targets.go#L62=

>> Try to install g++-aarch64-linux-gnu.
>> Or how should it be done on your system?
>=20
> A core dump would also be helpful to root around in and inspect
> what those registers point to. Thanks for posting the various reports
> on github, btw.
