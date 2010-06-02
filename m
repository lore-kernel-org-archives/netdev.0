From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev:bfin_mac: reclaim and free tx skb as soon as
 possible after transfer
Date: Wed, 02 Jun 2010 07:02:33 -0700 (PDT)
Message-ID: <20100602.070233.37574714.davem@davemloft.net>
References: <1275383974.1010.5.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754183Ab0FBOCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:02:23 -0400
In-Reply-To: <1275383974.1010.5.camel@eight.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sonic zhang <sonic.adi@gmail.com>
Date: Tue, 1 Jun 2010 17:19:34 +0800

> @@ -1485,6 +1506,10 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
>  	ndev->netdev_ops = &bfin_mac_netdev_ops;
>  	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
>  
> +	init_timer(&lp->tx_reclaim_timer);
> +	lp->tx_reclaim_timer.data = (unsigned long)(lp);

Putting parenthesis around "lp" is excessive, please don't do this.

> +	lp->tx_reclaim_timer.function = (void *)tx_reclaim_skb;
> +
>  	spin_lock_init(&lp->lock);

Do not cast the function pointer to "void *" like this, it's ugly and entirely
not necessary.

Instead have a wrapper function that uses the correct types as specified
for timer functions, that calls the existing function.
