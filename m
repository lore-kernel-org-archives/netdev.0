From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API debugging
Date: Fri, 21 Nov 2008 18:10:04 +0100
Message-ID: <20081121171004.GE1386@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com> <20081121165628.GD733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:3584 "EHLO
	WA4EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbYKURKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:10:11 -0500
Content-Disposition: inline
In-Reply-To: <20081121165628.GD733@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 05:56:28PM +0100, Ingo Molnar wrote:
> > +	return (entry->dev_addr >> HASH_FN_SHIFT) & HASH_FN_MASK;
> > +}
> > +
> > +static struct dma_debug_entry *dma_entry_alloc(void)
> > +{
> > +	gfp_t gfp = GFP_KERNEL | __GFP_ZERO;
> > +
> > +	if (in_atomic())
> > +		gfp |= GFP_ATOMIC;
> > +
> > +	return kmem_cache_alloc(dma_entry_cache, gfp);
> 
> hm. that slab allocation in the middle of DMA mapping ops makes me a 
> bit nervous. the DMA mapping ops are generally rather atomic.
> 
> and in_atomic() check there is a bug on !PREEMPT kernels, so it wont 
> fly.

I am not sure I understand this correctly. You say the check for
in_atomic() will break on !PREEMPT kernels?

> We dont have a gfp flag passed in as all the DMA mapping APIs really 
> expect all allocations having been done in advance already.

Hmm, I can change the code to pre-allocate a certain (configurable?)
number of these entries and disble the checking if we run out of it.

> Any chance to attach the debug entry to the iotlb entries themselves - 
> either during build time (for swiotlb) or during iommu init time (for 
> the hw iommu's) ?

Hm, I want to avoid that. This approach has the advantage that is
works independent of any dma_ops implementation. So it can be used to
find out if a DMA bug originates from the device driver or (in my case)
from the IOMMU driver.

Joerg

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

