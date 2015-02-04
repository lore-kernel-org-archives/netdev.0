From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: 3.19-rc7 netconsole locking bug.
Date: Thu, 5 Feb 2015 00:41:32 +0100
Message-ID: <20150204234132.GA13621@kria>
References: <20150204193902.GB652@codemonkey.org.uk>
 <20150204195901.GA1682@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:37902 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756083AbbBDXld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 18:41:33 -0500
Content-Disposition: inline
In-Reply-To: <20150204195901.GA1682@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-04, 14:59:01 -0500, Dave Jones wrote:
> On Wed, Feb 04, 2015 at 02:39:02PM -0500, Dave Jones wrote:
>  > I set up netconsole this morning, and noticed when I rebooted the machine
>  > that this happens when it initializes..
>  > ... 
>  > 
>  > Despite the positive sounding last two lines, nothing actually gets logged
>  > over the netconsole.
> 
> After changing the boot process to modprobe netconsole later, I still
> see the same spew, but the console now works.
> However, shortly afterwards, there's another locking warning..
> 
> BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
> in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/1
> 4 locks held by swapper/1/0:
>  #0:  (rcu_read_lock){......}, at: [<ffffffffa07c7e98>] __netif_receive_skb_core+0x78/0xc00
>  #1:  (rcu_read_lock_bh){......}, at: [<ffffffffa084676f>] ip_finish_output2+0x9f/0xaa0
>  #2:  (rcu_read_lock_bh){......}, at: [<ffffffffa07cd9a3>] __dev_queue_xmit+0x63/0xbe0
>  #3:  (_xmit_ETHER#2){+.-...}, at: [<ffffffffa0801b3f>] sch_direct_xmit+0x11f/0x330
> irq event stamp: 136019
> hardirqs last  enabled at (136018): [<ffffffffa09b26da>] _raw_spin_unlock_irqrestore+0x5a/0xb0
> hardirqs last disabled at (136019): [<ffffffffa09b4cca>] irq_work_interrupt+0x6a/0x80
> softirqs last  enabled at (135536): [<ffffffffa0093fd5>] _local_bh_enable+0x25/0x80
> softirqs last disabled at (135537): [<ffffffffa00952ed>] irq_exit+0x27d/0x2e0
> CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.19.0-rc7+ #13 
>  ffffffffa0d3d363 2097f77ab05a8c13 ffff88007ec03160 ffffffffa09a5efa
>  0000000000000000 0000000000000000 ffff88007ec03190 ffffffffa00ca277
>  ffff88007ec03190 ffffffffa0d3d363 0000000000000068 0000000000000000
> Call Trace:
>  <IRQ>  [<ffffffffa09a5efa>] dump_stack+0x84/0xb9
>  [<ffffffffa00ca277>] ___might_sleep+0x2d7/0x390
>  [<ffffffffa00ca3b0>] __might_sleep+0x80/0x100
>  [<ffffffffa01123f7>] synchronize_irq+0x67/0x120
>  [<ffffffffa01125a9>] ? __disable_irq_nosync+0x69/0xc0
>  [<ffffffffa0112634>] disable_irq+0x34/0x50
>  [<ffffffffa06c93f5>] e1000_netpoll+0x55/0x1d0
>  [<ffffffffa07fc3f9>] netpoll_poll_dev+0x99/0x300
>  [<ffffffffa07fc83f>] netpoll_send_skb_on_dev+0x1df/0x470
>  [<ffffffffa07fcddc>] netpoll_send_udp+0x30c/0x5a0

This looks like the issue I started working on:

https://lkml.org/lkml/2014/10/29/523
https://marc.info/?l=linux-netdev&m=141813589016500&w=2

I will continue.  Sorry I let this slide.

-- 
Sabrina
