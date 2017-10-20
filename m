From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Fri, 20 Oct 2017 17:14:55 +0200
Message-ID: <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com> <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Wei Wei <dotweiba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:53172 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751618AbdJTPPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 11:15:16 -0400
Received: by mail-it0-f65.google.com with SMTP id j140so13793271itj.1
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 08:15:16 -0700 (PDT)
In-Reply-To: <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 4:40 PM, Wei Wei <dotweiba@gmail.com> wrote:
> Sadly, the syzkaller characterized it as a non-reproducible bug and there=
 were empty
>  repro files. But if manually executing in VM like this =E2=80=9C./syz-ex=
ecprog -executor=3D
> ./syz-executor -repeat=3D0 -procs=3D16 -cover=3D0 crash-log=E2=80=9D, it =
crashed when executing exactly
> program 1056 using log0 provided.
>
> I failed to generate the C reproducer with syz-repro as it said =E2=80=9C=
no target compiler=E2=80=9D
> in the final step. I would appreciate if you could give some hints.

syzkaller tries to use aarch64-linux-gnu-gcc when cross-compiling to arm64:
https://github.com/google/syzkaller/blob/master/sys/targets/targets.go#L62
Try to install g++-aarch64-linux-gnu.
Or how should it be done on your system?


> Thanks,
> Wei
>> On 20 Oct 2017, at 7:14 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>>
>> On Thu, Oct 19, 2017 at 10:16:08PM -0400, Wei Wei wrote:
>>> Hi all,
>>
>> Hi,
>>
>>> I have fuzzed v4.14-rc3 using syzkaller and found a bug similar to that=
 one [1].
>>> But the call trace isn=E2=80=99t the same. The atomic_inc() might handl=
e a corrupted
>>> skb_buff.
>>>
>>> The logs and config have been uploaded to my github repo [2].
>>>
>>> [1] https://lkml.org/lkml/2017/10/2/216
>>> [2] https://github.com/dotweiba/skb_clone_atomic_inc_bug
>>
>> These do look very similar to what I was hitting; all appear to be
>> misaligned atomics in the same path.
>>
>> I see that you have some empty repro files in [2]. If you have any
>> reproducers, would you mind sharing them?
>>
>> If any of those are smaller or more reliable than the one I was able to
>> generate [3], it might make it more obvious what's going on, and/or make
>> it simpler to come up with a plain C reproducer.
>>
>> Thanks,
>> Mark.
>>
>> [3] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-sk=
b_clone-misaligned-atomic/syzkaller.repro
>
> --
> You received this message because you are subscribed to the Google Groups=
 "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
