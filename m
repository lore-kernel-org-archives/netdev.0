From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Tue, 5 May 2009 12:27:35 -0700
Message-ID: <20090505122735.b87dd129.akpm@linux-foundation.org>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Guntsche <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35080 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754832AbZEET3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 15:29:55 -0400
In-Reply-To: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Sun, 3 May 2009 15:36:27 +0200
Michael Guntsche <mike@it-loops.com> wrote:

> Hello list,
> 
> 
> I recently tried 2.6.30-rc4 on a routerboard currently running 2.6.29  
> (it is running stable with this kernel).
> 
> This board is used as a gateway and under load I see the following BUG  
> with 2.6.30-rc4.
> 
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:126!

skb_over_panic().  There should have been some additional information
printed before the "cut here" text.  That might be useful in fixing
this regression.


> Oops: Exception in kernel mode, sig: 5 [#1]
> MikroTik RouterBOARD 600 series
> Modules linked in: nf_nat_rtsp nf_conntrack_rtsp
> NIP: c01abc68 LR: c01abc68 CTR: c015559c
> REGS: c7aa7b20 TRAP: 0700   Not tainted  (2.6.30-rc4)
> MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002424  XER: 20000000
> TASK = c7855bc0[588] 'pptpgw' THREAD: c7aa6000
> GPR00: c01abc68 c7aa7bd0 c7855bc0 00000085 0000295e ffffffff c0152b68  
> 00000030
> GPR08: c03848d4 c0350000 0000295e c0380398 84002422 10029614 100de49c  
> 100e0000
> GPR16: 100b45a0 00000040 c02f6260 c02f628c c7846380 c7aa6000 c7957800  
> 00000000
> GPR24: 00000002 0000003e c7a12480 c7957a00 c7846000 000005e6 c7956240  
> c7a8b880
> NIP [c01abc68] skb_over_panic+0x48/0x5c
> LR [c01abc68] skb_over_panic+0x48/0x5c
> Call Trace:
> [c7aa7bd0] [c01abc68] skb_over_panic+0x48/0x5c (unreliable)
> [c7aa7be0] [c01ad468] skb_put+0x5c/0x60
> [c7aa7bf0] [c0187650] gfar_clean_rx_ring+0x204/0x42c
> [c7aa7c40] [c0189074] gfar_poll+0x258/0x338
> [c7aa7c90] [c01b8b8c] net_rx_action+0x9c/0x190
> [c7aa7cc0] [c002ddac] __do_softirq+0x84/0x100
> [c7aa7cf0] [c0006474] do_softirq+0x58/0x5c
> [c7aa7d00] [c002dc24] irq_exit+0x94/0x98
> [c7aa7d10] [c0006518] do_IRQ+0xa0/0xc4
> [c7aa7d30] [c0014448] ret_from_except+0x0/0x14
> --- Exception: 501 at ppp_asynctty_receive+0x1d8/0x550
>      LR = ppp_asynctty_receive+0x4a4/0x550
> [c7aa7df0] [c0197734] ppp_asynctty_receive+0x324/0x550 (unreliable)
> [c7aa7e40] [c014def4] pty_write+0x74/0x8c
> [c7aa7e50] [c0148f1c] n_tty_write+0x2b0/0x430
> [c7aa7eb0] [c0145f34] tty_write+0x188/0x268
> [c7aa7ef0] [c00903cc] vfs_write+0xb4/0x1a4
> [c7aa7f10] [c009096c] sys_write+0x4c/0x90
> [c7aa7f40] [c0013db0] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xff2d5c4
>      LR = 0x10003a48
> Instruction dump:
> 80a30054 2f800000 80e300a8 810300ac 816300a0 814300a4 419e0020 3c60c030
> 7d695b78 90010008 3863901c 4be7d091 <0fe00000> 48000000 3d20c02d  
> 380968b8
> Kernel panic - not syncing: Fatal exception in interrupt
> Call Trace:
> [c7aa7970] [c0008274] show_stack+0x4c/0x16c (unreliable)
> [c7aa79b0] [c0027d1c] panic+0x90/0x170
> [c7aa7a00] [c00118ac] die+0x19c/0x1d4
> [c7aa7a20] [c0011b80] _exception+0x138/0x15c
> [c7aa7b10] [c00143fc] ret_from_except_full+0x0/0x4c
> --- Exception: 700 at skb_over_panic+0x48/0x5c
>      LR = skb_over_panic+0x48/0x5c
> [c7aa7be0] [c01ad468] skb_put+0x5c/0x60
> [c7aa7bf0] [c0187650] gfar_clean_rx_ring+0x204/0x42c
> [c7aa7c40] [c0189074] gfar_poll+0x258/0x338
> [c7aa7c90] [c01b8b8c] net_rx_action+0x9c/0x190
> [c7aa7cc0] [c002ddac] __do_softirq+0x84/0x100
> [c7aa7cf0] [c0006474] do_softirq+0x58/0x5c
> [c7aa7d00] [c002dc24] irq_exit+0x94/0x98
> [c7aa7d10] [c0006518] do_IRQ+0xa0/0xc4
> [c7aa7d30] [c0014448] ret_from_except+0x0/0x14
> --- Exception: 501 at ppp_asynctty_receive+0x1d8/0x550
>      LR = ppp_asynctty_receive+0x4a4/0x550
> [c7aa7df0] [c0197734] ppp_asynctty_receive+0x324/0x550 (unreliable)
> [c7aa7e40] [c014def4] pty_write+0x74/0x8c
> [c7aa7e50] [c0148f1c] n_tty_write+0x2b0/0x430
> [c7aa7eb0] [c0145f34] tty_write+0x188/0x268
> [c7aa7ef0] [c00903cc] vfs_write+0xb4/0x1a4
> [c7aa7f10] [c009096c] sys_write+0x4c/0x90
> [c7aa7f40] [c0013db0] ret_from_syscall+0x0/0x38
> --- Exception: c01 at 0xff2d5c4
>      LR = 0x10003a48
> 
> After that the Board reboots after 180 seconds. To reproduce this  
> problem I just have to stream audio or run some benchmarks on http://speedtest.net 
> .
> 
> Doing the same with 2.6.29 does not inhibit this problem.
> 

