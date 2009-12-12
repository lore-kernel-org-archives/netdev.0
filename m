From: Kevin Constantine <kevin.constantine@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 17:06:36 -0800
Message-ID: <4B22EC9C.70207@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com> <4B22C075.2020902@gmail.com> <4B22C4CD.8010402@gmail.com> <4B22DBE0.1020104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:36013 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762855AbZLLBGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 20:06:37 -0500
Received: by ywh3 with SMTP id 3so1472532ywh.22
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 17:06:43 -0800 (PST)
In-Reply-To: <4B22DBE0.1020104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2009 03:55 PM, Kevin Constantine wrote:
> Kevin Constantine wrote:
>> On 12/11/2009 01:58 PM, Eric Dumazet wrote:
>>> Le 11/12/2009 22:50, Kevin Constantine a =E9crit :
>>>> On 12/11/2009 01:39 PM, Eric Dumazet wrote:
>>>>> Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
>>>>>> Hey Everyone-
>>>>>>
>>>>>> I've been playing with an ARM based linuxstamp
>>>>>> http://opencircuits.com/Linuxstamp, and I've been seeing kernel
>>>>>> panics
>>>>>> with both 2.6.28.3, and 2.6.30 within an hour or so of turning t=
he
>>>>>> linuxstamp on. The stack traces always seem to point at function=
s
>>>>>> related to networking. I've pasted a couple of the crash outputs
>>>>>> below.
>>>>>> The linuxstamp isn't typically doing anything when the crashes o=
ccur,
>>>>>> in fact it'll crash even if I haven't logged in.
>>>>>>
>>>>>> If I ifconfig the interface down, the linuxstamp stays up
>>>>>> indefinitely.
>>>>>> Any pointers in one direction or another would be much appreciat=
ed.
>>>>>>
>>>>>> I'm not sure if this is the right audience to help out or if the=
 arm
>>>>>> lists might be better. But in any event, any help would be reall=
y
>>>>>> appreciated.
>>>>>>
>>>>>>
>>>>>> linuxstamp login: Unable to handle kernel paging request at virt=
ual
>>>>>> address 183cb7b0
>>>>>> pgd =3D c0004000
>>>>>> [183cb7b0] *pgd=3D00000000
>>>>>> Internal error: Oops: 0 [#1] PREEMPT
>>>>>> Modules linked in:
>>>>>> CPU: 0 Not tainted (2.6.30-00002-g0148992 #13)
>>>>>> PC is at 0x183cb7b0
>>>>>> LR is at __udp4_lib_rcv+0x43c/0x72c
>>>>>
>>>>> Could you disassemble your vmlinux file, __udp4_lib_rcv function
>>>>> around LR
>>>>> <c024ff4c>, to see which function was called ? This function then
>>>>> called
>>>>> a wrong pointer (0x183cb7b0 not a kernel pointer)
>>>>>
>>>>> Maybe a kernel stack corruption, or bad ram, ...
>>>>
>>>> The vmlinux file I'm using has probably changed a number of times =
since
>>>> then. I'll get a fresh stack trace and disassemble that one.

Here's another crash from while the machine was sitting idly at the=20
login prompt.


debian login: Unable to handle kernel paging request at virtual address=
=20
183d84a0
pgd =3D c0004000
[183d84a0] *pgd=3D00000000
Internal error: Oops: 0 [#1] PREEMPT
Modules linked in: spidev atmel_spi
CPU: 0    Not tainted  (2.6.30-00002-g0148992 #16)
PC is at 0x183d84a0
LR is at __udp4_lib_rcv+0x43c/0x72c
pc : [<183d84a0>]    lr : [<c024e91c>]    psr: 40000013
sp : c037fe70  ip : c037fe20  fp : c0384e60
r10: 00000008  r9 : c03bad00  r8 : 00000000
r7 : c03bb0ec  r6 : c03baaa4  r5 : c1ec2500  r4 : c03a06f0
r3 : 00000000  r2 : c037e000  r1 : 00000075  r0 : 00000000
=46lags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: c000717f  Table: 21d58000  DAC: 00000017
Process swapper (pid: 0, stack limit =3D 0xc037e268)
Stack: (0xc037fe70 to 0xc0380000)
fe60:                                     c1d17800 c1da5c30 c1ec2500=20
c03a077c
fe80: c1d17800 c022dc58 c1d17800 00000001 c1df6400 c026e4d8 c03bace0=20
c1ec2500
fea0: c03a077c c1d17800 00000000 c0214ed0 c0037100 c0034388 00000001=20
c039e54c
fec0: 0005bedc 00000040 00000000 c039e534 c039e530 c0214fb4 00000001=20
c039e54c
fee0: 00000040 c037e000 0000012c c039e530 c03bacf0 0005bede c039e540=20
c0213764
ff00: c1ec2500 00000103 0000000c c037e000 00000001 c03a8678 00000000=20
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
Code: bad PC value.
Kernel panic - not syncing: Fatal exception in interrupt
[<c002895c>] (unwind_backtrace+0x0/0xdc) from [<c02b1dfc>]=20
(panic+0x3c/0x120)
[<c02b1dfc>] (panic+0x3c/0x120) from [<c0026e60>] (die+0x154/0x180)
[<c0026e60>] (die+0x154/0x180) from [<c0029848>]=20
(__do_kernel_fault+0x68/0x80)
[<c0029848>] (__do_kernel_fault+0x68/0x80) from [<c0029a74>]=20
(do_page_fault+0x214/0x234)
[<c0029a74>] (do_page_fault+0x214/0x234) from [<c0022b40>]=20
(__pabt_svc+0x40/0x80)
[<c0022b40>] (__pabt_svc+0x40/0x80) from [<c024e91c>]=20
(__udp4_lib_rcv+0x43c/0x72c)
[<c024e91c>] (__udp4_lib_rcv+0x43c/0x72c) from [<c039e54c>] (0xc039e54c=
)
