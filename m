From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 05/10] x86: add check code for map/unmap_single code
Date: Sat, 22 Nov 2008 10:39:08 +0100
Message-ID: <20081122093908.GI29705@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-6-git-send-email-joerg.roedel@amd.com> <20081122120632M.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joerg.roedel@amd.com, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:42412 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbYKVJjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:39:10 -0500
Content-Disposition: inline
In-Reply-To: <20081122120632M.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2008 at 12:27:41PM +0900, FUJITA Tomonori wrote:
> On Fri, 21 Nov 2008 17:26:05 +0100
> Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > Impact: detect bugs in map/unmap_single usage
> > 
> > Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> > ---
> >  arch/x86/include/asm/dma-mapping.h |    9 +++++-
> >  arch/x86/include/asm/dma_debug.h   |   20 +++++++++++++
> >  arch/x86/kernel/pci-dma-debug.c    |   55 ++++++++++++++++++++++++++++++++++++
> >  3 files changed, 83 insertions(+), 1 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> > index 83d7b7d..c9bead2 100644
> > --- a/arch/x86/include/asm/dma-mapping.h
> > +++ b/arch/x86/include/asm/dma-mapping.h
> > @@ -98,9 +98,14 @@ dma_map_single(struct device *hwdev, void *ptr, size_t size,
> >  	       int direction)
> >  {
> >  	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
> > +	dma_addr_t addr;
> >  
> >  	BUG_ON(!valid_dma_direction(direction));
> > -	return ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> > +	addr = ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
> > +
> > +	debug_map_single(hwdev, ptr, size, direction, addr);
> 
> debug_map_single could fail due to OOM. Then debug_unmap_single in
> dma_unmap_single gives a false warning because it can't find the
> dma_debug_entry?

True. I will add a check to disable checking when a map operation has
failed.

Joerg
