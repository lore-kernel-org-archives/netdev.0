From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 09:54:46 -0800 (PST)
Message-ID: <20101213.095446.71129033.davem@davemloft.net>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucian.grijincu@gmail.com,
	ddvlad@rosedu.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756613Ab0LMRyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:54:18 -0500
In-Reply-To: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 13 Dec 2010 16:18:23 +0200

> -static int __dev_close(struct net_device *dev)
> +static int __dev_close_many(struct list_head *head)
>  {
> -	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct net_device *dev;
>  
> -	ASSERT_RTNL();
> -	might_sleep();
> +	list_for_each_entry(dev, head, unreg_list) {
> +		ASSERT_RTNL();
> +		might_sleep();

It doesn't make any sense to put these insertions into this loop since
they are testing top-level invariants that must be provided by the
caller.
