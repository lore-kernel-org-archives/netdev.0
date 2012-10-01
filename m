From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipv6: don't add link local route when there is no
 link local address
Date: Mon, 01 Oct 2012 16:55:27 -0400 (EDT)
Message-ID: <20121001.165527.1025640918619977740.davem@davemloft.net>
References: <1348664962-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab2JAUz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:55:29 -0400
In-Reply-To: <1348664962-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 26 Sep 2012 15:09:22 +0200

> When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), a route
> to fe80::/64 is added in the main table:
>   unreachable fe80::/64 dev lo  proto kernel  metric 256  error -101
> 
> This route does not match any prefix (no fe80:: address on lo). In fact,
> addrconf_dev_config() will not add link local address because this function
> filters interfaces by type. If the link local address is added manually, the
> route to the link local prefix will be automatically added by
> addrconf_add_linklocal().
> Note also, that this route is not deleted when the address is removed.
> 
> After looking at the code, it seems that addrconf_add_lroute() is redundant with
> addrconf_add_linklocal(), because this function will add the link local route
> when the link local address is configured.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This change looks correct, however:

> @@ -2489,7 +2479,6 @@ static void addrconf_sit_config(struct net_device *dev)
>  
>  	if (dev->flags&IFF_POINTOPOINT) {
>  		addrconf_add_mroute(dev);
> -		addrconf_add_lroute(dev);
>  	} else
>  		sit_route_add(dev);

now that the if() branch is a single statement, please remove the
curly braces.

Thanks.
