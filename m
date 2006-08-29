From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/5] skge: use dev_alloc_skb
Date: Tue, 29 Aug 2006 13:28:10 -0700
Message-ID: <20060829132810.30a18d72@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
	<20060828232038.303254635@localhost.localdomain>
	<20060829112336.GA23975@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13520 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965044AbWH2U2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:28:33 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060829112336.GA23975@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006 12:23:36 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Aug 28, 2006 at 04:19:37PM -0700, Stephen Hemminger wrote:
> > To avoid problems with buggy protocols that assume extra header space,
> > use dev_alloc_skb() when allocating receive buffers.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> > --- skge-2.6.orig/drivers/net/skge.c
> > +++ skge-2.6/drivers/net/skge.c
> > @@ -827,7 +827,8 @@ static int skge_rx_fill(struct skge_port
> >  	do {
> >  		struct sk_buff *skb;
> >  
> > -		skb = alloc_skb(skge->rx_buf_size + NET_IP_ALIGN, GFP_KERNEL);
> > +		skb = __dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN,
> > +				      GFP_KERNEL);
> 
> While you're at it please use netdev_alloc_skb.
> 

Okay, that will be in the next clump.

-- 
Stephen Hemminger <shemminger@osdl.org>
