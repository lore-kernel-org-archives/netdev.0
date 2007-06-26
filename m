From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH UPDATE]  Extract chip specific code out of lasi_82596.c
Date: Tue, 26 Jun 2007 23:47:55 +0200
Message-ID: <20070626214755.GA11551@electric-eye.fr.zoreil.com>
References: <20070626205145.GA21014@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55607 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757399AbXFZVtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 17:49:52 -0400
Content-Disposition: inline
In-Reply-To: <20070626205145.GA21014@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
[...]
> +static inline void init_rx_bufs(struct net_device *dev)
> +{
> +	struct i596_private *lp = netdev_priv(dev);
> +	struct i596_dma *dma = lp->dma;
> +	int i;
> +	struct i596_rfd *rfd;
> +	struct i596_rbd *rbd;
> +
> +	/* First build the Receive Buffer Descriptor List */
> +
> +	for (i = 0, rbd = dma->rbds; i < rx_ring_size; i++, rbd++) {
> +		dma_addr_t dma_addr;
> +		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ + 4);
> +
> +		if (skb == NULL)
> +			panic(KERN_ERR "%s: alloc_skb() failed", __FILE__);

The driver could use netdev_alloc_skb.

init_rx_bufs() should handle failure more gracefully and return a proper
status code.

[...]
> +static int init_i596_mem(struct net_device *dev)
> +{
[...]
> +	if (request_irq(dev->irq, &i596_interrupt, 0, "i82596", dev)) {
> +		printk(KERN_ERR "%s: IRQ %d not free\n", dev->name, dev->irq);
> +		goto failed_free_irq;
> +	}
[...]
> +failed_free_irq:
> +	free_irq(dev->irq, dev);

Oops.

-- 
Ueimor
