From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Log the explicit address that triggered DAD failure
Date: Wed, 12 Aug 2009 21:33:36 -0400
Message-ID: <4A836D70.1040702@hp.com>
References: <1250089107.6641.36.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:23403 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbZHMBdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 21:33:38 -0400
In-Reply-To: <1250089107.6641.36.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
> If an interface has multiple addresses, the current message for DAD
> failure isn't really helpful, so this patch adds the address itself to
> the printk.
> 
> Signed-off-by: Jens Rosenboom <jens@mcbone.net>
> 
> ---
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 43b3c9f..01a4b25 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1403,8 +1403,8 @@ void addrconf_dad_failure(struct inet6_ifaddr
> *ifp)
>  	struct inet6_dev *idev = ifp->idev;
>  
>  	if (net_ratelimit())
> -		printk(KERN_INFO "%s: IPv6 duplicate address detected!\n",
> -			ifp->idev->dev->name);
> +		printk(KERN_INFO "%s: IPv6 duplicate address %pI6 detected!\n",
> +			ifp->idev->dev->name, &ifp->addr);
>  
>  	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
>  		struct in6_addr addr;

I have no problem with this patch, I should have done this when I
last changed this code.

The other thing I've come across that is similar to this is the
issue that when DAD fails, /sbin/ip doesn't show that it did,
the address just stays in a tentative state forever:

    inet6 dead:beef::1/64 scope global tentative 
       valid_lft forever preferred_lft forever

Does anyone have an issue of adding a "dadfailed" flag to make
this more obvious:

    inet6 dead:beef::1/64 scope global tentative dadfailed
       valid_lft forever preferred_lft forever

-Brian
