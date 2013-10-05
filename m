From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel BUG at net/core/skbuff.c:1048!
Date: Sat, 5 Oct 2013 11:01:05 +0100
Message-ID: <20131005100105.GA2457@macbook.localnet>
References: <524E8BFB.9080708@icts.kuleuven.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wim Vandersmissen <Wim.Vandersmissen@icts.kuleuven.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54152 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3JEKMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 06:12:16 -0400
Content-Disposition: inline
In-Reply-To: <524E8BFB.9080708@icts.kuleuven.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 11:35:55AM +0200, Wim Vandersmissen wrote:
> Hi,
> 
> Got the following BUG when using ipv6 netfilter/conntrack/ipv6
> forwarding and traffic flowing.
> 
> No issues in 3.4.x, but triggered in 3.10.x (introduced in 3.7)

Please also send me your 3.10.x config and the ip6tables rules you're
using.

Are you actually using IPv6 NAT? 

Thanks!

> git bisect tells me:
> 
> 58a317f1061c894d2344c0b6a18ab4a64b69b815 is the first bad commit
> commit 58a317f1061c894d2344c0b6a18ab4a64b69b815
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Sun Aug 26 19:14:12 2012 +0200
> netfilter: ipv6: add IPv6 NAT support
> 
> 
> 
> 
> kernel: kernel BUG at net/core/skbuff.c:1048!
> kernel: invalid opcode: 0000 [#1] SMP
> kernel: icrocode]
> kernel: CPU 2
> kernel: Pid: 0, comm: swapper/2 Not tainted 3.6.0-rc2+ #1 HP
> ProLiant DL380 G6
> kernel: RIP: 0010:[<ffffffff8126d8b8>]  [<ffffffff8126d8b8>]
> pskb_expand_head+0x30/0x210
> kernel: RSP: 0018:ffff88019fc239f0  EFLAGS: 00010202
> kernel: RAX: 0000000000000001 RBX: ffff88018ae50880 RCX: 0000000000000020
> kernel: RDX: 0000000000000000 RSI: 00000000000002c0 RDI: ffff88018ae50880
> kernel: RBP: 0000000000000020 R08: 0000000000000000 R09: 0000000000000000
> kernel: R10: ffff88018af4a2c0 R11: ffffffffa0271ff8 R12: 0000000000000000
> kernel: R13: ffff880196ca26c0 R14: ffff88018ac55456 R15: ffffffff814b0f40
> kernel: FS:  0000000000000000(0000) GS:ffff88019fc20000(0000)
> knlGS:0000000000000000
> kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> kernel: CR2: ffffffffff600000 CR3: 000000018b2ab000 CR4: 00000000000007e0
> kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> kernel: Process swapper/2 (pid: 0, threadinfo ffff8801990ca000, task
> ffff88019909e090)
> kernel: Stack:
> kernel: 0000000800000040 ffff88018ae50880 ffff88018ae50880 0000000000000000
> kernel: ffff880196ca26c0 ffff88018ac55456 ffffffff814b0f40 ffffffffa02725ab
> kernel: 0000000800000000 0006000000000000 402c022a00000000 ffff88018ae508a8
> kernel: Call Trace:
> kernel: <IRQ>
> kernel: [<ffffffffa02725ab>] ? ip6_forward+0x5b3/0x72a [ipv6]
> kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
> kernel: [<ffffffffa02f7407>] ? __ipv6_conntrack_in+0xed/0x153
> [nf_conntrack_ipv6]
> kernel: [<ffffffff81298f00>] ? nf_iterate+0x50/0x8b
> kernel: [<ffffffff810372eb>] ? mod_timer+0x15e/0x16c
> kernel: [<ffffffffa0273b0a>] ? ip6_xmit+0x2d2/0x368 [ipv6]
> kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
> kernel: [<ffffffff81299135>] ? nf_hook_slow+0x67/0xfb
> kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
> kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
> kernel: [<ffffffffa02f22c0>] ? nf_ct_frag6_output+0x97/0xe1 [nf_defrag_ipv6]
