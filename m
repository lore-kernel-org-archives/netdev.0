From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source addresses for datagrams
Date: Wed, 22 Jan 2014 01:16:07 +0100
Message-ID: <20140122001607.GA20565@order.stressinduktion.org>
References: <1390320070-12735-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56600 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaAVAQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:16:08 -0500
Content-Disposition: inline
In-Reply-To: <1390320070-12735-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 05:01:10PM +0100, Francois-Xavier Le Bail wrote:
> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index 5a80f15..d3a6e2d 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
> @@ -383,6 +383,17 @@ bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
>  	return found;
>  }
>  
> +/*	check if this anycast address is link-local on given interface or
> + *	is global
> + */
> +bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
> +			     const struct in6_addr *addr)
> +{
> +	if (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL)
> +		return ipv6_chk_acast_dev(dev, addr);
> +	else
> +		return ipv6_chk_acast_addr(net, NULL, addr);
> +}

You need to do the check with ipv6_chk_acast_addr in both cases, as only
ipv6_chk_acast_addr does a rcu_read_lock and it is needed for the dereference
of inet6_dev (__in6_dev_get is not safe in ipv6_chk_acast_dev without
rcu_read_lock).

Otherwise I am fine with this patch, thanks!
