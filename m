From: Kevin Constantine <kevin.constantine@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 15:55:12 -0800
Message-ID: <4B22DBE0.1020104@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com> <4B22C075.2020902@gmail.com> <4B22C4CD.8010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:56459 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935178AbZLKXzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:55:08 -0500
Received: by ywh3 with SMTP id 3so1430128ywh.22
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 15:55:14 -0800 (PST)
In-Reply-To: <4B22C4CD.8010402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Constantine wrote:
> On 12/11/2009 01:58 PM, Eric Dumazet wrote:
>> Le 11/12/2009 22:50, Kevin Constantine a =E9crit :
>>> On 12/11/2009 01:39 PM, Eric Dumazet wrote:
>>>> Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
>>>>> Hey Everyone-
>>>>>
>>>>> I've been playing with an ARM based linuxstamp
>>>>> http://opencircuits.com/Linuxstamp, and I've been seeing kernel p=
anics
>>>>> with both 2.6.28.3, and 2.6.30 within an hour or so of turning th=
e
>>>>> linuxstamp on.  The stack traces always seem to point at function=
s
>>>>> related to networking.  I've pasted a couple of the crash outputs=
=20
>>>>> below.
>>>>>    The linuxstamp isn't typically doing anything when the crashes=
=20
>>>>> occur,
>>>>> in fact it'll crash even if I haven't logged in.
>>>>>
>>>>> If I ifconfig the interface down, the linuxstamp stays up=20
>>>>> indefinitely.
>>>>>    Any pointers in one direction or another would be much appreci=
ated.
>>>>>
>>>>> I'm not sure if this is the right audience to help out or if the =
arm
>>>>> lists might be better.  But in any event, any help would be reall=
y
>>>>> appreciated.
>>>>>
>>>>>
>>>>> linuxstamp login: Unable to handle kernel paging request at virtu=
al
>>>>> address 183cb7b0
>>>>> pgd =3D c0004000
>>>>> [183cb7b0] *pgd=3D00000000
>>>>> Internal error: Oops: 0 [#1] PREEMPT
>>>>> Modules linked in:
>>>>> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
>>>>> PC is at 0x183cb7b0
>>>>> LR is at __udp4_lib_rcv+0x43c/0x72c
>>>>
>>>> Could you disassemble your vmlinux file, __udp4_lib_rcv function
>>>> around LR
>>>> <c024ff4c>, to see which function was called ? This function then=20
>>>> called
>>>> a wrong pointer (0x183cb7b0 not a kernel pointer)
>>>>
>>>> Maybe a kernel stack corruption, or bad ram, ...
>>>
>>> The vmlinux file I'm using has probably changed a number of times s=
ince
>>> then.  I'll get a fresh stack trace and disassemble that one.

Here's a new panic.  What would you like from the disassembled binary?

debian:~# Internal error: Oops - undefined instruction: 0 [#1] PREEMPT
Modules linked in: spidev atmel_spi
CPU: 0    Not tainted  (2.6.30-00002-g0148992 #16)
PC is at netif_receive_skb+0x284/0x2e8
LR is at kmem_cache_free+0x20/0x64
pc : [<c0214ec4>]    lr : [<c0089608>]    psr: a0000013
sp : c037feb0  ip : c037fe70  fp : c0384e60
r10: 00000008  r9 : c03bad00  r8 : 00000000
r7 : c1d2a800  r6 : c03a077c  r5 : c1e14980  r4 : c03bace0
r3 : c1d2a800  r2 : 00000062  r1 : c1d2a800  r0 : c1e14980
=46lags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: c000717f  Table: 21d58000  DAC: 00000017
Process swapper (pid: 0, stack limit =3D 0xc037e268)
Stack: (0xc037feb0 to 0xc0380000)
fea0:                                     00000000 c037fec0 00000001=20
c039e54c
fec0: 00083674 00000040 00000000 c039e534 c039e530 c0214fb4 fefff000=20
c039e54c
fee0: 00000040 c037e000 0000012c c039e530 c03bacf0 00083676 c039e540=20
c0213764
ff00: 00000001 00000103 0000000c c037e000 00000001 c03a8678 00000000=20
0000000a
ff20: 00000000 c0040358 c037e000 2001ccb8 00000000 00000018 00000000=20
00000018
ff40: 00000002 00000001 c037e000 2001ccb8 00000000 c0040428 00000018=20
c0022060
ff60: 00000000 ffffffff fefff000 c0022a3c 00000000 00000001 00000080=20
60000013
ff80: c00243a4 c037e000 c0381e7c c00243a4 c03a3ac8 41129200 2001ccb8=20
00000000
ffa0: fefff800 c037ffb8 c00243e0 c00243ec 60000013 ffffffff c00243a4=20
c0024368
ffc0: c03ab174 c03a3a90 c001ed30 c0381cc8 2001ccec c00088d4 c0008434=20
00000000
ffe0: 00000000 c001ed30 c0007175 c03a3af8 c001f134 20008034 00000000=20
00000000
[<c0214ec4>] (netif_receive_skb+0x284/0x2e8) from [<c0214fb4>]=20
(process_backlog+0x8c/0xd8)
[<c0214fb4>] (process_backlog+0x8c/0xd8) from [<c0213764>]=20
(net_rx_action+0x68/0x170)
[<c0213764>] (net_rx_action+0x68/0x170) from [<c0040358>]=20
(__do_softirq+0x74/0x104)
[<c0040358>] (__do_softirq+0x74/0x104) from [<c0040428>]=20
(irq_exit+0x40/0x58)
[<c0040428>] (irq_exit+0x40/0x58) from [<c0022060>] (_text+0x60/0x78)
[<c0022060>] (_text+0x60/0x78) from [<c0022a3c>] (__irq_svc+0x3c/0x80)
Exception stack(0xc037ff70 to 0xc037ffb8)
ff60:                                     00000000 00000001 00000080=20
60000013
ff80: c00243a4 c037e000 c0381e7c c00243a4 c03a3ac8 41129200 2001ccb8=20
00000000
ffa0: fefff800 c037ffb8 c00243e0 c00243ec 60000013 ffffffff=20

[<c0022a3c>] (__irq_svc+0x3c/0x80) from [<c00243e0>]=20
(default_idle+0x3c/0x54)
[<c00243e0>] (default_idle+0x3c/0x54) from [<c0024368>]=20
(cpu_idle+0x48/0x84)
[<c0024368>] (cpu_idle+0x48/0x84) from [<c00088d4>]=20
(start_kernel+0x208/0x254)
[<c00088d4>] (start_kernel+0x208/0x254) from [<20008034>] (0x20008034)
Code: 0a000007 e1a00005 e1a03007 e5951018 (e1a02006)
Kernel panic - not syncing: Fatal exception in interrupt
[<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b1dfc>]=20
(panic+0x3c/0x120)
[<c02b1dfc>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
[<c0026e60>] (die+0x154/0x180) from [<c0026f30>] (baddataabort+0x0/0xac=
)
[<c0026f30>] (baddataabort+0x0/0xac) from [<c037fe9c>] (0xc037fe9c)

