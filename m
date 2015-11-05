From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] ipv4: fix a potential deadlock in mcast
 getsockopt() path
Date: Wed, 04 Nov 2015 21:30:51 -0500 (EST)
Message-ID: <20151104.213051.484467040401799871.davem@davemloft.net>
References: <1446594076-3304-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	marcelo.leitner@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030897AbbKECax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 21:30:53 -0500
In-Reply-To: <1446594076-3304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  3 Nov 2015 15:41:16 -0800

> Sasha reported the following lockdep warning:
> 
>   Possible unsafe locking scenario:
> 
>         CPU0                    CPU1
>         ----                    ----
>    lock(sk_lock-AF_INET);
>                                 lock(rtnl_mutex);
>                                 lock(sk_lock-AF_INET);
>    lock(rtnl_mutex);
> 
> This is due to that for IP_MSFILTER and MCAST_MSFILTER, we take
> rtnl lock before the socket lock in setsockopt() path, but take
> the socket lock before rtnl lock in getsockopt() path. All the
> rest optnames are setsockopt()-only.
> 
> Fix this by aligning the getsockopt() path with the setsockopt()
> path, so that all mcast socket path would be locked in the same
> order.
> 
> Note, IPv6 part is different where rtnl lock is not held.
> 
> Fixes: 54ff9ef36bdf ("ipv4, ipv6: kill ip_mc_{join, leave}_group and ipv6_sock_mc_{join, drop}")
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I don't like conditional locking, but I can't think of a better
way to suggest fixing this, so applied.

And queued up for -stable as well.

Thanks!
