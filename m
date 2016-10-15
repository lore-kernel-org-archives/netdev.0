From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Require exact match for TCP socket lookups if
 dif is l3mdev
Date: Sat, 15 Oct 2016 17:46:54 -0400 (EDT)
Message-ID: <20161015.174654.72392403309705041.davem@davemloft.net>
References: <1476473359-15422-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcJOVq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:46:57 -0400
In-Reply-To: <1476473359-15422-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 14 Oct 2016 12:29:19 -0700

> +/* can not be used in TCP layer after tcp_v6_fill_cb */
> +static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
> +{
> +#if defined(CONFIG_NET_L3_MASTER_DEV)
> +	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
> +	    skb_l3mdev_slave(IP6CB(skb)->flags))
> +		return true;
> +#endif
> +	return false;
> +}
 ...
> +static inline bool skb_l3mdev_slave4(u16 flags)
> +{
> +	return !!(flags & IPSKB_L3SLAVE);
> +}

I think this makes the code confusing.

Actually it has been from the beginning, because we have a generically
named "skb_l3mdev_slave()" helper which strictly operates on ipv6
state.

Please do something with the naming of these two helpers,
skb_l3mdev_slave() and skb_l3mdev_slave4(), so that it is clear that
they are ipv6 and ipv4 specific helpers, respectively.
