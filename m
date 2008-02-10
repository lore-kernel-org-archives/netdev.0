From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] [resend] 3c509: convert to isa_driver and pnp_driver v4
Date: Sun, 10 Feb 2008 00:18:55 -0500
Message-ID: <20080210051855.GA22064@infradead.org>
References: <200801312012.43447.linux@rainbow-software.org> <200802092233.10239.linux@rainbow-software.org> <20080209134805.29cbc8ae@extreme> <200802100110.09301.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60080 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbYBJFTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 00:19:01 -0500
Content-Disposition: inline
In-Reply-To: <200802100110.09301.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 10, 2008 at 01:10:07AM +0100, Ondrej Zary wrote:
> > > +typedef enum { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA } el3_cardtype;
> > > +
> >
> > No typedef please (see checkpatch)
> 
> Is there any standard way to solve this without a typedef? I added 
> el3_dev_fill() function which fills that card type value according to a 
> parameter passed to it. "int" could be used instead and "#define EL3_ISA 
> 0", "#define EL3_PNP 1" - but I think that's ugly.

enum el3_cardtype {
	EL3_ISA,
	EL3_PNP,
	EL3_MCA,
	EL3_EISA,
};

> > >  struct el3_private {
> > >  	struct net_device_stats stats;
> >
> > Use network device stats in net_device now
> 
> OK, looks like the driver will need some more patches.

While I agree with Stephens comment that this driver should be using
the stats in net_device that's totally out of scope for this patch.
As you're the defacto maintainer of this driver now it would be nice
if you could submit another one for it.

> > > -	struct net_device *next_dev;
> > >  	spinlock_t lock;
> > >  	/* skb send-queue */
> > >  	int head, size;
> > >  	struct sk_buff *queue[SKB_QUEUE_SIZE];
> >
> > What about sk_buff_head (linked list instead)?
> 
> I don't know anything about this, maybe in next patch.

Yes, separate patch please.

