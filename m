From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: release rt when found circular route
Date: Fri, 06 Dec 2013 15:14:07 -0500 (EST)
Message-ID: <20131206.151407.756289328683473825.davem@davemloft.net>
References: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758722Ab3LFUOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:14:08 -0500
In-Reply-To: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Thu, 5 Dec 2013 16:03:51 +0800

> Otherwise causing dst memory leakage.
> Have Checked all other type tunnel device transmit implementation,
> no such things happens anymore.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
...
> @@ -1665,6 +1665,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		}
>  
>  		if (rt->dst.dev == dev) {
> +			ip_rt_put(rt);
>  			netdev_dbg(dev, "circular route to %pI4\n",
>  				   &dst->sin.sin_addr.s_addr);
>  			dev->stats.collisions++;

There is already a "rt_tx_error" label that will handle releasing the
'rt', so at the end of this basic block, goto rt_tx_error instead of
just plain tx_error.

Thanks.
