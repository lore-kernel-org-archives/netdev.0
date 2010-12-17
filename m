From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Thu, 16 Dec 2010 17:18:13 -0800
Message-ID: <m1mxo5tcx6.fsf@fess.ebiederm.org>
References: <4D00F58A.2050307@hp.com> <m139q6ahld.fsf@fess.ebiederm.org>
	<20101209111611.1d2e6e2b@nehalam>
	<20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org, maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:32795 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0LQBSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 20:18:20 -0500
In-Reply-To: <20101216132812.2d7fd885@nehalam> (Stephen Hemminger's message of
	"Thu, 16 Dec 2010 13:28:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> When loopback device is being brought down, then keep the route table
> entries because they are special. The entries in the local table for
> linklocal routes and ::1 address should not be purged.
>
> This is a sub optimal solution to the problem and should be replaced
> by a better fix in future.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Stephen thanks for this.  This patch looks good to me.  I just tested
this against 2.6.37-rc6 and my simple tests show it to be working
without problems.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


> ---
> patch versus current net-next tree, but if this acceptable
> it should be applied to net-2.6 as well.
>
> --- a/net/ipv6/addrconf.c	2010-12-16 10:29:34.035408392 -0800
> +++ b/net/ipv6/addrconf.c	2010-12-16 10:30:37.366834482 -0800
> @@ -2669,7 +2669,9 @@ static int addrconf_ifdown(struct net_de
>  
>  	ASSERT_RTNL();
>  
> -	rt6_ifdown(net, dev);
> +	/* Flush routes if device is being removed or it is not loopback */
> +	if (how || !(dev->flags & IFF_LOOPBACK))
> +		rt6_ifdown(net, dev);
>  	neigh_ifdown(&nd_tbl, dev);
>  
>  	idev = __in6_dev_get(dev);
