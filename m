From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure
 (v3)
Date: Mon, 21 Nov 2011 15:39:23 -0500 (EST)
Message-ID: <20111121.153923.1130612299870337625.davem@davemloft.net>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
	<1321632821-11640-1-git-send-email-nhorman@tuxdriver.com>
	<1321632821-11640-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	robert.w.love@intel.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab1KUUkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:40:31 -0500
In-Reply-To: <1321632821-11640-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 18 Nov 2011 11:13:40 -0500


> +#ifdef CONFIG_CGROUPS
> +void skb_update_prio(struct sk_buff *skb)
> +{
> +	struct netprio_map *map = rcu_dereference(skb->dev->priomap);
> +
> +	if ((!skb->priority) && (skb->sk) && map)
> +		skb->priority = map->priomap[skb->sk->sk_cgrp_prioidx];
> +}
> +EXPORT_SYMBOL_GPL(skb_update_prio);
> +#endif

skb_update_prio() has one call site, right here in this dev.c file.
Mark it static, kill the symbol export, and use the ifdef here to nop
out the implementation when the config option isn't set.

> +	struct netprio_map *map;
> +
> +	rtnl_lock();
> +
> +
> +	for_each_netdev(&init_net, dev) {

There are a few instances of extra empty lines in the code added by
this patch, please do a quick audit and get rid of them.

Otherwise seems ok to me.

Thanks.
