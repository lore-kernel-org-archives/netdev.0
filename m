From: Wei Wei <dotweiba@gmail.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Fri, 20 Oct 2017 10:40:38 -0400
Message-ID: <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        willemb@google.com, syzkaller@googlegroups.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sadly, the syzkaller characterized it as a non-reproducible bug and =
there were empty
 repro files. But if manually executing in VM like this =
=E2=80=9C./syz-execprog -executor=3D
./syz-executor -repeat=3D0 -procs=3D16 -cover=3D0 crash-log=E2=80=9D, it =
crashed when executing exactly=20
program 1056 using log0 provided.

I failed to generate the C reproducer with syz-repro as it said =E2=80=9Cn=
o target compiler=E2=80=9D
in the final step. I would appreciate if you could give some hints.

Thanks,
Wei
> On 20 Oct 2017, at 7:14 AM, Mark Rutland <mark.rutland@arm.com> wrote:
>=20
> On Thu, Oct 19, 2017 at 10:16:08PM -0400, Wei Wei wrote:
>> Hi all,
>=20
> Hi,
>=20
>> I have fuzzed v4.14-rc3 using syzkaller and found a bug similar to =
that one [1].
>> But the call trace isn=E2=80=99t the same. The atomic_inc() might =
handle a corrupted=20
>> skb_buff.
>>=20
>> The logs and config have been uploaded to my github repo [2].
>>=20
>> [1] https://lkml.org/lkml/2017/10/2/216
>> [2] https://github.com/dotweiba/skb_clone_atomic_inc_bug
>=20
> These do look very similar to what I was hitting; all appear to be
> misaligned atomics in the same path.
>=20
> I see that you have some empty repro files in [2]. If you have any
> reproducers, would you mind sharing them?
>=20
> If any of those are smaller or more reliable than the one I was able =
to
> generate [3], it might make it more obvious what's going on, and/or =
make
> it simpler to come up with a plain C reproducer.
>=20
> Thanks,
> Mark.
>=20
> [3] =
https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-skb_clon=
e-misaligned-atomic/syzkaller.repro
