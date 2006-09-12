From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] pcnet32: Magic number cleanup
Date: Tue, 12 Sep 2006 11:59:12 -0400
Message-ID: <4506D950.9030306@pobox.com>
References: <20060911174713.GA3978@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53472 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030244AbWILP7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 11:59:15 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060911174713.GA3978@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> @@ -2701,13 +2701,10 @@ static struct net_device_stats *pcnet32_
>  {
>  	struct pcnet32_private *lp = dev->priv;
>  	unsigned long ioaddr = dev->base_addr;
> -	u16 saved_addr;
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&lp->lock, flags);
> -	saved_addr = lp->a.read_rap(ioaddr);
>  	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
> -	lp->a.write_rap(ioaddr, saved_addr);
>  	spin_unlock_irqrestore(&lp->lock, flags);

This should be in a separate patch.  Even though it is mentioned in the 
patch description, this change is totally out of character when looking 
at the rest of the patch.

	Jeff


