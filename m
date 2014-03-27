From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: move DAD and addrconf_verify processing
 to workqueue
Date: Thu, 27 Mar 2014 13:15:49 -0400 (EDT)
Message-ID: <20140327.131549.909533657131515923.davem@davemloft.net>
References: <20140325142004.7507d310@samsung-9>
	<20140326000052.GD22086@order.stressinduktion.org>
	<20140326061745.GE22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151AbaC0RPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:15:51 -0400
In-Reply-To: <20140326061745.GE22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 26 Mar 2014 07:17:45 +0100

> @@ -751,7 +753,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
>  
>  	in6_dev_put(ifp->idev);
>  
> -	if (del_timer(&ifp->dad_timer))
> +	if (cancel_delayed_work(&ifp->dad_work))
>  		pr_notice("Timer is still running, when freeing ifa=%p\n", ifp);
>  
>  	if (ifp->state != INET6_IFADDR_STATE_DEAD) {

This pr_notice() needs to be adjusted, we are no longer using a timer.
