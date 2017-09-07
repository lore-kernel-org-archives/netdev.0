From: Florian Westphal <fw@strlen.de>
Subject: Re: WARNING: at net/netfilter/core.c:218
 __nf_hook_entries_try_shrink+0xf7/0x110
Date: Thu, 7 Sep 2017 09:13:28 +0200
Message-ID: <20170907071328.GG11551@breakpoint.cc>
References: <1504761109.6518.10.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38018 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754141AbdIGHQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 03:16:26 -0400
Content-Disposition: inline
In-Reply-To: <1504761109.6518.10.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Galbraith <efault@gmx.de> wrote:
> [   21.219604] ip6_tables: (C) 2000-2006 Netfilter Core Team
> [   21.433091] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
> [   21.495849] ip_tables: (C) 2000-2006 Netfilter Core Team
> [   22.404040] ------------[ cut here ]------------
> [   22.404267] WARNING: CPU: 2 PID: 1379 at net/netfilter/core.c:218 __nf_hook_entries_try_shrink+0xf7/0x110

The WARN_ON is bogus, I sent a patch to remove it.

> Met 10 of those during this boot.  The first time I booted, the
> warnings were followed by the explosion below, but that kernel was not
> entirely virgin, so add a pinch of salt.
> 
> [   48.592298] Ebtables v2.0 registered
> [   48.730755] BUG: unable to handle kernel NULL pointer dereference at 000000000000003c
> [   48.732723] IP: _raw_read_lock_bh+0x15/0x30
> [   48.734526] PGD 0 P4D 0 
> [   48.736482] Oops: 0002 [#1] SMP
> [   48.738317] Dumping ftrace buffer:
> [   48.740260]    (ftrace buffer empty)
> [   48.775370] RIP: 0010:_raw_read_lock_bh+0x15/0x30
> [   48.776496] RSP: 0018:ffff88041ec83bd0 EFLAGS: 00010286
> [   48.777414] RAX: 0000000000000100 RBX: 0000000000000001 RCX: 0000000000000000
> [   48.778302] RDX: 0000000000000000 RSI: ffff88041ec83ca8 RDI: 000000000000003c
> [   48.779189] RBP: 0000000000000000 R08: 0000000000000001 R09: 00000000088a0c8d
> [   48.780072] R10: 0000000000000000 R11: 0000000000007b00 R12: ffff8803cdcc1300
> [   48.780950] R13: ffff8803cdcc1300 R14: 0000000000000000 R15: ffff8803f1b8b000
> [   48.781845] FS:  0000000000000000(0000) GS:ffff88041ec80000(0000) knlGS:0000000000000000
> [   48.782727] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   48.783533] CR2: 000000000000003c CR3: 00000003f19fa001 CR4: 00000000001606e0
> [   48.784348] Call Trace:
> [   48.785160]  <IRQ>
> [   48.786004]  ebt_do_table+0x3b/0x6ca [ebtables]
> [   48.786900]  ? dequeue_rt_stack+0x4c/0x290
> [   48.787792]  ? enqueue_task_rt+0x1da/0x300
> [   48.789001]  nf_hook_slow+0x37/0xb0
> [   48.790662]  br_pass_frame_up+0xbe/0xd0 [bridge]

Haven't seen that before, I will investigate.
