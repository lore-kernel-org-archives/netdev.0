From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
Date: Tue, 3 Jul 2007 12:04:30 -0700
Message-ID: <20070703120430.4dcbba68@freepuppy.localdomain.hemminger.net>
References: <200706291330.37070.yinghai.lu@sun.com>
	<20070703115840.e05a0f47.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <Yinghai.Lu@Sun.COM>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41163 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757275AbXGCTEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 15:04:47 -0400
In-Reply-To: <20070703115840.e05a0f47.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Jul 2007 11:58:40 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 29 Jun 2007 13:30:36 -0700
> Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:
> 
> > [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
> 
> Please copy netdev@vger.kernel.org on net patches.
> 
> This patch modifies a net driver as well as the networking core.  These
> subsytems have different maintainers who run different development trees. 
> Consequently I must split your patch into two and change their titles and
> changelogs appropriately.
> 
> Please do this for us in future, thanks.
> 
> 
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > index 42ba1c0..6d53b52 100644
> > --- a/drivers/net/forcedeth.c
> > +++ b/drivers/net/forcedeth.c
> > @@ -1383,7 +1383,7 @@ static int nv_alloc_rx(struct net_device *dev)
> >  		less_rx = np->last_rx.orig;
> >  
> >  	while (np->put_rx.orig != less_rx) {
> > -		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
> > +		struct sk_buff *skb = dev_alloc_skb_node(np->rx_buf_sz + NV_RX_ALLOC_PAD, dev_to_node(&dev->dev));
> 
> If we're going to do this then it would probably make sense to change
> dev_alloc_skb_node() so that it takes a `struct net_device *' rather than a
> bare node-id.  That's a call which the net guys will need to make, which is
> why we cc them on our emails.

The driver should use netdev_alloc_skb. That routine is supposed to be overriden
on architecture's that need per node changes.

> >  		if (skb) {
> >  			np->put_rx_ctx->skb = skb;
> >  			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
> > @@ -1415,7 +1415,7 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
> >  		less_rx = np->last_rx.ex;
> >  
> >  	while (np->put_rx.ex != less_rx) {
> > -		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
> > +		struct sk_buff *skb = dev_alloc_skb_node(np->rx_buf_sz + NV_RX_ALLOC_PAD, dev_to_node(&dev->dev));
> 
> It might help to edit code in an 80-col xterm.
> 
> Please run scritps/checkpatch.pl across all your diffs.  Its suggestions
> are by no means compulsory, but they do provide things for you to check up
> and and have a think about, thanks.
> 
> I won't apply this (these) patches because I expect API changes.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
