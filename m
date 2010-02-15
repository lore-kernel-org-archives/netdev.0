From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: remove INIT_RCU_HEAD() usage
Date: Mon, 15 Feb 2010 12:13:50 -0800
Message-ID: <20100215201350.GJ6750@linux.vnet.ibm.com>
References: <20100212214138.GA5866@x200>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:55346 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756326Ab0BOUNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 15:13:52 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1FK4TRV028432
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 15:04:29 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1FKDpgK141276
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 15:13:51 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1FKDoh5007918
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 15:13:51 -0500
Content-Disposition: inline
In-Reply-To: <20100212214138.GA5866@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2010 at 11:41:39PM +0200, Alexey Dobriyan wrote:
> call_rcu() will unconditionally reinitialize RCU head anyway.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  net/core/drop_monitor.c            |    1 -
>  net/ipv6/sit.c                     |    1 -
>  net/ipv6/xfrm6_tunnel.c            |    1 -
>  net/netlabel/netlabel_domainhash.c |    1 -
>  net/netlabel/netlabel_unlabeled.c  |    3 ---
>  net/sctp/bind_addr.c               |    1 -
>  net/sctp/ipv6.c                    |    1 -
>  net/sctp/protocol.c                |    1 -
>  8 files changed, 10 deletions(-)
> 
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -296,7 +296,6 @@ static int dropmon_net_event(struct notifier_block *ev_block,
> 
>  		new_stat->dev = dev;
>  		new_stat->last_rx = jiffies;
> -		INIT_RCU_HEAD(&new_stat->rcu);
>  		spin_lock(&trace_state_lock);
>  		list_add_rcu(&new_stat->list, &hw_stats_list);
>  		spin_unlock(&trace_state_lock);
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -363,7 +363,6 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
>  		goto out;
>  	}
> 
> -	INIT_RCU_HEAD(&p->rcu_head);
>  	p->next = t->prl;
>  	p->addr = a->addr;
>  	p->flags = a->flags;
> --- a/net/ipv6/xfrm6_tunnel.c
> +++ b/net/ipv6/xfrm6_tunnel.c
> @@ -178,7 +178,6 @@ alloc_spi:
>  	if (!x6spi)
>  		goto out;
> 
> -	INIT_RCU_HEAD(&x6spi->rcu_head);
>  	memcpy(&x6spi->addr, saddr, sizeof(x6spi->addr));
>  	x6spi->spi = spi;
>  	atomic_set(&x6spi->refcnt, 1);
> --- a/net/netlabel/netlabel_domainhash.c
> +++ b/net/netlabel/netlabel_domainhash.c
> @@ -315,7 +315,6 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
>  		entry_old = netlbl_domhsh_search_def(entry->domain);
>  	if (entry_old == NULL) {
>  		entry->valid = 1;
> -		INIT_RCU_HEAD(&entry->rcu);
> 
>  		if (entry->domain != NULL) {
>  			u32 bkt = netlbl_domhsh_hash(entry->domain);
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -327,7 +327,6 @@ static int netlbl_unlhsh_add_addr4(struct netlbl_unlhsh_iface *iface,
>  	entry->list.addr = addr->s_addr & mask->s_addr;
>  	entry->list.mask = mask->s_addr;
>  	entry->list.valid = 1;
> -	INIT_RCU_HEAD(&entry->rcu);
>  	entry->secid = secid;
> 
>  	spin_lock(&netlbl_unlhsh_lock);
> @@ -373,7 +372,6 @@ static int netlbl_unlhsh_add_addr6(struct netlbl_unlhsh_iface *iface,
>  	entry->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
>  	ipv6_addr_copy(&entry->list.mask, mask);
>  	entry->list.valid = 1;
> -	INIT_RCU_HEAD(&entry->rcu);
>  	entry->secid = secid;
> 
>  	spin_lock(&netlbl_unlhsh_lock);
> @@ -410,7 +408,6 @@ static struct netlbl_unlhsh_iface *netlbl_unlhsh_add_iface(int ifindex)
>  	INIT_LIST_HEAD(&iface->addr4_list);
>  	INIT_LIST_HEAD(&iface->addr6_list);
>  	iface->valid = 1;
> -	INIT_RCU_HEAD(&iface->rcu);
> 
>  	spin_lock(&netlbl_unlhsh_lock);
>  	if (ifindex > 0) {
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -186,7 +186,6 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>  	addr->valid = 1;
> 
>  	INIT_LIST_HEAD(&addr->list);
> -	INIT_RCU_HEAD(&addr->rcu);
> 
>  	/* We always hold a socket lock when calling this function,
>  	 * and that acts as a writer synchronizing lock.
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -381,7 +381,6 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
>  			addr->a.v6.sin6_scope_id = dev->ifindex;
>  			addr->valid = 1;
>  			INIT_LIST_HEAD(&addr->list);
> -			INIT_RCU_HEAD(&addr->rcu);
>  			list_add_tail(&addr->list, addrlist);
>  		}
>  	}
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -188,7 +188,6 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
>  			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
>  			addr->valid = 1;
>  			INIT_LIST_HEAD(&addr->list);
> -			INIT_RCU_HEAD(&addr->rcu);
>  			list_add_tail(&addr->list, addrlist);
>  		}
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
