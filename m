From: =?ISO-8859-1?Q?Per_Dal=E9n?= <per.dalen@appeartv.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Mon, 02 Sep 2013 16:37:28 +0200
Message-ID: <5224A2A8.6000306@appeartv.com>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmx2.itpays.net ([193.107.29.97]:39813 "EHLO
	outmx2.itpays.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab3IBOhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 10:37:38 -0400
Received: from server12.itpays.net (unknown [193.107.28.22])
	by outmx2.itpays.net (Postfix) with SMTP id 56E17107AAD1
	for <netdev@vger.kernel.org>; Mon,  2 Sep 2013 16:37:36 +0200 (CEST)
In-Reply-To: <52249859.2040605@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2013 03:53 PM, Claudiu Manoil wrote:
> On 9/2/2013 4:21 PM, Per Dal=E9n wrote:
>>  > On Mo, 2013-04-29 at 15:20 +0200, Tino Keitel wrote:
>>  > > On Mo, 2013-04-29 at 15:14 +0200, Claudiu Manoil wrote:
>>  > >
>>  > > > The proposed fix (passes this test):
>>  > > > http://patchwork.ozlabs.org/patch/240365/
>>  > > >
>>  > > > Does it work for you?
>>
>> Hi,
>>
>> This patch do not work for me. I have the same problems that Tino on=
 my
>> card. My card is a Freescale P2020 and I use "iperf -c 10.10.51.36 -=
n
>> 100M -P 50" to trigger the error.
>> The network interface is set to 100M half duplex.
>> I have tested this using 3.4.35 and 3.4.60 kernel.
>>
>> NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit queue 0 timed out
>> ------------[ cut here ]------------
>> WARNING: at net/sched/sch_generic.c:256
>> Modules linked in:
>> NIP: c039bb94 LR: c039bb94 CTR: c02ee500
>> REGS: dffe7e60 TRAP: 0700   Not tainted  (3.4.60+)
>> MSR: 00029000 <CE,EE,ME>  CR: 40000084  XER: 20000000
>> TASK =3D df843200[0] 'swapper/1' THREAD: df864000 CPU: 1
>> GPR00: c039bb94 dffe7f10 df843200 00000046 00021000 ffffffff c02eecf=
0
>> 00029000
>> GPR08: 00000001 00008000 00463000 00003fff 80000028 00000000 0000000=
0
>> 00000004
>> GPR16: 00000001 df858e14 c051f1f4 00000001 df858c14 df858a14 df85881=
4
>> ffffffff
>> GPR24: 00000001 df813234 00000004 df8f9a00 c05e0000 c05e0000 df81300=
0
>> 00000000
>> NIP [c039bb94] dev_watchdog+0x2d4/0x2e4
>> LR [c039bb94] dev_watchdog+0x2d4/0x2e4
>> Call Trace:
>> [dffe7f10] [c039bb94] dev_watchdog+0x2d4/0x2e4 (unreliable)
>> [dffe7f40] [c003e944] run_timer_softirq+0x11c/0x20c
>> [dffe7fa0] [c00377dc] __do_softirq+0xe4/0x16c
>> [dffe7ff0] [c000c408] call_do_softirq+0x14/0x24
>> [df865e80] [c00043c4] do_softirq+0xb4/0xe4
>> [df865ea0] [c0037b4c] irq_exit+0xb0/0xcc
>> [df865eb0] [c0008958] timer_interrupt+0x188/0x1a4
>> [df865ee0] [c000db68] ret_from_except+0x0/0x18
>> --- Exception: 901 at cpu_idle+0x90/0xf4
>>      LR =3D cpu_idle+0x90/0xf4
>> [df865fa0] [c0007b30] cpu_idle+0x5c/0xf4 (unreliable)
>> [df865fc0] [c049d68c] start_secondary+0x2b0/0x2b4
>> [df865ff0] [c0001cf8] __secondary_start+0x30/0x84
>> Instruction dump:
>> 4e800421 80fe0244 4bffff40 7fc3f378 4bfeab6d 7fc4f378 7c651b78 3c60c=
055
>> 7fe6fb78 38633108 4cc63182 480fc889 <0fe00000> 39200001 993cea1a 4bf=
fffb4
>> ---[ end trace 4be011773b23dae3 ]---
>>
>>
>> When I revert "gianfar: Add support for byte queue limits.", commit
>> d8a0f1b0af67679bba886784de10d8c21acc4e0e, the network test work fine
>> without any "hiccup".
>> If the network interface is set to 1000M full duplex there's also no
>> "hiccup".
>>
>
> Hi,
>
> That patch wasn't approved (for good reasons).
> The proposed fix is currently under review:
> http://patchwork.ozlabs.org/patch/271242/
> "gianfar: Fix reported number of sent bytes to BQL"
>
> Does this one work for you? You might need to pull
> one recent gianfar clean-up patch from net-next in order
> to apply this one without incidents.
>

No, still the same error:

NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit queue 0 timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:256
Modules linked in:
NIP: c039ce0c LR: c039ce0c CTR: c02ef578
=2E..
4e800421 80fe0244 4bffff40 7fc3f378 4bfea9d1 7fc4f378 7c651b78 3c60c055
7fe6fb78 38635304 4cc63182 480fcddd <0fe00000> 39200001 993c0a3c 4bffff=
b4
---[ end trace 5f5e1e3c30024010 ]---


> Thanks,
> Claudiu
>
>
>

Thanks,
Per
