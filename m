From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 bridge hw csum error since 3.0.6
Date: Wed, 5 Oct 2011 08:38:26 -0700
Message-ID: <20111005083826.4032a697@nehalam.linuxnetplumber.net>
References: <4E8C5D88.4020500@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tobias Powalowski <tobias.powalowski@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38955 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757910Ab1JEPia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 11:38:30 -0400
In-Reply-To: <4E8C5D88.4020500@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Oct 2011 15:37:12 +0200
Tobias Powalowski <tobias.powalowski@googlemail.com> wrote:

> Hi,
> here the log of the new 3.0.6 kernel and my sky2 ethernet card:
> eth0: hw csum failure.
> [   47.462091] Pid: 0, comm: swapper Not tainted 3.0-ARCH #1
> [   47.462094] Call Trace:
> [   47.462097]  <IRQ>  [<ffffffff81334ca2>] netdev_rx_csum_fault+0x42/0x50
> [   47.462112]  [<ffffffff8132b700>] __skb_checksum_complete_head+0x60/0x70
> [   47.462116]  [<ffffffff8132b721>] __skb_checksum_complete+0x11/0x20
> [   47.462128]  [<ffffffffa05bcfba>] br_multicast_rcv+0x32a/0x1350 [bridge]
> [   47.462134]  [<ffffffff8136758e>] ? ip_rcv+0x21e/0x2f0
> [   47.462140]  [<ffffffff8121aa96>] ? cpumask_next_and+0x36/0x50
> [   47.462145]  [<ffffffff8104a64d>] ? select_task_rq_fair+0x53d/0x9e0
> [   47.462152]  [<ffffffffa05b3fd0>] ? br_handle_local_finish+0x50/0x50
> [bridge]
> [   47.462159]  [<ffffffffa05b3fd0>] ? br_handle_local_finish+0x50/0x50
> [bridge]
> [   47.462165]  [<ffffffffa05b4087>] br_handle_frame_finish+0xb7/0x2a0
> [bridge]
> [   47.462172]  [<ffffffffa05b9e88>]
> br_nf_pre_routing_finish_ipv6+0x108/0x160 [bridge]
> [   47.462178]  [<ffffffffa05ba8dc>] br_nf_pre_routing+0x55c/0x710 [bridge]
> [   47.462183]  [<ffffffff81055b10>] ? try_to_wake_up+0x290/0x290
> [   47.462188]  [<ffffffff8135f7f5>] nf_iterate+0x85/0xc0
> [   47.462194]  [<ffffffffa05b3fd0>] ? br_handle_local_finish+0x50/0x50
> [bridge]
> [   47.462198]  [<ffffffff8135f8ae>] nf_hook_slow+0x7e/0x130
> [   47.462204]  [<ffffffffa05b3fd0>] ? br_handle_local_finish+0x50/0x50
> [bridge]
> [   47.462210]  [<ffffffff81380da1>] ? tcp_rcv_established+0x4d1/0x830
> [   47.462216]  [<ffffffffa05b4420>] br_handle_frame+0x1b0/0x270 [bridge]
> [   47.462222]  [<ffffffffa05b4270>] ?
> br_handle_frame_finish+0x2a0/0x2a0 [bridge]
> [   47.462227]  [<ffffffff8133415e>] __netif_receive_skb+0x16e/0x660
> [   47.462232]  [<ffffffff81334e2d>] netif_receive_skb+0xad/0xc0
> [   47.462236]  [<ffffffff813357a0>] napi_skb_finish+0x50/0x70
> [   47.462240]  [<ffffffff81335875>] napi_gro_receive+0xb5/0xc0
> [   47.462256]  [<ffffffffa028cce3>] sky2_poll+0x693/0xce0 [sky2]
> [   47.462260]  [<ffffffff8136758e>] ? ip_rcv+0x21e/0x2f0
> [   47.462265]  [<ffffffff81334302>] ? __netif_receive_skb+0x312/0x660
> [   47.462269]  [<ffffffff81335109>] net_rx_action+0x149/0x300
> [   47.462274]  [<ffffffff81063e40>] __do_softirq+0xb0/0x270
> [   47.462279]  [<ffffffff813f711c>] call_softirq+0x1c/0x30
> [   47.462283]  [<ffffffff8100da75>] do_softirq+0x65/0xa0
> [   47.462287]  [<ffffffff8106434e>] irq_exit+0x9e/0xc0
> [   47.462291]  [<ffffffff813f7973>] do_IRQ+0x63/0xe0
> [   47.462296]  [<ffffffff813f5653>] common_interrupt+0x13/0x13
> [   47.462298]  <EOI>  [<ffffffff81014375>] ? mwait_idle+0x95/0x2e0
> [   47.462307]  [<ffffffff8100a21a>] cpu_idle+0xba/0x100
> [   47.462311]  [<ffffffff813d31f2>] rest_init+0x96/0xa4
> [   47.462315]  [<ffffffff81748c23>] start_kernel+0x3de/0x3eb
> [   47.462319]  [<ffffffff81748347>] x86_64_start_reservations+0x132/0x136
> [   47.462323]  [<ffffffff81748140>] ? early_idt_handlers+0x140/0x140
> [   47.462327]  [<ffffffff8174844d>] x86_64_start_kernel+0x102/0x111
> 
> thanks for your help,
> kernel 3.0.4 is not affected by this.
> greetings
> tpowa

There were no changes to the sky2 driver between 3.0.4 and 3.0.6  but there were
changes to multicast tracking.  A couple of other pieces of information that might
help.  First, what is the chip type:
   dmesg | grep sky2

And could you try 'git bisect' to narrow the problem down to a particular
change.

Thanks

P.s: adding netdev list to this to make discussion public.
