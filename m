From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH  kernel 2.6.34-rc5] lib8390: to be SMP safe
Date: Fri, 7 May 2010 05:47:48 +0900
Message-ID: <20100507054748.711826db.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
	<20100307070256.cb86716d.ken_kawasaki@spring.nifty.jp>
	<20100503194316.60c98272.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:60973 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522Ab0EFUsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:48:17 -0400
Received: from localhost.localdomain (eaoska324027.adsl.ppp.infoweb.ne.jp [115.176.53.27])by userg506.nifty.com with SMTP id o46Km8fj011028
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 05:48:08 +0900
In-Reply-To: <20100503194316.60c98272.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, I cancel this patch
and test it again.


Best Regards
Ken

> 
> lib8390:
> 	write the value "ENISR_ALL" to register "EN0_IMR"
> 	after enable_irq_lockdep_irqrestore. 
> 
> 	This patch avoids frequent transmit error on SMP system.
> 
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
> 
> ---
> 
> --- linux-2.6.34-rc6/drivers/net/lib8390.c.orig	2010-05-02 16:49:57.000000000 +0900
> +++ linux-2.6.34-rc6/drivers/net/lib8390.c	2010-05-02 18:09:18.000000000 +0900
> @@ -367,9 +367,9 @@ static netdev_tx_t __ei_start_xmit(struc
>  				dev->name, ei_local->tx1, ei_local->tx2, ei_local->lasttx);
>  		ei_local->irqlock = 0;
>  		netif_stop_queue(dev);
> -		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  		spin_unlock(&ei_local->page_lock);
>  		enable_irq_lockdep_irqrestore(dev->irq, &flags);
> +		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  		dev->stats.tx_errors++;
>  		return NETDEV_TX_BUSY;
>  	}
> @@ -407,10 +407,10 @@ static netdev_tx_t __ei_start_xmit(struc
>  
>  	/* Turn 8390 interrupts back on. */
>  	ei_local->irqlock = 0;
> -	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  
>  	spin_unlock(&ei_local->page_lock);
>  	enable_irq_lockdep_irqrestore(dev->irq, &flags);
> +	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
>  
>  	dev_kfree_skb (skb);
>  	dev->stats.tx_bytes += send_length;

