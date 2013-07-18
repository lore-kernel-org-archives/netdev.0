From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: BCM5721 transmit queue 0 timed out
Date: Thu, 18 Jul 2013 09:36:18 -0700
Message-ID: <51E81982.5090200@broadcom.com>
References: <51E7AB9D.3010803@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Net Dev" <netdev@vger.kernel.org>
To: "Cosmin GIRADU" <cosmin.giradu@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4701 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758607Ab3GRQgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jul 2013 12:36:46 -0400
In-Reply-To: <51E7AB9D.3010803@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 7/18/2013 1:47 AM, Cosmin GIRADU wrote:
> Hi,
>
> I need some help with the following situation:
>
> We keep getting random lockups on our BCM5721 cards (most of them are
> LOMs, multiple machines, running multiple kernel versions between 3.4
> and 3.10.1), when the traffic is high (above 300Mbit/s). The hardware is
> dual port "Tigon3 [partno(BCM95721) rev 4201] (PCI Express)" with 5750
> chip inside.

Cosmin,
Can you send the full register dump from the kernel log?

Also can you give more details about the system and the traffic? Is it 
reproducible with something like netperf?

Nithin.


> The lockups look like this:
>
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x25a/0x270()
> NETDEV WATCHDOG: eth2 (tg3): transmit queue 0 timed out
> Modules linked in: ip_gre ip_tunnel gre loop processor thermal_sys
> i2c_i801 lpc_ich coretemp button mfd_core
> CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.1.htb.104 #1
> Hardware name: IBM IBM System x3250 -[43654BG]-/M31ip, BIOS IBM BIOS
> Version 1.33-[G9E133AUS-1.33]- 08/28/2007
>   ffffffff81781f16 ffff88003fd03d98 ffffffff8152f6eb ffff88003fd03dd8
>   ffffffff8103659b ffff88003fd03dd8 ffff88003d3f0000 ffff88003e103d00
>   0000000000000005 0000000000000001 ffff88003e0a9428 ffff88003fd03e38
> Call Trace:
>   <IRQ>  [<ffffffff8152f6eb>] dump_stack+0x19/0x1e
>   [<ffffffff8103659b>] warn_slowpath_common+0x6b/0xa0
>   [<ffffffff81036671>] warn_slowpath_fmt+0x41/0x50
>   [<ffffffff81471d6a>] dev_watchdog+0x25a/0x270
>   [<ffffffff81471b10>] ? __netdev_watchdog_up+0x80/0x80
>   [<ffffffff8104312c>] call_timer_fn+0x2c/0x90
>   [<ffffffff81043369>] run_timer_softirq+0x1d9/0x1f0
>   [<ffffffff8103d351>] __do_softirq+0xd1/0x1a0
>   [<ffffffff8103d4c5>] irq_exit+0x65/0x80
>   [<ffffffff81024399>] smp_apic_timer_interrupt+0x69/0xa0
>   [<ffffffff81533b0a>] apic_timer_interrupt+0x6a/0x70
>   <EOI>  [<ffffffff8100a126>] ? default_idle+0x6/0x10
>   [<ffffffff8100a2f6>] arch_cpu_idle+0x16/0x20
>   [<ffffffff8106afd5>] cpu_startup_entry+0xa5/0x200
>   [<ffffffff818c57ce>] start_secondary+0x267/0x269
> ---[ end trace d3a202af040f84f0 ]---
> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=1400 enable_bit=2
> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=c00 enable_bit=2
> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=1400 enable_bit=2
> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=c00 enable_bit=2
>
> As far as I can tell the "tg3_stop_block timed out" is thrown when the
> card is being reset after the hang timer expires and is quite harmless
> (hope I'm reading it right). However said hangs do tend to be more
> frequent as the amount of traffic rises, and that does interfere with
> operation.
>
> As a workaround, disabling scatter-gather on the offending cards stops
> the problem from reappearing, however I'd like to get to the bottom of
> this once and for all.
>
