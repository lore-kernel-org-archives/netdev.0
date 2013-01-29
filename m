From: Vikram Narayanan <vikram186@gmail.com>
Subject: Re: i.Mx6Quad - eth0: tx queue full!
Date: Tue, 29 Jan 2013 22:03:31 +0530
Message-ID: <5107F9DB.2000402@gmail.com>
References: <5106B7EE.3040603@gmail.com> <5106D5D4.2090200@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Ungerer <gregungerer@westnet.com.au>,
	shawn.guo@linaro.org, LAK <linux-arm-kernel@lists.infradead.org>,
	=?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:34678 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab3A2Qds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 11:33:48 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so303983dae.7
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 08:33:47 -0800 (PST)
In-Reply-To: <5106D5D4.2090200@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2013 1:17 AM, Troy Kisky wrote:
> On 1/28/2013 10:39 AM, Vikram Narayanan wrote:
>> Running the latest head <linux-2.6.git> on an i.Mx6Quad based platform
>> gives me the below error when flooded with ping requests.
>>
>> == Start log ==
>> [ 2555.004031] ------------[ cut here ]------------
>> [ 2555.009740] WARNING: at net/sched/sch_generic.c:254
>> dev_watchdog+0x298/0x2b8()
>> [ 2555.018721] NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out
>
> I think the tx interrupt status bit was lost. The packets were
> transmitted, but the interrupt never
> happened. The controller should have been reset here, but perhaps a bug
> with the reset code.
> Are you using the mainline kernel, or a version Freescale's kernel.

I tried with both the kernels. Freescale's and mainline results in the 
same error.

> mainline fec_restart does not reset tx_full
>
> You can try adding
> fep->tx_full = 0;

With this there was no improvement.

> to fec_restart, though it would be better to call fec_enet_tx in
> fec_timeout
> and skip the call to fec_restart if it returns some packets.

fec_enet_tx returns void, how do I check for the return packets.
I'm sorry, I couldn't get your point here.

>
>> [ 2555.026733] Modules linked in:
>> [ 2555.030598] Backtrace:
>> [ 2555.034252] [<800119c8>] (dump_backtrace+0x0/0x10c) from
>> [<803b8494>] (dump_stack+0x18/0x1c)
>> [ 2555.044438]  r6:000000fe r5:80302f64 r4:80503dd0 r3:80510e80
>> [ 2555.052019] [<803b847c>] (dump_stack+0x0/0x1c) from [<8001df08>]
>> (warn_slowpath_common+0x54/0x6c)
>> [ 2555.062679] [<8001deb4>] (warn_slowpath_common+0x0/0x6c) from
>> [<8001dfc4>] (warn_slowpath_fmt+0x38/0x40)
>> [ 2555.073936]  r8:8052ebf1 r7:805040c0 r6:00000000 r5:8f9771d4
>> r4:8f977000
>> r3:00000009
>> [ 2555.084816] [<8001df8c>] (warn_slowpath_fmt+0x0/0x40) from
>> [<80302f64>] (dev_watchdog+0x298/0x2b8)
>> [ 2555.095535]  r3:8f977000 r2:8049f6d4
>> [ 2555.099868] [<80302ccc>] (dev_watchdog+0x0/0x2b8) from [<8002acf8>]
>> (call_timer_fn.isra.33+0x2c/0x8c)
>> [ 2555.110794] [<8002accc>] (call_timer_fn.isra.33+0x0/0x8c) from
>> [<8002af48>] (run_timer_softirq+0x1f0/0x204)
>> [ 2555.122240]  r7:80571114 r6:805040c0 r5:00000000 r4:80570900
>> [ 2555.129894] [<8002ad58>] (run_timer_softirq+0x0/0x204) from
>> [<80025750>] (__do_softirq+0xc8/0x180)
>> [ 2555.140599] [<80025688>] (__do_softirq+0x0/0x180) from [<80025b40>]
>> (irq_exit+0x88/0x90)
>> [ 2555.150492] [<80025ab8>] (irq_exit+0x0/0x90) from [<8000ec58>]
>> (handle_IRQ+0x44/0x98)
>> [ 2555.160112]  r4:804ffde0 r3:00000220
>> [ 2555.164848] [<8000ec14>] (handle_IRQ+0x0/0x98) from [<80008540>]
>> (gic_handle_irq+0x30/0x64)
>> [ 2555.174956]  r6:80503f28 r5:8050a518 r4:f400010c r3:00000000
>> [ 2555.182694] [<80008510>] (gic_handle_irq+0x0/0x64) from
>> [<8000df80>] (__irq_svc+0x40/0x50)
>> [ 2555.192737] Exception stack(0x80503f28 to 0x80503f70)
>> [ 2555.198639] 3f20:                   8052f150 a0000093 00000000
>> 00000000 80502000 8052ed08
>> [ 2555.208600] 3f40: 8050a4f4 803bfaec 8050df00 412fc09a 80502000
>> 80503f7c 80503f80 80503f70
>> [ 2555.218584] 3f60: 8000eee4 8000eee8 60000013 ffffffff
>> [ 2555.224730]  r7:80503f5c r6:ffffffff r5:60000013 r4:8000eee8
>> [ 2555.232292] [<8000eeb8>] (default_idle+0x0/0x38) from [<8000f0d8>]
>> (cpu_idle+0xcc/0x114)
>> [ 2555.242204] [<8000f00c>] (cpu_idle+0x0/0x114) from [<803b3718>]
>> (rest_init+0x64/0x7c)
>> [ 2555.251858] [<803b36b4>] (rest_init+0x0/0x7c) from [<804cc7dc>]
>> (start_kernel+0x258/0x298)
>> [ 2555.261963] [<804cc584>] (start_kernel+0x0/0x298) from [<10008078>]
>> (0x10008078)
>> [ 2555.271167] ---[ end trace 3d2ffb53e6fe41f3 ]---
>> [ 2555.277270] eth0: tx queue full!.
>> [ 2555.288776] eth0: tx queue full!.
>> [ 2555.293594] eth0: tx queue full!.
>> [ 2555.297944] eth0: tx queue full!.
>> [ 2555.302229] eth0: tx queue full!.
> All the packet have been transmitted but the transmit queue is full, so
> no more
> tx interrupts can happen to replace the previously lost tx interrupt.
>
> I've seen MII interrupts clear the TX interrupt status bit.
>

Do you suspect the MAC <-> PHY interconnect? I'm having an MII interface.

Regards,
Vikram
