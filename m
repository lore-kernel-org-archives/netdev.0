From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: reproducable panic eviction work queue
Date: Sat, 18 Jul 2015 12:02:37 +0200
Message-ID: <55AA243D.5020306@cumulusnetworks.com>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl> <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com> <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38473 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbGRKCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 06:02:40 -0400
Received: by wicmv11 with SMTP id mv11so59745959wic.1
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 03:02:39 -0700 (PDT)
In-Reply-To: <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2015 11:01 AM, Johan Schuijt wrote:
> Yes, we already found these and are included in our kernel, but even =
with these patches we still receive the panic.
>=20
> - Johan
>=20
>=20
>> On 18 Jul 2015, at 10:56, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
>>
>> On Fri, 2015-07-17 at 21:18 +0000, Johan Schuijt wrote:
>>> Hey guys,=20
>>>
>>>
>>> We=E2=80=99re currently running into a reproducible panic in the ev=
iction work
>>> queue code when we pin al our eth* IRQ to different CPU cores (in
>>> order to scale our networking performance for our virtual servers).
>>> This only occurs in kernels >=3D 3.17 and is a result of the follow=
ing
>>> change:
>>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.gi=
t/commit/?h=3Dlinux-3.18.y&id=3Db13d3cbfb8e8a8f53930af67d1ebf05149f32c2=
4
>>>
>>>
>>> The race/panic we see seems to be the same as, or similar to:
>>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.gi=
t/commit/?h=3Dlinux-3.18.y&id=3D65ba1f1ec0eff1c25933468e1d238201c0c2cb2=
9
>>>
>>>
>>> We can confirm that this is directly exposed by the IRQ pinning sin=
ce
>>> disabling this stops us from being able to reproduce this case :)
>>>
>>>
>>> How te reproduce: in our test-setup we have 4 machines generating U=
DP
>>> packets which are send to the vulnerable host. These all have a MTU=
 of
>>> 100 (for test purposes) and send UDP packets of a size of 256 bytes=
=2E
>>> Within half an hour you will see the following panic:
>>>
>>>
>>> crash> bt
>>> PID: 56     TASK: ffff885f3d9fc210  CPU: 9   COMMAND: "kworker/9:0"
>>> #0 [ffff885f3da03b60] machine_kexec at ffffffff8104a1f7
>>> #1 [ffff885f3da03bb0] crash_kexec at ffffffff810db187
>>> #2 [ffff885f3da03c80] oops_end at ffffffff81015140
>>> #3 [ffff885f3da03ca0] general_protection at ffffffff814f6c88
>>>    [exception RIP: inet_evict_bucket+281]
>>>    RIP: ffffffff81480699  RSP: ffff885f3da03d58  RFLAGS: 00010292
>>>    RAX: ffff885f3da03d08  RBX: dead0000001000a8  RCX:
>>> ffff885f3da03d08
>>>    RDX: 0000000000000006  RSI: ffff885f3da03ce8  RDI:
>>> dead0000001000a8
>>>    RBP: 0000000000000002   R8: 0000000000000286   R9:
>>> ffff88302f401640
>>>    R10: 0000000080000000  R11: ffff88602ec0c138  R12:
>>> ffffffff81a8d8c0
>>>    R13: ffff885f3da03d70  R14: 0000000000000000  R15:
>>> ffff881d6efe1a00
>>>    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>>> #4 [ffff885f3da03db0] inet_frag_worker at ffffffff8148075a
>>> #5 [ffff885f3da03e10] process_one_work at ffffffff8107be19
>>> #6 [ffff885f3da03e60] worker_thread at ffffffff8107c6e3
>>> #7 [ffff885f3da03ed0] kthread at ffffffff8108103e
>>> #8 [ffff885f3da03f50] ret_from_fork at ffffffff814f4d7c
>>>
>>>
>>> We would love to receive your input on this matter.
>>>
>>>
>>> Thx in advance,
>>>
>>>
>>> - Johan
>>
>> Check commits 65ba1f1ec0eff1c25933468e1d238201c0c2cb29 &
>> d70127e8a942364de8dd140fe73893efda363293
>>
>> Also please send your mails in text format, not html, and CC netdev =
( I
>> did here)
>>
>>>
>>>
>>
>>
>=20
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
>=20

Thank you for the report, I will try to reproduce this locally
Could you please post the full crash log ? Also could you test
with a clean current kernel from Linus' tree or Dave's -net ?
These are available at:
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
respectively.

One last question how many IRQs do you pin i.e. how many cores
do you actively use for receive ?
