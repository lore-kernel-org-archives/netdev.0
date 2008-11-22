From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Sat, 22 Nov 2008 10:33:18 +0100
Message-ID: <20081122093318.GG29705@8bytes.org>
References: <1227288269.4901.222.camel@macbook.infradead.org> <20081121172722.GG1386@amd.com> <20081121174551.GC4336@elte.hu> <20081122122730W.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, mingo@redhat.com,
	netdev@vger.kernel.org, tglx@linutronix.de
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:46028 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbYKVJdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:33:19 -0500
Content-Disposition: inline
In-Reply-To: <20081122122730W.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2008 at 12:27:43PM +0900, FUJITA Tomonori wrote:
> On Fri, 21 Nov 2008 18:45:51 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > * Joerg Roedel <joerg.roedel@amd.com> wrote:
> > 
> > > On Fri, Nov 21, 2008 at 05:24:29PM +0000, David Woodhouse wrote:
> > > > On Fri, 2008-11-21 at 18:20 +0100, Joerg Roedel wrote:
> > > > > Ok, I will move the generic bits to lib/ and include/linux and let
> > > > > architectures decide if they want to use it.
> > > > 
> > > > Once you've done that, I'll try to hook it up on PowerPC to make 
> > > > sure it works there.
> > > 
> > > Ok, cool. Thanks
> > 
> > i'll give it a whirl on x86 once the allocation bug is resolved. x86 
> > testing will be the most interesting in practice, because most drivers 
> > there are developed with no dynamic DMA in mind. (many of the x86 
> > drivers were developed before IOMMUs were supported in Linux)
> 
> Yeah, one of the problems due to this is that some drivers wrongly
> assume that the dma mapping operations never fail (they do DMA with a
> wrong address). With VT-d and AMD IOMMU, the dma mapping operations
> fail just because of OOM.

At least AMD IOMMU code will not fail because of memory shortage. All
necessary data structures, including the pagetables, are preallocated.
The only place were it might fail is dma_alloc_coherent. But that is not
specific to that driver.

> Some time ago, I hooked the fault injection mechanism to the dma
> mapping operations (I linked struct fault_attr to struct pci_dev so
> you can make dma_map_single/sg fail with a particular pci device). It
> might interest some people:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git dmafault

This would also be helpful to find bugs in drivers together with this
code. Do you plan to submit it?

Joerg
