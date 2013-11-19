From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: Always propagate flag changes to interfaces
Date: Tue, 19 Nov 2013 16:24:29 -0500 (EST)
Message-ID: <20131119.162429.133625511390166283.davem@davemloft.net>
References: <1384894858-3238-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.priebe@profihost.ag, vfalico@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab3KSVYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 16:24:31 -0500
In-Reply-To: <1384894858-3238-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 19 Nov 2013 16:00:58 -0500

> @@ -4991,9 +4991,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  
> -	if (((dev->flags & IFF_UP) ||
> -	     (dev->flags & (IFF_MASTER | IFF_SLAVE)))
> -	    && ops->ndo_change_rx_flags)
> +	if (ops->ndo_change_rx_flags)
>  		ops->ndo_change_rx_flags(dev, flags);

Right now this test looks like:

	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)

in 'net' tree, please respin against current sources.

Thanks.
