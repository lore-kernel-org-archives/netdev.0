From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_dst_cache RCUification
Date: Tue, 13 Apr 2010 01:52:32 -0700 (PDT)
Message-ID: <20100413.015232.67916764.davem@davemloft.net>
References: <1270803809.2623.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42517
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752370Ab0DMIw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:52:28 -0400
In-Reply-To: <1270803809.2623.69.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Apr 2010 11:03:29 +0200

> With latest CONFIG_PROVE_RCU stuff, I felt more comfortable to make this
> work.
> 
> sk->sk_dst_cache is currently protected by a rwlock (sk_dst_lock)
> 
> This rwlock is readlocked for a very small amount of time, and dst
> entries are already freed after RCU grace period. This calls for RCU
> again :)
> 
> This patch converts sk_dst_lock to a spinlock, and use RCU for readers.
> 
> __sk_dst_get() is supposed to be called with rcu_read_lock() or if
> socket locked by user, so use appropriate rcu_dereference_check()
> condition (rcu_read_lock_held() || sock_owned_by_user(sk))
> 
> This patch avoids two atomic ops per tx packet on UDP connected sockets,
> for example, and permits sk_dst_lock to be much less dirtied.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for doing this work Eric.
