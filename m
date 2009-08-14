From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yellowfin: Fix buffer underrun after dev_alloc_skb()
 failure
Date: Fri, 14 Aug 2009 16:17:01 -0700 (PDT)
Message-ID: <20090814.161701.02803885.davem@davemloft.net>
References: <4A7C6B08.1040800@gmail.com>
	<20090812.210845.84504668.davem@davemloft.net>
	<4A853572.70209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754008AbZHNXQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:16:50 -0400
In-Reply-To: <4A853572.70209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 14 Aug 2009 11:59:14 +0200

>  	/* Reset the chip. */
>  	iowrite32(0x80000000, ioaddr + DMACtrl);
>  
> -	i = request_irq(dev->irq, &yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
> -	if (i) return i;
> +	ret = request_irq(dev->irq, &yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
> +	if (ret)
> +		return ret;
>  
>  	if (yellowfin_debug > 1)
>  		printk(KERN_DEBUG "%s: yellowfin_open() irq %d.\n",
>  			   dev->name, dev->irq);
>  
> -	yellowfin_init_ring(dev);
> +	ret = yellowfin_init_ring(dev);
> +	if (ret)
> +		return ret;
>  
>  	iowrite32(yp->rx_ring_dma, ioaddr + RxPtr);
>  	iowrite32(yp->tx_ring_dma, ioaddr + TxPtr);

If yellowfin_init_ring() returns an error, you're leaking the IRQ
allocated by request_irq().
