From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 11/16] dma-debug: add checking for [alloc|free]_coherent
Date: Sun, 11 Jan 2009 08:59:19 +0100
Message-ID: <20090111075919.GJ9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-12-git-send-email-joerg.roedel@amd.com> <20090111150026Y.fujita.tomonori@lab.ntt.co.jp> <20090111153011H.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com, netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:38440 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbZAKH7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 02:59:20 -0500
Content-Disposition: inline
In-Reply-To: <20090111153011H.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 03:30:14PM +0900, FUJITA Tomonori wrote:
> On Sun, 11 Jan 2009 15:25:42 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > On Fri, 9 Jan 2009 17:19:25 +0100
> > Joerg Roedel <joerg.roedel@amd.com> wrote:
> > 
> > > Impact: add debug callbacks for dma_[alloc|free]_coherent
> > > 
> > > Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> > > ---
> > >  include/linux/dma-debug.h |   16 ++++++++++++++++
> > >  lib/dma-debug.c           |   45 +++++++++++++++++++++++++++++++++++++++++++++
> > >  2 files changed, 61 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
> > > index b2131f4..a28a701 100644
> > > --- a/include/linux/dma-debug.h
> > > +++ b/include/linux/dma-debug.h
> > > @@ -40,6 +40,12 @@ extern void debug_map_sg(struct device *dev, struct scatterlist *sg,
> > >  extern void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
> > >  			   int nelems, int dir);
> > >  
> > > +extern void debug_alloc_coherent(struct device *dev, size_t size,
> > > +				 dma_addr_t dma_addr, void *virt);
> > > +
> > > +extern void debug_free_coherent(struct device *dev, size_t size,
> > > +				void *virt, dma_addr_t addr);
> > > +
> > >  #else /* CONFIG_DMA_API_DEBUG */
> > >  
> > >  static inline void dma_debug_init(u32 num_entries)
> > > @@ -68,6 +74,16 @@ static inline void debug_unmap_sg(struct device *dev,
> > >  {
> > >  }
> > >  
> > > +static inline void debug_alloc_coherent(struct device *dev, size_t size,
> > > +					dma_addr_t dma_addr, void *virt)
> > > +{
> > > +}
> > > +
> > > +static inline void debug_free_coherent(struct device *dev, size_t size,
> > > +				       void *virt, dma_addr_t addr)
> > > +{
> > > +}
> > > +
> > >  #endif /* CONFIG_DMA_API_DEBUG */
> > >  
> > >  #endif /* __DMA_DEBUG_H */
> > > diff --git a/lib/dma-debug.c b/lib/dma-debug.c
> > > index e6d45f9..a4a5b0f 100644
> > > --- a/lib/dma-debug.c
> > > +++ b/lib/dma-debug.c
> > > @@ -604,3 +604,48 @@ void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
> > >  }
> > >  EXPORT_SYMBOL(debug_unmap_sg);
> > >  
> > > +void debug_alloc_coherent(struct device *dev, size_t size,
> > > +			  dma_addr_t dma_addr, void *virt)
> > > +{
> > > +	struct dma_debug_entry *entry;
> > > +
> > > +	if (global_disable)
> > > +		return;
> > > +
> > > +	if (dma_addr == bad_dma_address)
> > > +		return;
> > 
> > Only X86 has 'bad_dma_address' (IA64 also has with some configurations
> > though). You need to use dma_mapping_error, as I pointed out in the
> > previous submission.
> 
> Oops, this is for dma_alloc_coherent so you need to check 'virt'
> instead of dma_mapping_error().

Ah, true. Thanks. I will fix that.

Joerg
