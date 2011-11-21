From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: add network priority cgroup infrastructure (v3)
Date: Mon, 21 Nov 2011 15:43:07 -0500
Message-ID: <20111121204307.GA10900@hmsreliant.think-freely.org>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
 <1321632821-11640-1-git-send-email-nhorman@tuxdriver.com>
 <1321632821-11640-2-git-send-email-nhorman@tuxdriver.com>
 <20111121.153923.1130612299870337625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	robert.w.love@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37334 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab1KUUnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:43:17 -0500
Content-Disposition: inline
In-Reply-To: <20111121.153923.1130612299870337625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 03:39:23PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 18 Nov 2011 11:13:40 -0500
> 
> 
> > +#ifdef CONFIG_CGROUPS
> > +void skb_update_prio(struct sk_buff *skb)
> > +{
> > +	struct netprio_map *map = rcu_dereference(skb->dev->priomap);
> > +
> > +	if ((!skb->priority) && (skb->sk) && map)
> > +		skb->priority = map->priomap[skb->sk->sk_cgrp_prioidx];
> > +}
> > +EXPORT_SYMBOL_GPL(skb_update_prio);
> > +#endif
> 
> skb_update_prio() has one call site, right here in this dev.c file.
> Mark it static, kill the symbol export, and use the ifdef here to nop
> out the implementation when the config option isn't set.
> 
> > +	struct netprio_map *map;
> > +
> > +	rtnl_lock();
> > +
> > +
> > +	for_each_netdev(&init_net, dev) {
> 
> There are a few instances of extra empty lines in the code added by
> this patch, please do a quick audit and get rid of them.
> 
> Otherwise seems ok to me.
> 
> Thanks.
Copy that Dave, will respin and repost in the AM.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
