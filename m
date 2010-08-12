From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [xfrm_user] BUG: sleeping function called from invalid context
Date: Thu, 12 Aug 2010 14:50:27 +0200
Message-ID: <20100812125027.GA12982@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I just noticed this message in my log (I'm not sure what charon was
doing at the time...):

BUG: sleeping function called from invalid context at /home/kronos/src/linux-2.6.git/mm/slub.c:1701
in_atomic(): 1, irqs_disabled(): 0, pid: 10411, name: charon
Pid: 10411, comm: charon Not tainted 2.6.35 #271
Call Trace:
 [<ffffffff810275d7>] __might_sleep+0xf8/0xfa
 [<ffffffff810a99be>] kmem_cache_alloc+0x35/0x9d
 [<ffffffff81265c8e>] xfrm_policy_alloc+0x20/0xa1
 [<ffffffffa0372d73>] xfrm_compile_policy+0x112/0x16f [xfrm_user]
 [<ffffffff812686e4>] xfrm_user_policy+0xb8/0x131
 [<ffffffff81233b5b>] do_ip_setsockopt+0xa83/0xb2e
 [<ffffffff8102c0ce>] ? get_parent_ip+0x11/0x41
 [<ffffffff81080838>] ? unlock_page+0x22/0x27
 [<ffffffff810935c3>] ? __do_fault+0x4d4/0x50c
 [<ffffffff8109497d>] ? handle_mm_fault+0x45d/0x8a4
 [<ffffffff810afbef>] ? get_empty_filp+0x79/0x15a
 [<ffffffff8102c0e5>] ? get_parent_ip+0x28/0x41
 [<ffffffff8102c0e5>] ? get_parent_ip+0x28/0x41
 [<ffffffff81283385>] ? sub_preempt_count+0x92/0xa6
 [<ffffffff812832b6>] ? do_page_fault+0x3d5/0x412
 [<ffffffff8125522e>] ? inet_bind+0x1cc/0x1dc
 [<ffffffff81233cc2>] ip_setsockopt+0x23/0x82
 [<ffffffff810acfbf>] ? fd_install+0x54/0x5d
 [<ffffffff8124d175>] udp_setsockopt+0x24/0x26
 [<ffffffff811fd5c5>] sock_common_setsockopt+0xf/0x11
 [<ffffffff811fb0a8>] sys_setsockopt+0x81/0xa2
 [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b


xfrm_user_policy takes read_lock(&xfrm_km_lock) before calling
xfrm_compile_policy (via km->compile_policy), which in turn calls
xfrm_policy_alloc with GFP_KERNEL.

Luca
