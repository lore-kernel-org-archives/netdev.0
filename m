From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 13/13] TProxy: use the interface primary IP address as
 a default value for --on-ip
Date: Mon, 21 Sep 2009 14:00:39 -0400
Message-ID: <4AB7BF47.2030404@hp.com>
References: <1253548005.12519.13.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:14820 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbZIUSAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 14:00:37 -0400
In-Reply-To: <1253548005.12519.13.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balazs Scheidler wrote: 
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +
> +static inline const struct in6_addr *
> +tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr, const struct in6_addr *daddr)
> +{
> +	struct inet6_dev *indev;
> +	struct inet6_ifaddr *ifa;
> +	struct in6_addr *laddr;
> +	
> +        if (!ipv6_addr_any(user_laddr))
> +                return user_laddr;
> +	
> +        laddr = NULL;
> +        rcu_read_lock();
> +        indev = __in6_dev_get(skb->dev);
> +        if (indev && (ifa = indev->addr_list)) {
> +		laddr = &ifa->addr;
> +	}
> +        rcu_read_unlock();
> +        
> +        return laddr ? laddr : daddr;
> +}

You should call ipv6_dev_get_saddr() to get a source address based on the target
destination address.

-Brian
