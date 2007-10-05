From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 16:27:51 -0700 (PDT)
Message-ID: <20071005.162751.118962534.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761371AbXJEX14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:27:56 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> > +static int niu_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> > +{
> > +	return -EINVAL;
> > +}
> 
> Why not leave function ptr null and get "-EOPNOTSUPP"

To be honest, it's there mostly to remind me that I need to implement
this routine :-)

> > +	spin_lock_irqsave(&np->lock, flags);
> > +	niu_enable_interrupts(np, 0);
> > +	spin_unlock_irqrestore(&np->lock, flags);
> > +
> > +	netif_device_detach(dev);
> 
> No need to drop lock for detach? all it does is call stop_queue()

I think I'm just being paranoid here, I think it's fine either
way.

> > +static void *niu_phys_alloc_coherent(struct device *dev, size_t size,
> > +				     u64 *dma_addr, gfp_t flag)
> > +{
> > +	unsigned long order = get_order(size);
> > +	unsigned long page = __get_free_pages(flag, order);
> > +
> > +	if (page == 0UL)
> > +		return NULL;
> > +	memset((char *)page, 0, PAGE_SIZE << order);
> > +	*dma_addr = __pa(page);
> > +
> > +	return (void *) page;
> > +}
> 
> Generic cod useful for other drivers??

Quite possibly, once we have something else that wants this
we can split it out into some generic place.  Currently I am
unaware of any such in-tree cases.

Thanks.
