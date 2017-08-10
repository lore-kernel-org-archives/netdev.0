From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH v2 net-next 5/7] rtnetlink: protect handler table with rcu
Date: Thu, 10 Aug 2017 11:26:47 +0300
Message-ID: <20170810082647.GA11516@splinter>
References: <20170809184153.16700-1-fw@strlen.de>
 <20170809184153.16700-6-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37373 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752417AbdHJI0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 04:26:52 -0400
Content-Disposition: inline
In-Reply-To: <20170809184153.16700-6-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 09, 2017 at 08:41:51PM +0200, Florian Westphal wrote:
> Note that netlink dumps still acquire rtnl mutex via the netlink
> dump infrastructure.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Florian, can you please check the following splat? I didn't bisect, but
looks like it's related to this patch.

Thanks

[    2.940093] =============================
[    2.944145] WARNING: suspicious RCU usage
[    2.948147] 4.13.0-rc4-idosch-next-custom #565 Not tainted
[    2.954116] -----------------------------
[    2.958113] net/core/rtnetlink.c:175 suspicious rcu_dereference_check() usage!
[    2.965116]
[    2.965116] other info that might help us debug this:
[    2.965116]
[    2.973123]
[    2.973123] rcu_scheduler_active = 1, debug_locks = 1
[    2.979119] no locks held by swapper/0/1.
[    2.983109]
[    2.983109] stack backtrace:
[    2.988117] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.13.0-rc4-idosch-next-custom #565
[    2.989000] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox switch, BIOS 4.6.5 05/21/2015
[    2.989000] Call Trace:
[    2.989000]  dump_stack+0xb1/0x10c
[    2.989000]  ? _atomic_dec_and_lock+0x124/0x124
[    2.989000]  ? lockdep_print_held_locks+0x9b/0xf0
[    2.989000]  lockdep_rcu_suspicious+0xdd/0x110
[    2.989000]  __rtnl_register+0x1c1/0x320
[    2.989000]  ? rtnetlink_bind+0x50/0x50
[    2.989000]  ? net_defaults_init+0x29/0x29
[    2.989000]  rtnl_register+0x11/0x30
[    2.989000]  net_ns_init+0x1bd/0x1fd
[    2.989000]  ? net_defaults_init+0x29/0x29
[    2.989000]  ? __init_srcu_struct+0x54/0x60
[    2.989000]  ? srcu_init_notifier_head+0x4a/0x80
[    2.989000]  do_one_initcall+0x9a/0x241
[    2.989000]  ? initcall_blacklisted+0x140/0x140
[    2.989000]  ? up_read+0x40/0x40
[    2.989000]  ? _raw_spin_unlock_irqrestore+0x3d/0x60
[    2.989000]  ? __wake_up+0x3f/0x50
[    2.989000]  kernel_init_freeable+0x3ea/0x485
[    2.989000]  ? rest_init+0x100/0x100
[    2.989000]  kernel_init+0xe/0x140
[    2.989000]  ? rest_init+0x100/0x100
[    2.989000]  ? rest_init+0x100/0x100
[    2.989000]  ret_from_fork+0x27/0x40
