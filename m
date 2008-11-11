From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Tue, 11 Nov 2008 20:19:16 +0100
Message-ID: <4919DAB4.7050009@krogh.cc>
References: <1225809909.10206.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:42067 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192AbYKKTpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 14:45:17 -0500
In-Reply-To: <1225809909.10206.90.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> Hi DaveM
> 
> I just bought the Sun x8 Express Quad Gigabit Ethernet Adapter you
> recommended to me.  It seem to work with the NIU driver (I can ping
> through the box), but I get a kernel warning when spamming it with
> pktgen...
> 
> Where do I go from here?
> And what do you want me to try?
> 
> Tested on kernels:
>   Kernel: 2.6.28-rc2
>   Kernel: 2.6.27
> 
> CPU:    Intel(R) Xeon(R) CPU E5335  @ 2.00GHz
> System: HP ProLiant DL380-G5
> 
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x21e/0x230()
> NETDEV WATCHDOG: eth2 (niu): transmit timed out
> Modules linked in: ehci_hcd ipmi_si ipmi_msghandler rng_core hpwdt
> uhci_hcd serio_raw hpilo bnx2 zlib_inflate niu
> Pid: 0, comm: swapper Not tainted 2.6.28-rc2-torvalds #2
> Call Trace:
>  [<c0126773>] warn_slowpath+0x63/0x80
>  [<c01201ce>] ? __enqueue_entity+0x8e/0xb0
>  [<c01202fd>] ? enqueue_task_fair+0x2d/0xe0
>  [<c0108ca9>] ? read_tsc+0x9/0x30
>  [<c0108ca9>] ? read_tsc+0x9/0x30
>  [<c013f52b>] ? getnstimeofday+0x3b/0xe0
>  [<c021f48e>] ? strlcpy+0x1e/0x60
>  [<c0326a8e>] dev_watchdog+0x21e/0x230
>  [<c0108ca9>] ? read_tsc+0x9/0x30
>  [<c013f52b>] ? getnstimeofday+0x3b/0xe0
>  [<c012f19b>] ? cascade+0x4b/0x60
>  [<c012f2cf>] run_timer_softirq+0x11f/0x190
>  [<c014399c>] ? tick_dev_program_event+0x3c/0xc0
>  [<c0326870>] ? dev_watchdog+0x0/0x230
>  [<c012b024>] __do_softirq+0x94/0x160
>  [<c013cc7a>] ? hrtimer_interrupt+0x14a/0x170
>  [<c012b12b>] do_softirq+0x3b/0x50
>  [<c012b335>] irq_exit+0x75/0x90
>  [<c01141ca>] smp_apic_timer_interrupt+0x5a/0x90
>  [<c013ca8a>] ? hrtimer_start+0x1a/0x20
>  [<c0103ee0>] apic_timer_interrupt+0x28/0x30
>  [<c0109cd5>] ? mwait_idle+0x35/0x40
>  [<c0101c1e>] cpu_idle+0x4e/0xa0
> ---[ end trace 28edc9a90244cfaf ]---
> niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
> niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
> niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
> niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
> niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting

Not that it solves the problem, but it looks awfully much like this 
problem I reported 6 months back on the niu-driver just using a 10GbitE 
card.

http://article.gmane.org/gmane.linux.kernel/677545/match=niu

I shifted to a binary driver i got from Matheos Worku and that
hasn't blown up since. (I expect that can rule out hardware problems).

Jesper
-- 
Jesper Krogh
