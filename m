From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [PATCH UPDATE]  Extract chip specific code out of lasi_82596.c
Date: Wed, 27 Jun 2007 00:17:36 +0200
Message-ID: <20070626221736.GA22252@alpha.franken.de>
References: <20070626205145.GA21014@alpha.franken.de> <20070626214755.GA11551@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:60799 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755982AbXFZWRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 18:17:41 -0400
Content-Disposition: inline
In-Reply-To: <20070626214755.GA11551@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2007 at 11:47:55PM +0200, Francois Romieu wrote:
> Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
> [...]
> > +static inline void init_rx_bufs(struct net_device *dev)
> > +{
> > +	struct i596_private *lp = netdev_priv(dev);
> > +	struct i596_dma *dma = lp->dma;
> > +	int i;
> > +	struct i596_rfd *rfd;
> > +	struct i596_rbd *rbd;
> > +
> > +	/* First build the Receive Buffer Descriptor List */
> > +
> > +	for (i = 0, rbd = dma->rbds; i < rx_ring_size; i++, rbd++) {
> > +		dma_addr_t dma_addr;
> > +		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ + 4);
> > +
> > +		if (skb == NULL)
> > +			panic(KERN_ERR "%s: alloc_skb() failed", __FILE__);
> 
> The driver could use netdev_alloc_skb.

what's the advantage ?

> init_rx_bufs() should handle failure more gracefully and return a proper
> status code.

of course.

> 
> [...]
> > +static int init_i596_mem(struct net_device *dev)
> > +{
> [...]
> > +	if (request_irq(dev->irq, &i596_interrupt, 0, "i82596", dev)) {
> > +		printk(KERN_ERR "%s: IRQ %d not free\n", dev->name, dev->irq);
> > +		goto failed_free_irq;
> > +	}
> [...]
> > +failed_free_irq:
> > +	free_irq(dev->irq, dev);
> 
> Oops.

thanks, will fix.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
