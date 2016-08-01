From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Mon, 1 Aug 2016 22:59:08 +0200
Message-ID: <20160801205908.GD3031@alphalink.fr>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
 <20160728110948.GA3046@alphalink.fr>
 <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38378 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbcHAU7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:59:13 -0400
Content-Disposition: inline
In-Reply-To: <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 02:28:23PM +0300, Denys Fedoryshchenko wrote:
> <server19> [ 5449.904989] CPU: 1 PID: 6359 Comm: ip Not tainted
> 4.7.0-build-0109 #2
> <server19> [ 5449.905255] Hardware name: Supermicro
> X10SLM+-LN4F/X10SLM+-LN4F, BIOS 3.0 04/24/2015
> <server19> [ 5449.905712] task: ffff8803eef40000 ti: ffff8803fd754000
> task.ti: ffff8803fd754000
> <server19> [ 5449.906168] RIP: 0010:[<ffffffff818a994d>]
> <server19> [<ffffffff818a994d>] inet_fill_ifaddr+0x5a/0x264
> <server19> [ 5449.906710] RSP: 0018:ffff8803fd757b98  EFLAGS: 00010286
> <server19> [ 5449.906976] RAX: ffff8803ef65cb90 RBX: ffff8803f7d2cd00 RCX:
> 0000000000000000
> <server19> [ 5449.907248] RDX: 0000000800000002 RSI: ffff8803ef65cb90 RDI:
> ffff8803ef65cba8
> <server19> [ 5449.907519] RBP: ffff8803fd757be0 R08: 0000000000000008 R09:
> 0000000000000002
> <server19> [ 5449.907792] R10: ffa005040269f480 R11: ffffffff820a1c00 R12:
> ffa005040269f480
> <server19> [ 5449.908067] R13: ffff8803ef65cb90 R14: 0000000000000000 R15:
> ffff8803f7d2cd00
> <server19> [ 5449.908339] FS:  00007f660674d700(0000)
> GS:ffff88041fc40000(0000) knlGS:0000000000000000
> <server19> [ 5449.908796] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <server19> [ 5449.909067] CR2: 00000000008b9018 CR3: 00000003f2a11000 CR4:
> 00000000001406e0
> <server19> [ 5449.909339] Stack:
> <server19> [ 5449.909598]  0163a8c0869711ac
> <server19> 0000008000000000
> <server19> ffffffffffffffff
> <server19> 0003e1d50003e1d5
> <server19>
> <server19> [ 5449.910329]  ffff8800d54c0ac8
> <server19> ffff8803f0d90000
> <server19> 0000000000000005
> <server19> 0000000000000000
> <server19>
> <server19> [ 5449.911066]  ffff8803f7d2cd00
> <server19> ffff8803fd757c40
> <server19> ffffffff818a9f73
> <server19> ffffffff820a1c00
> <server19>
> <server19> [ 5449.911803] Call Trace:
> <server19> [ 5449.912061]  [<ffffffff818a9f73>] inet_dump_ifaddr+0xfb/0x185
> <server19> [ 5449.912332]  [<ffffffff8185de4b>] rtnl_dump_all+0xa9/0xc2
> <server19> [ 5449.912601]  [<ffffffff818756d8>] netlink_dump+0xf0/0x25c
> <server19> [ 5449.912873]  [<ffffffff818759ed>] netlink_recvmsg+0x1a9/0x2d3
> <server19> [ 5449.913142]  [<ffffffff81838412>] sock_recvmsg+0x14/0x16
> <server19> [ 5449.913407]  [<ffffffff8183a743>] ___sys_recvmsg+0xea/0x1a1
> <server19> [ 5449.913675]  [<ffffffff811658e6>] ?
> alloc_pages_vma+0x167/0x1a0
> <server19> [ 5449.913945]  [<ffffffff81159a8b>] ?
> page_add_new_anon_rmap+0xb4/0xbd
> <server19> [ 5449.914212]  [<ffffffff8113b0d0>] ?
> lru_cache_add_active_or_unevictable+0x31/0x9d
> <server19> [ 5449.914664]  [<ffffffff81151762>] ?
> handle_mm_fault+0x632/0x112d
> <server19> [ 5449.914940]  [<ffffffff811550fe>] ? vma_merge+0x27e/0x2b1
> <server19> [ 5449.915208]  [<ffffffff8183b4db>] __sys_recvmsg+0x3d/0x5e
> <server19> [ 5449.915478]  [<ffffffff8183b4db>] ? __sys_recvmsg+0x3d/0x5e
> <server19> [ 5449.915747]  [<ffffffff8183b509>] SyS_recvmsg+0xd/0x17
> <server19> [ 5449.916017]  [<ffffffff818cb85f>]
> entry_SYSCALL_64_fastpath+0x17/0x93
> 
Do you still have the vmlinux file with debug symbols that generated
this panic?
