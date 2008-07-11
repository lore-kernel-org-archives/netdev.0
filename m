From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Fri, 11 Jul 2008 11:24:16 +0200
Message-ID: <20080711092416.GA26515@orion.carnet.hr>
References: <20080710220030.GA29558@orion.carnet.hr> <1215728763.6901.23.camel@dell> <20080710223141.GA2519@orion.carnet.hr> <20080710.162007.04790623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:60963 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbYGKJYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 05:24:22 -0400
Content-Disposition: inline
In-Reply-To: <20080710.162007.04790623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 04:20:07PM -0700, David Miller wrote:
> From: Josip Rodin <joy@entuzijast.net>
> Date: Fri, 11 Jul 2008 00:31:42 +0200
> 
> > It's running with it now, no messages yet. I'll report when if/when they
> > happen.
> 
> Thanks Josip.
> 
> I'll try to whip up some other debug patches if this one Michael gave
> you doesn't trigger.

Here we go, it triggered, here are the first few, tell me if you need more:

Jul 11 02:15:10 arrakis kernel: Splitting cloned skb
Jul 11 02:15:10 arrakis kernel: Pid: 0, comm: swapper Not tainted 2.6.25.6 #2
Jul 11 02:15:10 arrakis kernel: 
Jul 11 02:15:10 arrakis kernel: Call Trace:
Jul 11 02:15:10 arrakis kernel:  <IRQ>  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:15:10 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:15:10 arrakis kernel:  [<ffffffff80424596>] tcp_rcv_established+0x596/0x9d0
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042a77c>] tcp_v4_do_rcv+0xdc/0x220
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042c213>] tcp_v4_rcv+0x5e3/0x810
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8040e58f>] ip_local_deliver_finish+0x9f/0x200
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8040e2a0>] ip_rcv_finish+0x130/0x380
Jul 11 02:15:10 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:15:10 arrakis kernel:  [<ffffffff88083b56>] :bnx2:bnx2_poll+0x676/0x1330
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8025e52a>] handle_edge_irq+0x7a/0x150
Jul 11 02:15:10 arrakis kernel:  [<ffffffff80225076>] __change_page_attr_set_clr+0x8a6/0x920
Jul 11 02:15:10 arrakis kernel:  [<ffffffff803edad8>] net_rx_action+0xf8/0x200
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8023a5b9>] __do_softirq+0x69/0xe0
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020c4ac>] call_softirq+0x1c/0x30
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020e995>] do_softirq+0x35/0x70
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020ec10>] do_IRQ+0x80/0x100
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020a410>] mwait_idle+0x0/0x50
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020b831>] ret_from_intr+0x0/0xa
Jul 11 02:15:10 arrakis kernel:  <EOI>  [<ffffffff80419a80>] tcp_poll+0x0/0x180
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020a451>] mwait_idle+0x41/0x50
Jul 11 02:15:10 arrakis kernel:  [<ffffffff8020a378>] cpu_idle+0x48/0x90
Jul 11 02:15:10 arrakis kernel: 
Jul 11 02:15:33 arrakis kernel: Splitting cloned skb
Jul 11 02:15:33 arrakis kernel: Pid: 4350, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 02:15:33 arrakis kernel: 
Jul 11 02:15:33 arrakis kernel: Call Trace:
Jul 11 02:15:33 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:15:33 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:15:33 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:15:33 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:15:33 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 02:15:33 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 02:15:33 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 02:15:33 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 02:15:33 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 02:15:33 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 02:15:33 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 02:15:33 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 02:15:33 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 02:15:33 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: Splitting cloned skb
Jul 11 02:16:11 arrakis kernel: Pid: 0, comm: swapper Not tainted 2.6.25.6 #2
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: Call Trace:
Jul 11 02:16:11 arrakis kernel:  <IRQ>  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:16:11 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:16:11 arrakis kernel:  [<ffffffff80424596>] tcp_rcv_established+0x596/0x9d0
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8042a77c>] tcp_v4_do_rcv+0xdc/0x220
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8042c213>] tcp_v4_rcv+0x5e3/0x810
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8040e58f>] ip_local_deliver_finish+0x9f/0x200
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8040e2a0>] ip_rcv_finish+0x130/0x380
Jul 11 02:16:11 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:16:11 arrakis kernel:  [<ffffffff88083b56>] :bnx2:bnx2_poll+0x676/0x1330
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8023e7a4>] lock_timer_base+0x34/0x70
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8023e910>] __mod_timer+0xb0/0xd0
Jul 11 02:16:11 arrakis kernel:  [<ffffffff88085c00>] :bnx2:bnx2_timer+0x0/0x3d0
Jul 11 02:16:11 arrakis kernel:  [<ffffffff803edad8>] net_rx_action+0xf8/0x200
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8023a5b9>] __do_softirq+0x69/0xe0
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020c4ac>] call_softirq+0x1c/0x30
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020e995>] do_softirq+0x35/0x70
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020ec10>] do_IRQ+0x80/0x100
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020a410>] mwait_idle+0x0/0x50
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020b831>] ret_from_intr+0x0/0xa
Jul 11 02:16:11 arrakis kernel:  <EOI>  [<ffffffff80419a80>] tcp_poll+0x0/0x180
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020a451>] mwait_idle+0x41/0x50
Jul 11 02:16:11 arrakis kernel:  [<ffffffff8020a378>] cpu_idle+0x48/0x90
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 2
Jul 11 02:16:11 arrakis kernel: original skb:
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000000 00000000 8e964080 ffff8101 00000000 00000000 
Jul 11 02:16:11 arrakis kernel: 2db80000 ffff8102 2e54e700 ffff8102 00000000 00000000 00000000 00000000 
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000000 00000000 6616cee6 6616da36 0024c8af 00000010 
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000b92 00000b50 01000000 001000e0 00000000 0008d00e 
Jul 11 02:16:11 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000 
Jul 11 02:16:11 arrakis kernel: 56255203 00000000 000000e0 000000cc 00000000 00000100 00000100 1eadfa52 
Jul 11 02:16:11 arrakis kernel: 62c55800 ffff8100 62c558be ffff8100 00000d28 00000001 
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: 00010002 05a80002 00010002 00000000 00000000 00000000 016aaeb0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 0000071d 000008e3 018b4b80 ffffe200 00000000 0000026d 01487eb8 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 0159ebb0 ffffe200 00000000 00001000 01bb2ac0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 014dbe10 ffffe200 00000000 00000bf5 014b1fd0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 015c29b0 ffffe200 00000000 00001000 01598588 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 015b48d0 ffffe200 00000000 00001000 015c51b8 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 01e26de0 ffffe200 00000000 00001000 0148a998 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 0000005d 01594fb8 ffffe200 00000000 00001000 016d8f00 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 00733028 ffffe200 00000000 00001000 01baaa20 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00000b9f a958b6d7 05df7a82 05ddd09a 312d8da0 
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: Corrupted skb:
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000000 00000000 8e964080 ffff8101 00000000 00000000 
Jul 11 02:16:11 arrakis kernel: 2db80000 ffff8102 2e54e700 ffff8102 00000000 00000000 00000000 00000000 
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000000 00000000 6616cee6 6616da36 0024c8af 00000010 
Jul 11 02:16:11 arrakis kernel: 00000000 00000000 00000b92 00000b50 01000000 001000e0 00000000 0008d00e 
Jul 11 02:16:11 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000 
Jul 11 02:16:11 arrakis kernel: 56255203 00000000 000000e0 000000cc 00000000 00000100 00000100 1eadfa52 
Jul 11 02:16:11 arrakis kernel: 62c55800 ffff8100 62c558be ffff8100 00000d28 00000001 
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:16:11 arrakis kernel: 00010002 00000001 00000001 00000000 00000000 00000000 016aaeb0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 0000071d 000005a8 018b4b80 ffffe200 00000000 0000026d 01487eb8 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 0159ebb0 ffffe200 00000000 00001000 01bb2ac0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 014dbe10 ffffe200 00000000 00000bf5 014b1fd0 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 015c29b0 ffffe200 00000000 00001000 01598588 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 015b48d0 ffffe200 00000000 00001000 015c51b8 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 01e26de0 ffffe200 00000000 00001000 0148a998 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 0000005d 01594fb8 ffffe200 00000000 00001000 016d8f00 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00001000 00733028 ffffe200 00000000 00001000 01baaa20 ffffe200 
Jul 11 02:16:11 arrakis kernel: 00000000 00000b9f a958b6d7 05df7a82 05ddd09a 312d8da0 
Jul 11 02:16:11 arrakis kernel: 
Jul 11 02:17:23 arrakis kernel: Splitting cloned skb
Jul 11 02:17:23 arrakis kernel: Pid: 4350, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 02:17:23 arrakis kernel: 
Jul 11 02:17:23 arrakis kernel: Call Trace:
Jul 11 02:17:23 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:17:23 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:17:23 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:17:23 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:17:23 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 02:17:23 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 02:17:23 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 02:17:23 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 02:17:23 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 02:17:23 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 02:17:23 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 02:17:23 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 02:17:23 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 02:17:23 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 02:17:23 arrakis kernel: 
Jul 11 02:17:46 arrakis kernel: Splitting cloned skb
Jul 11 02:17:46 arrakis kernel: Pid: 4350, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 02:17:46 arrakis kernel: 
Jul 11 02:17:46 arrakis kernel: Call Trace:
Jul 11 02:17:46 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:17:46 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:17:46 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:17:46 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:17:46 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 02:17:46 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 02:17:46 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 02:17:46 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 02:17:46 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 02:17:46 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 02:17:46 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 02:17:46 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 02:17:46 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 02:17:46 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 02:17:46 arrakis kernel: 
Jul 11 02:18:28 arrakis kernel: Splitting cloned skb
Jul 11 02:18:28 arrakis kernel: Pid: 4350, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 02:18:28 arrakis kernel: 
Jul 11 02:18:28 arrakis kernel: Call Trace:
Jul 11 02:18:28 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 02:18:28 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 02:18:28 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 02:18:28 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 02:18:28 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 02:18:28 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 02:18:28 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 02:18:28 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 02:18:28 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 02:18:28 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 02:18:28 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 02:18:28 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 02:18:28 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 02:18:28 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 02:18:28 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: Splitting cloned skb
Jul 11 03:57:08 arrakis kernel: Pid: 0, comm: swapper Not tainted 2.6.25.6 #2
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: Call Trace:
Jul 11 03:57:08 arrakis kernel:  <IRQ>  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 03:57:08 arrakis kernel:  [<ffffffff80424596>] tcp_rcv_established+0x596/0x9d0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042a77c>] tcp_v4_do_rcv+0xdc/0x220
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042c213>] tcp_v4_rcv+0x5e3/0x810
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8040e58f>] ip_local_deliver_finish+0x9f/0x200
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8040e2a0>] ip_rcv_finish+0x130/0x380
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:57:08 arrakis kernel:  [<ffffffff88083b56>] :bnx2:bnx2_poll+0x676/0x1330
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8022d746>] run_rebalance_domains+0xf6/0x4c0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff80226787>] sys32_mmap2+0x47/0x100
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803edad8>] net_rx_action+0xf8/0x200
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8023a5b9>] __do_softirq+0x69/0xe0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020c4ac>] call_softirq+0x1c/0x30
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020e995>] do_softirq+0x35/0x70
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020ec10>] do_IRQ+0x80/0x100
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a410>] mwait_idle+0x0/0x50
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020b831>] ret_from_intr+0x0/0xa
Jul 11 03:57:08 arrakis kernel:  <EOI>  [<ffffffff80419a80>] tcp_poll+0x0/0x180
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a451>] mwait_idle+0x41/0x50
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a378>] cpu_idle+0x48/0x90
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: Splitting cloned skb
Jul 11 03:57:08 arrakis kernel: Pid: 0, comm: swapper Not tainted 2.6.25.6 #2
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: Call Trace:
Jul 11 03:57:08 arrakis kernel:  <IRQ>  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 03:57:08 arrakis kernel:  [<ffffffff80424596>] tcp_rcv_established+0x596/0x9d0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042a77c>] tcp_v4_do_rcv+0xdc/0x220
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8042c213>] tcp_v4_rcv+0x5e3/0x810
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8040e58f>] ip_local_deliver_finish+0x9f/0x200
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8040e2a0>] ip_rcv_finish+0x130/0x380
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:57:08 arrakis kernel:  [<ffffffff88083b56>] :bnx2:bnx2_poll+0x676/0x1330
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8022d746>] run_rebalance_domains+0xf6/0x4c0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff802267da>] sys32_mmap2+0x9a/0x100
Jul 11 03:57:08 arrakis kernel:  [<ffffffff803edad8>] net_rx_action+0xf8/0x200
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8023a5b9>] __do_softirq+0x69/0xe0
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020c4ac>] call_softirq+0x1c/0x30
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020e995>] do_softirq+0x35/0x70
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020ec10>] do_IRQ+0x80/0x100
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a410>] mwait_idle+0x0/0x50
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020b831>] ret_from_intr+0x0/0xa
Jul 11 03:57:08 arrakis kernel:  <EOI>  [<ffffffff80419a80>] tcp_poll+0x0/0x180
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a451>] mwait_idle+0x41/0x50
Jul 11 03:57:08 arrakis kernel:  [<ffffffff8020a378>] cpu_idle+0x48/0x90
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: bnx2: skb->nr_frags=1 is corrupted, should be 2
Jul 11 03:57:08 arrakis kernel: original skb:
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 00000000 00000000 964321c0 ffff8101 00000000 00000000 
Jul 11 03:57:08 arrakis kernel: 2db80000 ffff8102 2e8a4800 ffff8102 00000000 00000000 00000000 00000000 
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 00000000 00000000 7207adad 7207beb1 003be3a4 00000010 
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 0000113a 00001104 01000000 001000ec 00000000 0008300e 
Jul 11 03:57:08 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000 
Jul 11 03:57:08 arrakis kernel: 2d2e3cdb 00000000 000000ec 000000d8 00000000 00000100 00000100 a6f7e35a 
Jul 11 03:57:08 arrakis kernel: 94e95000 ffff8101 94e950ca ffff8101 000012dc 00000001 
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: 00010002 05ac0002 00010003 00000000 00000000 00000000 05f972a8 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000275 00000d8b 05f8f828 ffffe200 00000000 00000379 05f20388 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 054167a0 ffffe200 00000000 00001000 0540e000 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000c31 05f8f828 ffffe200 00000000 00001000 05f20388 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 054167a0 ffffe200 00000000 00001000 0540e000 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000c31 06ff9af0 ffffe200 00000000 00001000 06d055b0 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 04683f60 ffffe200 00000000 000000ab 014864e8 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000f83 038daff0 ffffe200 00000000 00001000 038dae30 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 038da1f0 ffffe200 00000000 00001000 038dd910 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000ce3 115fe1a6 8119c99d 52de821b 31d7c6c7 
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: Corrupted skb:
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 00000000 00000000 964321c0 ffff8101 00000000 00000000 
Jul 11 03:57:08 arrakis kernel: 2db80000 ffff8102 2e8a4800 ffff8102 00000000 00000000 00000000 00000000 
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 00000000 00000000 7207adad 7207beb1 003be3a4 00000010 
Jul 11 03:57:08 arrakis kernel: 00000000 00000000 0000113a 00001104 01000000 001000ec 00000000 0008300e 
Jul 11 03:57:08 arrakis kernel: 803e3440 ffffffff 00000000 00000000 00000000 00000000 00000000 20000000 
Jul 11 03:57:08 arrakis kernel: 2d2e3cdb 00000000 000000ec 000000d8 00000000 00000100 00000100 a6f7e35a 
Jul 11 03:57:08 arrakis kernel: 94e95000 ffff8101 94e950ca ffff8101 000012dc 00000001 
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:57:08 arrakis kernel: 00010002 00000001 00000001 00000000 00000000 00000000 05f972a8 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000275 000005ac 05f8f828 ffffe200 00000000 00000379 05f20388 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 054167a0 ffffe200 00000000 00001000 0540e000 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000c31 05f8f828 ffffe200 00000000 00001000 05f20388 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 054167a0 ffffe200 00000000 00001000 0540e000 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000c31 06ff9af0 ffffe200 00000000 00001000 06d055b0 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 04683f60 ffffe200 00000000 000000ab 014864e8 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000f83 038daff0 ffffe200 00000000 00001000 038dae30 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00001000 038da1f0 ffffe200 00000000 00001000 038dd910 ffffe200 
Jul 11 03:57:08 arrakis kernel: 00000000 00000ce3 115fe1a6 8119c99d 52de821b 31d7c6c7 
Jul 11 03:57:08 arrakis kernel: 
Jul 11 03:59:02 arrakis kernel: Splitting cloned skb
Jul 11 03:59:02 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 03:59:02 arrakis kernel: 
Jul 11 03:59:02 arrakis kernel: Call Trace:
Jul 11 03:59:02 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:59:02 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 03:59:02 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 03:59:02 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 03:59:02 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 03:59:02 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 03:59:02 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 03:59:02 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 03:59:02 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 03:59:02 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 03:59:02 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 03:59:02 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 03:59:02 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 03:59:02 arrakis kernel: 
Jul 11 04:00:02 arrakis kernel: Splitting cloned skb
Jul 11 04:00:02 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:00:02 arrakis kernel: 
Jul 11 04:00:02 arrakis kernel: Call Trace:
Jul 11 04:00:02 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:00:02 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:00:02 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:00:02 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:00:02 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:00:02 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:00:02 arrakis kernel:  [<ffffffff802a4f75>] __mark_inode_dirty+0x65/0x1a0
Jul 11 04:00:02 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:00:02 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:00:02 arrakis kernel:  [<ffffffff80268ba2>] __pagevec_lru_add_active+0xd2/0xf0
Jul 11 04:00:02 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:00:02 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:00:02 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:00:02 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:00:02 arrakis kernel: 
Jul 11 04:00:18 arrakis kernel: Splitting cloned skb
Jul 11 04:00:18 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:00:18 arrakis kernel: 
Jul 11 04:00:18 arrakis kernel: Call Trace:
Jul 11 04:00:18 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:00:18 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:00:18 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:00:18 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:00:18 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:00:18 arrakis kernel:  [<ffffffff802a4f75>] __mark_inode_dirty+0x65/0x1a0
Jul 11 04:00:18 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:00:18 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:00:18 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:00:18 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:00:18 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:00:18 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:00:18 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:00:18 arrakis kernel: 
Jul 11 04:00:34 arrakis kernel: Splitting cloned skb
Jul 11 04:00:34 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:00:34 arrakis kernel: 
Jul 11 04:00:34 arrakis kernel: Call Trace:
Jul 11 04:00:34 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:00:34 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:00:34 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:00:34 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:00:34 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:00:34 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:00:34 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:00:34 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:00:34 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:00:34 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:00:34 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:00:34 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:00:34 arrakis kernel: 
Jul 11 04:01:54 arrakis kernel: Splitting cloned skb
Jul 11 04:01:54 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:01:54 arrakis kernel: 
Jul 11 04:01:54 arrakis kernel: Call Trace:
Jul 11 04:01:54 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:01:54 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:01:54 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:01:54 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:01:54 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:01:54 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:01:54 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:01:54 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:01:54 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:01:54 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:01:54 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:01:54 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:01:54 arrakis kernel: 
Jul 11 04:02:14 arrakis kernel: Splitting cloned skb
Jul 11 04:02:14 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:02:14 arrakis kernel: 
Jul 11 04:02:14 arrakis kernel: Call Trace:
Jul 11 04:02:14 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:02:14 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:02:14 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:02:14 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:02:14 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:02:14 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:02:14 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 04:02:14 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:02:14 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:02:14 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:02:14 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:02:14 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:02:14 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:02:14 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:02:14 arrakis kernel: 
Jul 11 04:02:34 arrakis kernel: Splitting cloned skb
Jul 11 04:02:34 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:02:34 arrakis kernel: 
Jul 11 04:02:34 arrakis kernel: Call Trace:
Jul 11 04:02:34 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:02:34 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:02:34 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:02:34 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:02:34 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:02:34 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:02:34 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:02:34 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:02:34 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:02:34 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:02:34 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:02:34 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:02:34 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:02:34 arrakis kernel: 
Jul 11 04:02:41 arrakis kernel: Splitting cloned skb
Jul 11 04:02:41 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:02:41 arrakis kernel: 
Jul 11 04:02:41 arrakis kernel: Call Trace:
Jul 11 04:02:41 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:02:41 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:02:41 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:02:41 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:02:41 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:02:41 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:02:41 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:02:41 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:02:41 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:02:41 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:02:41 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:02:41 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:02:41 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:02:41 arrakis kernel: 
Jul 11 04:02:57 arrakis kernel: Splitting cloned skb
Jul 11 04:02:57 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:02:57 arrakis kernel: 
Jul 11 04:02:57 arrakis kernel: Call Trace:
Jul 11 04:02:57 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:02:57 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:02:57 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:02:57 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:02:57 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:02:57 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:02:57 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:02:57 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:02:57 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:02:57 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:02:57 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:02:57 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:02:57 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:02:57 arrakis kernel: 
Jul 11 04:03:02 arrakis kernel: Splitting cloned skb
Jul 11 04:03:02 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:03:02 arrakis kernel: 
Jul 11 04:03:02 arrakis kernel: Call Trace:
Jul 11 04:03:02 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:03:02 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:03:02 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:03:02 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:03:02 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:03:02 arrakis kernel:  [<ffffffff802a4f44>] __mark_inode_dirty+0x34/0x1a0
Jul 11 04:03:02 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:03:02 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:03:02 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:03:02 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:03:02 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:03:02 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:03:02 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:03:02 arrakis kernel: 
Jul 11 04:04:24 arrakis kernel: Splitting cloned skb
Jul 11 04:04:24 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:04:24 arrakis kernel: 
Jul 11 04:04:24 arrakis kernel: Call Trace:
Jul 11 04:04:24 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:04:24 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:04:24 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:04:24 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:04:24 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:04:24 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:04:24 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:04:24 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:04:24 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:04:24 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:04:24 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:04:24 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:04:24 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:04:24 arrakis kernel: 
Jul 11 04:05:03 arrakis kernel: Splitting cloned skb
Jul 11 04:05:03 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:05:03 arrakis kernel: 
Jul 11 04:05:03 arrakis kernel: Call Trace:
Jul 11 04:05:03 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:05:03 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:05:03 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:05:03 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:05:03 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:05:03 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:05:03 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:05:03 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:05:03 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:05:03 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:05:03 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:05:03 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:05:03 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:05:03 arrakis kernel: 
Jul 11 04:05:19 arrakis kernel: Splitting cloned skb
Jul 11 04:05:19 arrakis kernel: Pid: 2082, comm: rsync Not tainted 2.6.25.6 #2
Jul 11 04:05:19 arrakis kernel: 
Jul 11 04:05:19 arrakis kernel: Call Trace:
Jul 11 04:05:19 arrakis kernel:  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
Jul 11 04:05:19 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
Jul 11 04:05:19 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
Jul 11 04:05:19 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
Jul 11 04:05:19 arrakis kernel:  [<ffffffff80265f7b>] __alloc_pages+0x5b/0x390
Jul 11 04:05:19 arrakis kernel:  [<ffffffff8041b150>] tcp_sendmsg+0x880/0xbf0
Jul 11 04:05:19 arrakis kernel:  [<ffffffff802a4f75>] __mark_inode_dirty+0x65/0x1a0
Jul 11 04:05:19 arrakis kernel:  [<ffffffff803ddf70>] sock_aio_write+0x110/0x120
Jul 11 04:05:19 arrakis kernel:  [<ffffffff80285309>] do_sync_write+0xd9/0x120
Jul 11 04:05:19 arrakis kernel:  [<ffffffff80249590>] autoremove_wake_function+0x0/0x30
Jul 11 04:05:19 arrakis kernel:  [<ffffffff802299c3>] set_next_entity+0x23/0x50
Jul 11 04:05:19 arrakis kernel:  [<ffffffff80285c5a>] vfs_write+0x15a/0x170
Jul 11 04:05:19 arrakis kernel:  [<ffffffff802862a3>] sys_write+0x53/0x90
Jul 11 04:05:19 arrakis kernel:  [<ffffffff8020b30b>] system_call_after_swapgs+0x7b/0x80
Jul 11 04:05:19 arrakis kernel: 

-- 
Josip Rodin
mirrors@debian.org
