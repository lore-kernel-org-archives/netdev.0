From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Sun, 28 Jul 2013 06:40:52 -0400
Message-ID: <20130728104052.GA9876@neilslaptop.think-freely.org>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
 <20130726200630.GA20690@electric-eye.fr.zoreil.com>
 <20130726204245.GD11633@hmsreliant.think-freely.org>
 <20130726212403.GA25674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38531 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab3G1KlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 06:41:05 -0400
Content-Disposition: inline
In-Reply-To: <20130726212403.GA25674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 11:24:03PM +0200, Francois Romieu wrote:
> Neil Horman <nhorman@tuxdriver.com> :
> > On Fri, Jul 26, 2013 at 10:06:30PM +0200, Francois Romieu wrote:
> > > Neil Horman <nhorman@tuxdriver.com> :
> [...]
> > > > @@ -533,6 +533,11 @@ rx_status_loop:
> > > >  
> > > >  		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
> > > >  					 PCI_DMA_FROMDEVICE);
> > > > +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> > > > +			kfree_skb(skb);
> > > 
> > > 			dev->stats.rx_dropped++;
> > > 
> > > Sorry, I did not notice that skb contained newly received data :o/
> > > 
> > Yeah, this isn't needed.  The skb being mapped in is newly allocated, and
> > contains no data.  We haven't dropped anything here, so theres no need for the
> > stats bump.
> 
> Huh ?
> 
> [...error path...]
> 		kfree(skb);
> [...normal path...]
> 	cp_rx_skb(cp, skb, desc);
> 
> Afaiks it's the same skb. We drop data and a stats bump is needed.
> 
> [...]
> > Thoughts?
> 
> Nevermind. cp_start_xmit is a piece of it and it isn't your work to
> turn it into something sensible.
> 
So you agree with the patch as it stands?
Neil

> -- 
> Ueimor
> 
