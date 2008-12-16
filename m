From: David Miller <davem@davemloft.net>
Subject: Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Tue, 16 Dec 2008 01:22:47 -0800 (PST)
Message-ID: <20081216.012247.267028680.davem@davemloft.net>
References: <20081214.224800.125614949.davem@davemloft.net>
	<20081215133521.GA6697@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.huemer@sbg.ac.at, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751787AbYLPJWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:22:46 -0500
In-Reply-To: <20081215133521.GA6697@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 15 Dec 2008 13:35:21 +0000

> Could you try this patch, please?
 ...
> @@ -1503,6 +1503,11 @@ static int __netdev_rx(struct net_device *dev, int *quota)
>  		desc->status = 0;
>  		np->rx_done = (np->rx_done + 1) % DONE_Q_SIZE;
>  	}
> +
> +	if (*quota == 0) {	/* out of rx quota */
> +		retcode = 1;
> +		goto out;
> +	}
>  	writew(np->rx_done, np->base + CompletionQConsumerIdx);
>  
>   out:

Jarek this looks good and it looks to be tested as well.

Could you formally submit this?

Thanks.
