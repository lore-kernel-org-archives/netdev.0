From: Dan Williams <dcbw@redhat.com>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Tue, 08 Aug 2006 07:40:18 -0400
Message-ID: <1155037218.2898.0.camel@localhost.localdomain>
References: <20060808094410.GA29313@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48588 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964860AbWHHLjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 07:39:02 -0400
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20060808094410.GA29313@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 12:44 +0300, Pekka Pietikainen wrote:
> Only aironet lockdep related report I could find was 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115406279721287&w=2

Shouldn't this be fixed by the wireless events patch that was a result
of the orinoco lockdep issues that davej posted about last week?

Dan

> this looks a bit different:
> 
> Linux version 2.6.17-1.2528.fc6 (brewbuilder@hs20-bc2-2.build.redhat.com) (gcc version 4.1.1 20060802 (Red Hat 4.1.1-14)) #1 SMP Sun Aug 6 01:43:42 EDT 2006
> 
> =================================
> [ INFO: inconsistent lock state ]
> ---------------------------------
> inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
> swapper/0 [HC1[1]:SC0[0]:HE0:SE1] takes:
>  (&list->lock){++..}, at: [<c05b2ed9>] skb_queue_tail+0x14/0x32
> {hardirq-on-W} state was registered at:
>   [<c043bfb9>] lock_acquire+0x4b/0x6a
>   [<c060f428>] _spin_lock_bh+0x1e/0x2d
>   [<c05ed45e>] udp_poll+0x49/0xce
>   [<c05ae678>] sock_poll+0x12/0x15
>   [<c04838da>] do_sys_poll+0x1f7/0x3c3
>   [<c0483ada>] sys_poll+0x34/0x36
>   [<c0403faf>] syscall_call+0x7/0xb
> irq event stamp: 516288
> hardirqs last  enabled at (516287): [<c0403ff7>] restore_nocheck+0x12/0x15
> hardirqs last disabled at (516288): [<c0404a3f>] common_interrupt+0x1b/0x2c
> softirqs last  enabled at (516272): [<c042941f>] __do_softirq+0xec/0xf2
> softirqs last disabled at (516261): [<c0406673>] do_softirq+0x5a/0xbe
> 
> other info that might help us debug this:
> no locks held by swapper/0.
> 
> stack backtrace:
>  [<c04051ee>] show_trace_log_lvl+0x58/0x159
>  [<c04057ea>] show_trace+0xd/0x10
>  [<c0405903>] dump_stack+0x19/0x1b
>  [<c043a402>] print_usage_bug+0x1ca/0x1d7
>  [<c043a748>] mark_lock+0x96/0x353
>  [<c043b463>] __lock_acquire+0x3b2/0x997
>  [<c043bfb9>] lock_acquire+0x4b/0x6a
>  [<c060f727>] _spin_lock_irqsave+0x22/0x32
>  [<c05b2ed9>] skb_queue_tail+0x14/0x32
>  [<c05ca889>] netlink_broadcast+0x1bf/0x28e
>  [<c05c234e>] wireless_send_event+0x28b/0x29d
>  [<f099a098>] airo_send_event+0x6c/0x76 [airo]
>  [<f099de2d>] airo_interrupt+0x210/0xff7 [airo]
>  [<c0450dd8>] handle_IRQ_event+0x20/0x4d
>  [<c0450e99>] __do_IRQ+0x94/0xef
>  [<c0406790>] do_IRQ+0xb9/0xcd
>  [<c0404a49>] common_interrupt+0x25/0x2c
> DWARF2 unwinder stuck at common_interrupt+0x25/0x2c
> Leftover inexact backtrace:
>  [<c04057ea>] show_trace+0xd/0x10
>  [<c0405903>] dump_stack+0x19/0x1b
>  [<c043a402>] print_usage_bug+0x1ca/0x1d7
>  [<c043a748>] mark_lock+0x96/0x353
>  [<c043b463>] __lock_acquire+0x3b2/0x997
>  [<c043bfb9>] lock_acquire+0x4b/0x6a
>  [<c060f727>] _spin_lock_irqsave+0x22/0x32
>  [<c05b2ed9>] skb_queue_tail+0x14/0x32
>  [<c05ca889>] netlink_broadcast+0x1bf/0x28e
>  [<c05c234e>] wireless_send_event+0x28b/0x29d
>  [<f099a098>] airo_send_event+0x6c/0x76 [airo]
>  [<f099de2d>] airo_interrupt+0x210/0xff7 [airo]
>  [<c0450dd8>] handle_IRQ_event+0x20/0x4d
>  [<c0450e99>] __do_IRQ+0x94/0xef
>  [<c0406790>] do_IRQ+0xb9/0xcd
>  [<c0404a49>] common_interrupt+0x25/0x2c
>  [<c0402cd9>] cpu_idle+0xa7/0xc1
>  [<c04005f5>] rest_init+0x23/0x26
>  [<c07aa81a>] start_kernel+0x3ab/0x3b3
>  [<c0400210>] 0xc0400210
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

