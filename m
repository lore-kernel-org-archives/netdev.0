From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH] net: mvneta: remove useless RX descriptor prefetch
Date: Thu, 31 Mar 2016 15:15:01 +0800
Message-ID: <20160331151501.27fe34d5@xhacker>
References: <1459406190-2334-1-git-send-email-jszhang@marvell.com>
	<20160331144537.20f04a8c@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <thomas.petazzoni@free-electrons.com>,
	<gregory.clement@free-electrons.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160331144537.20f04a8c@xhacker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Thu, 31 Mar 2016 14:45:37 +0800 Jisheng Zhang wrote:

> Hi,
> 
> + linux arm kernel
> 
> On Thu, 31 Mar 2016 14:36:30 +0800 Jisheng Zhang wrote:
> 
> > The rx descriptors are allocated using dma_alloc_coherent, so prefetch
> > doesn't really happen at all.  
> 
> This is for RFC, I'm sorry to send it without changing its title -- s/PATCH/RFC.
> 
> I'm not sure whether there's any benefit to prefetch on space allocated from
> dma_alloc_coherent.

After more consideration, I think my patch is wrong.

As for coherent platforms, the space allocated from dma_alloc_coherent is
cacheable, so prefetch would definitely benefit us.

As for noncoherent platforms, the space allocated from dma_alloc_coherent is
uncacheable, but prefetch on arm/arm64 is implemented via. pld/prfm, the op
would be nop if target address is uncacheable.

So let's drop this patch.

Thanks,
Jisheng


> 
> Thanks
> 
> > 
> > Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> > ---
> >  drivers/net/ethernet/marvell/mvneta.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> > index 5880871..6c09a27 100644
> > --- a/drivers/net/ethernet/marvell/mvneta.c
> > +++ b/drivers/net/ethernet/marvell/mvneta.c
> > @@ -757,7 +757,6 @@ mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
> >  	int rx_desc = rxq->next_desc_to_proc;
> >  
> >  	rxq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);
> > -	prefetch(rxq->descs + rxq->next_desc_to_proc);
> >  	return rxq->descs + rx_desc;
> >  }
> >    
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
