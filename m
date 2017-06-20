From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] igmp: add a missing spin_lock_init()
Date: Tue, 20 Jun 2017 15:52:29 -0400 (EDT)
Message-ID: <20170620.155229.1782557175397900375.davem@davemloft.net>
References: <1497980787-4040-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdFTTwa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:52:30 -0400
In-Reply-To: <1497980787-4040-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 20 Jun 2017 10:46:27 -0700

> Andrey reported a lockdep warning on non-initialized
> spinlock:
> 
>  INFO: trying to register non-static key.
>  the code is fine but needs lockdep annotation.
>  turning off the locking correctness validator.
>  CPU: 1 PID: 4099 Comm: a.out Not tainted 4.12.0-rc6+ #9
>  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  Call Trace:
>   __dump_stack lib/dump_stack.c:16
>   dump_stack+0x292/0x395 lib/dump_stack.c:52
>   register_lock_class+0x717/0x1aa0 kernel/locking/lockdep.c:755
>   ? 0xffffffffa0000000
>   __lock_acquire+0x269/0x3690 kernel/locking/lockdep.c:3255
>   lock_acquire+0x22d/0x560 kernel/locking/lockdep.c:3855
>   __raw_spin_lock_bh ./include/linux/spinlock_api_smp.h:135
>   _raw_spin_lock_bh+0x36/0x50 kernel/locking/spinlock.c:175
>   spin_lock_bh ./include/linux/spinlock.h:304
>   ip_mc_clear_src+0x27/0x1e0 net/ipv4/igmp.c:2076
>   igmpv3_clear_delrec+0xee/0x4f0 net/ipv4/igmp.c:1194
>   ip_mc_destroy_dev+0x4e/0x190 net/ipv4/igmp.c:1736
> 
> We miss a spin_lock_init() in igmpv3_add_delrec(), probably
> because previously we never use it on this code path. Since
> we already unlink it from the global mc_tomb list, it is
> probably safe not to acquire this spinlock here. It does not
> harm to have it although, to avoid conditional locking.
> 
> Fixes: c38b7d327aaf ("igmp: acquire pmc lock for ip_mc_clear_src()")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thank you.
