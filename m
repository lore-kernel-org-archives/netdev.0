From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Fri, 26 Jul 2013 23:24:03 +0200
Message-ID: <20130726212403.GA25674@electric-eye.fr.zoreil.com>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
 <20130726200630.GA20690@electric-eye.fr.zoreil.com>
 <20130726204245.GD11633@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32894 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760623Ab3GZVYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:24:13 -0400
Content-Disposition: inline
In-Reply-To: <20130726204245.GD11633@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> :
> On Fri, Jul 26, 2013 at 10:06:30PM +0200, Francois Romieu wrote:
> > Neil Horman <nhorman@tuxdriver.com> :
[...]
> > > @@ -533,6 +533,11 @@ rx_status_loop:
> > >  
> > >  		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
> > >  					 PCI_DMA_FROMDEVICE);
> > > +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> > > +			kfree_skb(skb);
> > 
> > 			dev->stats.rx_dropped++;
> > 
> > Sorry, I did not notice that skb contained newly received data :o/
> > 
> Yeah, this isn't needed.  The skb being mapped in is newly allocated, and
> contains no data.  We haven't dropped anything here, so theres no need for the
> stats bump.

Huh ?

[...error path...]
		kfree(skb);
[...normal path...]
	cp_rx_skb(cp, skb, desc);

Afaiks it's the same skb. We drop data and a stats bump is needed.

[...]
> Thoughts?

Nevermind. cp_start_xmit is a piece of it and it isn't your work to
turn it into something sensible.

-- 
Ueimor
