From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Sat, 22 Sep 2012 07:46:40 +1000
Message-ID: <1348264000.1132.63.camel@pasglop>
References: <20120920.164558.2281417114805373564.davem@davemloft.net>
	 <20120921081531.67db8a7d0ac1b35426b22c45@canb.auug.org.au>
	 <1348179764.1132.35.camel@pasglop>
	 <20120920.185315.576326460331670020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, paulus@samba.org,
	linuxppc-dev@lists.ozlabs.org, mika.westerberg@linux.intel.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120920.185315.576326460331670020.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-20 at 18:53 -0400, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Fri, 21 Sep 2012 08:22:44 +1000
> 
> > Hrm, that's ancient gunk, I'll have to dig. We potentially can support
> > ISA devices DMA'ing from an ISA bridge... but via the iommu, which means
> > isa_virt_to_bus is a non-starter.
> > 
> > But then, do we really care ? IE. Is there single device that actually
> > requires ISA_DMA_API and that is expected to work on any currently
> > supported powerpc hw ? :-)
> > 
> > We don't even support PReP anymore, so that leaves us with what ?
> 
> ISA_DMA_API implies a fixed window of addresses which are <= 32-bits
> on the bus, which is a hardware requirement of these devices.
>
> isa_virt_to_bus() goes to that physical address, and the expection is
> that you use GFP_DMA and thus the physical addresses fit inside of
> an unsigned int.

Right, but on ppc, GFP_DMA is a nop (no separate ZONE_DMA, or rather all
of memory is ZONE_DMA). It's always been like that afaik.

We could support ISA device limited addressability using the iommu but
that would involve a map/unmap type API (which I remember we did support
in the old days by passing NULL to pci_map_*, but we dropped that along
the way).

> isa_virt_to_bus() basically amounts to a virt-->phys plus a cast.
> 
> > Anybody has an objection to turning ISA_DMA_API off ?
> 
> Then you can remove all of the DMA api stuff in powerpc's asm/dma.h
> but some of it looks like it might be in use.

I will dig a bit. I think there might be some users of the ISA DMA
engine for legacy floppies and parport on some early pSeries and CHRP
machines (including Pegasos).

Cheers,
Ben.
