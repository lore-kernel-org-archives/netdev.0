From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: gianfar tries to free an irq from interrupt context
Date: Thu, 18 Dec 2008 20:56:04 +0300
Message-ID: <20081218175604.GA21494@oksana.dev.rtsoft.ru>
References: <6a6049b80812180938q927a8e6v9b2ca659c42442c@mail.gmail.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: netdev <netdev@vger.kernel.org>, linuxppc-dev@ozlabs.org
To: M B <super.firetwister@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:26508 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751803AbYLRR4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 12:56:09 -0500
Content-Disposition: inline
In-Reply-To: <6a6049b80812180938q927a8e6v9b2ca659c42442c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 06:38:26PM +0100, M B wrote:
> Hi,
> 
> I'm having Problems with the gianfar Ethernet. eth1 is working fine,
> but eth0 is making trouble. It's making trouble in u-boot as well, so
> it could as well be a hardware problem.
> First of all eth0 receives some frame errors (frame: in ifconfig), but
> eth1 doesn't.
> eth1 performs well under a ping flood, but eth0 produces the following
> WARN_ON() after some time.
> I'm using linux-2.6.26 ARCH ppc on a MPC8347 with 2 different 100MB PHYs.

This patch should fix the issue:

commit ab9399059bb85a94758f42fb25607e440e926cc6
Author: Sebastian Siewior <bigeasy@linutronix.de>
Date:   Tue Aug 19 21:12:45 2008 +0200

    net: don't grab a mutex within a timer context in gianfar

http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ab9399059bb85a94758f42fb25607e440e926cc6

> Is my Board just triggering this error or responsible for it?

The MAC could not send the packet within specified timeout value,
it might be normal, or not. This depends. But the WARN_ON() you
observe is a bug.

> Regards
> 
> Markus
> 
> ------------[ cut here ]------------
> Badness at kernel/irq/manage.c:441
> NIP: c003e9c0 LR: c014e5b4 CTR: c014e7f0
> REGS: c029bcd0 TRAP: 0700   Tainted: G        W  (2.6.26)
> MSR: 00021032 <ME,IR,DR>  CR: 44000028  XER: 00000000
> TASK = c027f7f8[0] 'swapper' THREAD: c029a000
> GPR00: 00000001 c029bd80 c027f7f8 00000022 cfca1080 ffffffff c013e298 c02f2cd8
> GPR08: cfca13e0 c029a000 02000100 fe024000 38c35770 ffffffff 0404f000 00000000
> GPR16: ffffffbf ffffffff c02f002c c0282344 00200200 00000000 c0303be8 c0303de8
> GPR24: c0303fe8 c03041e8 c029a034 c029bde8 cfca1080 00009032 00000022 cfca13e0
> NIP [c003e9c0] free_irq+0x2c/0x18c
> LR [c014e5b4] stop_gfar+0x70/0x11c
> Call Trace:
> [c029bd80] [00000102] 0x102 (unreliable)
> [c029bda0] [c014e5b4] stop_gfar+0x70/0x11c
> [c029bdc0] [c014e820] gfar_timeout+0x30/0x60
> [c029bdd0] [c01a4770] dev_watchdog+0xac/0x160
> [c029bde0] [c0021a18] run_timer_softirq+0x17c/0x220
> [c029be30] [c001cd84] __do_softirq+0x70/0xd0
> [c029be60] [c0008ff8] do_softirq+0x40/0x58
> [c029be70] [c001ca08] irq_exit+0x3c/0x5c
> [c029be80] [c0005790] timer_interrupt+0x204/0x234
> [c029bec0] [c00042b4] ret_from_except+0x0/0x14
> [c029bf80] [c000bdcc] cpu_idle+0xdc/0xec
> [c029bfa0] [c02057b4] rest_init+0x7c/0x90
> [c029bfc0] [c029d914] start_kernel+0x2b8/0x2cc
> [c029bff0] [000032c0] 0x32c0
> Instruction dump:
> 4e800020 7c0802a6 9421ffe0 bf810010 54290024 90010024 7c7e1b78 7c9c2378
> 8009000c 5400012e 7c0000d0 54000ffe <0f000000> 2b83007f 419d0144 1c030038
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
