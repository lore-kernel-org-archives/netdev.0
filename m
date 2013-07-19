From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mod_timer: list_add corruption: WARNING: CPU: 1 PID: 0 at
 lib/list_debug.c:33 __list_add+0xbe/0xd0()
Date: Fri, 19 Jul 2013 15:40:37 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1307191523050.4089@ionos.tec.linutronix.de>
References: <51E557C0.2060602@linux.vnet.ibm.com> <alpine.DEB.2.02.1307191323150.4089@ionos.tec.linutronix.de> <51E92769.7090106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:49740 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760509Ab3GSNkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:40:45 -0400
In-Reply-To: <51E92769.7090106@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Jul 2013, Srivatsa S. Bhat wrote:
> On 07/19/2013 04:55 PM, Thomas Gleixner wrote:
> > On Tue, 16 Jul 2013, Srivatsa S. Bhat wrote:
> >> ------------[ cut here ]------------
> >> WARNING: CPU: 1 PID: 0 at lib/list_debug.c:33 __list_add+0xbe/0xd0()
> >> list_add corruption. prev->next should be next (ffff8810396b5568), but was           (null). (prev=ffff88102c1344c0).
> > 
> > Can you please enable debugobjects?
> > 
> 
> Sure Thomas, please find the new traces below, with
> debug objects enabled.
> Regards,
> Srivatsa S. Bhat
> 
> 
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 0 at lib/debugobjects.c:260 debug_print_object+0x8e/0xb0()
> ODEBUG: init active (active state 0) object type: timer_list hint: br_multicast_group_expired+0x0/0x110 [bridge]

So an active enqueued timer gets reinitialized. Not so pretty :)

>  [<ffffffff812b5aee>] debug_print_object+0x8e/0xb0
>  [<ffffffffa04247f0>] ? br_multicast_free_pg+0x20/0x20 [bridge]
>  [<ffffffff812b65e2>] ? __debug_object_init+0x42/0x3f0
>  [<ffffffff812b67bf>] __debug_object_init+0x21f/0x3f0
>  [<ffffffff812b69df>] debug_object_init+0x1f/0x30
>  [<ffffffff81060ea9>] init_timer_key+0x39/0x100
>  [<ffffffffa0425ec5>] br_ip4_multicast_query+0x155/0x380 [bridge]

Here is the offending call site. I leave that to the network wizards.

> [<ffffffffa0427eef>] br_multicast_ipv4_rcv+0x2cf/0x3d0 [bridge]
> [<ffffffff8162140b>] ? _raw_spin_unlock+0x2b/0x50
> [<ffffffffa0419a9b>] ? br_fdb_update+0x1db/0x2b0 [bridge]
> [<ffffffffa04284b5>] br_multicast_rcv+0x45/0x60 [bridge]
> [<ffffffffa041bdfe>] br_handle_frame_finish+0x16e/0x3c0 [bridge]
> [<ffffffffa041bac8>] br_handle_frame+0x238/0x400 [bridge]
> [<ffffffffa041b890>] ? br_del_bridge+0x80/0x80 [bridge]
> [<ffffffff81539ca7>] __netif_receive_skb_core+0x237/0x960
> [<ffffffff81539ade>] ? __netif_receive_skb_core+0x6e/0x960
> [<ffffffff8153a3f7>] __netif_receive_skb+0x27/0x70
> [<ffffffff8153c6fd>] netif_receive_skb+0x2d/0x210
> [<ffffffff81527e65>] ? __netdev_alloc_skb+0xa5/0x110
> [<ffffffffa0129a0f>] be_rx_compl_process+0xef/0x140 [be2net]
> [<ffffffffa0129dc2>] be_process_rx+0xe2/0x1a0 [be2net]
> [<ffffffffa0129fbd>] be_poll+0x13d/0x1d0 [be2net]
> [<ffffffff8153dab8>] net_rx_action+0xd8/0x2a0
> [<ffffffff81058e19>] __do_softirq+0x149/0x400
> [<ffffffff8105922d>] irq_exit+0xed/0x100
> [<ffffffff8162d206>] do_IRQ+0x66/0xe0

Thanks,

	tglx
