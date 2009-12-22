From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Tue, 22 Dec 2009 11:09:49 +0100
Message-ID: <4B309AED.7080601@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com> <4B22C075.2020902@gmail.com> <4B22C4CD.8010402@gmail.com> <4B22DBE0.1020104@gmail.com> <4B22EC9C.70207@gmail.com> <4B22F6A3.9080505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Kevin Constantine <kevin.constantine@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36655 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbZLVKKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 05:10:01 -0500
In-Reply-To: <4B22F6A3.9080505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2009 02:49, Kevin Constantine a =E9crit :
> Kevin Constantine wrote:
>> On 12/11/2009 03:55 PM, Kevin Constantine wrote:
>>> Kevin Constantine wrote:
>>>> On 12/11/2009 01:58 PM, Eric Dumazet wrote:
>>>>> Le 11/12/2009 22:50, Kevin Constantine a =E9crit :
>>>>>> On 12/11/2009 01:39 PM, Eric Dumazet wrote:
>>>>>>> Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
>>>>>>>> Hey Everyone-
>>>>>>>>
>>>>>>>> I've been playing with an ARM based linuxstamp
>>>>>>>> http://opencircuits.com/Linuxstamp, and I've been seeing kerne=
l
>>>>>>>> panics
>>>>>>>> with both 2.6.28.3, and 2.6.30 within an hour or so of turning=
 the
>>>>>>>> linuxstamp on. The stack traces always seem to point at functi=
ons
>>>>>>>> related to networking. I've pasted a couple of the crash outpu=
ts
>>>>>>>> below.
>>>>>>>> The linuxstamp isn't typically doing anything when the crashes
>>>>>>>> occur,
>>>>>>>> in fact it'll crash even if I haven't logged in.
>>>>>>>>
>>>>>>>> If I ifconfig the interface down, the linuxstamp stays up
>>>>>>>> indefinitely.
>>>>>>>> Any pointers in one direction or another would be much appreci=
ated.
>>>>>>>>
>>>>>>>> I'm not sure if this is the right audience to help out or if t=
he
>>>>>>>> arm
>>>>>>>> lists might be better. But in any event, any help would be rea=
lly
>>>>>>>> appreciated.
>>>>>>>>
>>>>>>>>
>>>>>>>> linuxstamp login: Unable to handle kernel paging request at vi=
rtual
>>>>>>>> address 183cb7b0
>>>>>>>> pgd =3D c0004000
>>>>>>>> [183cb7b0] *pgd=3D00000000
>>>>>>>> Internal error: Oops: 0 [#1] PREEMPT
>>>>>>>> Modules linked in:
>>>>>>>> CPU: 0 Not tainted (2.6.30-00002-g0148992 #13)
>>>>>>>> PC is at 0x183cb7b0
>>>>>>>> LR is at __udp4_lib_rcv+0x43c/0x72c
>>>>>>>
>>>>>>> Could you disassemble your vmlinux file, __udp4_lib_rcv functio=
n
>>>>>>> around LR
>>>>>>> <c024ff4c>, to see which function was called ? This function th=
en
>>>>>>> called
>>>>>>> a wrong pointer (0x183cb7b0 not a kernel pointer)
>>>>>>>
>>>>>>> Maybe a kernel stack corruption, or bad ram, ...
>>>>>>
>>>>>> The vmlinux file I'm using has probably changed a number of time=
s
>>>>>> since
>>>>>> then. I'll get a fresh stack trace and disassemble that one.
>>
>=20
> Here's yet another crash.  I recompiled the kernel to include slab
> debug.  This crash seems to implicate the at91ether driver.
>=20
>=20
>=20
> debian login: Unable to handle kernel paging request at virtual addre=
ss
> 60000013
> pgd =3D c0004000
> [60000013] *pgd=3D00000000
> Internal error: Oops: 805 [#1] PREEMPT
> Modules linked in:
> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #17)
> PC is at memset+0xb8/0xc0
> LR is at __alloc_skb+0x64/0x108
> pc : [<c017c118>]    lr : [<c0211a64>]    psr: 20000013
> sp : c0383ee8  ip : 5a5a5a5a  fp : ffc00048
> r10: 00000000  r9 : 00000002  r8 : c021268c
> r7 : c1c06d20  r6 : 000000e0  r5 : c1db2000  r4 : 60000013
> r3 : 00000003  r2 : 00000000  r1 : 00000088  r0 : 60000013
> Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: c000717f  Table: 21d78000  DAC: 00000017
> Process swapper (pid: 0, stack limit =3D 0xc0382268)
> Stack: (0xc0383ee8 to 0xc0384000)
> 3ee0:                   c0045164 c1c91e60 000000be c1d38800 c1d38b00
> 00000006
> 3f00: ffc00000 c021268c 00000004 c01c90d4 00000001 c1c91e60 00000000
> 00000000
> 3f20: 00000018 00000001 c0382000 2001cf90 00000000 c006112c 00000000
> c1c91e60
> 3f40: c038a37c 00000018 00000002 c0062e7c 00000018 00000000 00000018
> c0022050
> 3f60: 00000000 ffffffff fefff000 c0022a3c 00000000 00000001 00000080
> 60000013
> 3f80: c00243a4 c0382000 c0385ebc c00243a4 c03a7c68 41129200 2001cf90
> 00000000
> 3fa0: fefff800 c0383fb8 c00243e0 c00243ec 60000013 ffffffff c00243a4
> c0024368
> 3fc0: c03af314 c03a7c30 c001ed30 c0385d08 2001cfc4 c00088d4 c0008434
> 00000000
> 3fe0: 00000000 c001ed30 c0007175 c03a7c98 c001f134 20008034 00000000
> 00000000
> [<c017c118>] (memset+0xb8/0xc0) from [<c1d38800>] (0xc1d38800)
> Code: ba00001d e3530002 b4c02001 d4c02001 (e4c02001)
> Kernel panic - not syncing: Fatal exception in interrupt
> [<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b4c20>]
> (panic+0x3c/0x120)
> [<c02b4c20>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
> [<c0026e60>] (die+0x154/0x180) from [<c0029848>]
> (__do_kernel_fault+0x68/0x80)
> [<c0029848>] (__do_kernel_fault+0x68/0x80) from [<c0029a74>]
> (do_page_fault+0x214/0x234)
> [<c0029a74>] (do_page_fault+0x214/0x234) from [<c0022244>]
> (do_DataAbort+0x30/0x90)
> [<c0022244>] (do_DataAbort+0x30/0x90) from [<c00229e0>]
> (__dabt_svc+0x40/0x60)
> Exception stack(0xc0383ea0 to 0xc0383ee8)
> 3ea0: 60000013 00000088 00000000 00000003 60000013 c1db2000 000000e0
> c1c06d20
> 3ec0: c021268c 00000002 00000000 ffc00048 5a5a5a5a c0383ee8 c0211a64
> c017c118
> 3ee0: 20000013 ffffffff
> [<c00229e0>] (__dabt_svc+0x40/0x60) from [<c0211a64>]
> (__alloc_skb+0x64/0x108)
> [<c0211a64>] (__alloc_skb+0x64/0x108) from [<c021268c>]
> (dev_alloc_skb+0x1c/0x44)
> [<c021268c>] (dev_alloc_skb+0x1c/0x44) from [<c01c90d4>]
> (at91ether_interrupt+0x44/0x1b8)
> [<c01c90d4>] (at91ether_interrupt+0x44/0x1b8) from [<c006112c>]
> (handle_IRQ_event+0x40/0x110)
> [<c006112c>] (handle_IRQ_event+0x40/0x110) from [<c0062e7c>]
> (handle_level_irq+0xbc/0x134)
> [<c0062e7c>] (handle_level_irq+0xbc/0x134) from [<c0022050>]
> (_text+0x50/0x78)
> [<c0022050>] (_text+0x50/0x78) from [<c0022a3c>] (__irq_svc+0x3c/0x80=
)
> Exception stack(0xc0383f70 to 0xc0383fb8)
> 3f60:                                     00000000 00000001 00000080
> 60000013
> 3f80: c00243a4 c0382000 c0385ebc c00243a4 c03a7c68 41129200 2001cf90
> 00000000
> 3fa0: fefff800 c0383fb8 c00243e0 c00243ec 60000013 ffffffff
> [<c0022a3c>] (__irq_svc+0x3c/0x80) from [<c00243e0>]
> (default_idle+0x3c/0x54)
> [<c00243e0>] (default_idle+0x3c/0x54) from [<c0024368>]
> (cpu_idle+0x48/0x84)
> [<c0024368>] (cpu_idle+0x48/0x84) from [<c00088d4>]
> (start_kernel+0x208/0x254)
> [<c00088d4>] (start_kernel+0x208/0x254) from [<20008034>] (0x20008034=
)
>=20
>=20

After many private mails exchanged with Kevin,=20
it seems we have many unrelated corruptions happening in ARM, possibly =
at IRQ
handling or whatever. Its more likely an ARM problem more than a networ=
k stack issue.

I found an old commit mentioning a problem with LDM instruction that co=
uld be
interrupted/ restarted with a base register already changed -> we load =
registers with garbage.

author	Catalin Marinas <catalin.marinas@arm.com>=09
	Thu, 12 Jan 2006 16:53:51 +0000 (16:53 +0000)
committer	Russell King <rmk+kernel@arm.linux.org.uk>=09
	Thu, 12 Jan 2006 16:53:51 +0000 (16:53 +0000)
commit	90303b102353302e84758f245906368907e6a23b


Patch from Catalin Marinas

If the low interrupt latency mode is enabled for the CPU (from ARMv6
onwards), the ldm/stm instructions are no longer atomic. An ldm instruc=
tion
restoring the sp and pc registers can be interrupted immediately after =
sp
was updated but before the pc. If this happens, the CPU restores the ba=
se
register to the value before the ldm instruction but if the base regist=
er
is not sp, the interrupt routine will corrupt the stack and the restart=
ed
ldm instruction will load garbage.

Note that future ARM cores might always run in the low interrupt latenc=
y
mode.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

I found one instance of LDM instruction in 2.6.30 that could have same =
problem :

__switch_to:

=2E..
	ldm r4, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}


Kevin, any chance you can try 2.6.33 (or 2.6.32) instead of 2.6.30 ?

