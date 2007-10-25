From: Domen Puncer <domen.puncer@telargo.com>
Subject: Re: [PATCH v4] FEC - fast ethernet controller for mpc52xx
Date: Thu, 25 Oct 2007 21:41:14 +0200
Message-ID: <20071025194114.GH3369@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org> <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com> <20071025185706.29496.qmail@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:33294 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbXJYTlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 15:41:47 -0400
Content-Disposition: inline
In-Reply-To: <20071025185706.29496.qmail@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/10/07 11:57 -0700, Dale Farnsworth wrote:
> Domen wrote:
> > > use your platform's dma mapping functions, rather than virt_to_phys()
> > > 
> > > it might be the exact same implementation, inside the platform 
> > > internals, but drivers should not be using this directly.
> > 
> > I've replaced this with dma_map_single(), unmatched with
> > dma_unmap_single(), since bestcomm doesn't have a way to do that
> > and it's blank on ppc32 anyway.
> > 
> > Is this OK? PPC guys?
> 
> Even though dma_unmap_single() may be a no-op, calls to
> dma_map_single() must be matched with calls to dma_unmap_single().
> 
> Perhaps with the additions below:
> 
> > +static void mpc52xx_fec_free_rx_buffers(struct bcom_task *s)
> > +{
> > +	struct sk_buff *skb;
> > +
> > +	while (!bcom_queue_empty(s)) {
> > +		skb = bcom_retrieve_buffer(s, NULL, NULL);
> 
> 		dma_unmap_single(&skb->dev->dev, skb-data,
> 				 FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);

It looks to me like dma_unmap_single takes the mapped address
(what dma_map_single returned), and not the address we're mapping
(skb->data).


	Domen
