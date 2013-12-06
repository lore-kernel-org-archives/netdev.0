From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: don't count addrconf generated routes against gc
 limit
Date: Fri, 06 Dec 2013 16:21:24 -0500 (EST)
Message-ID: <20131206.162124.1642753475890720004.davem@davemloft.net>
References: <20131206172556.GF26746@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brett.ciphery@windriver.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3LFVV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:21:26 -0500
In-Reply-To: <20131206172556.GF26746@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 6 Dec 2013 18:25:56 +0100

> @@ -2166,7 +2166,8 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>  				    bool anycast)
>  {
>  	struct net *net = dev_net(idev->dev);
> -	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
> +	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
> +					    DST_NOCOUNT, NULL);
>  
>  	if (!rt) {
>  		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");

So basically, we only want to count routes that will have RTF_CACHE
set on them.

This warning in the net_warn_ratelimited() is no longer relevant, only
hard memory allocation failures can result in this !rt condition.  So
please respin this patch with that warning removed.

Thanks.
