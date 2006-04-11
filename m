From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Tue, 11 Apr 2006 03:53:51 +0200
Message-ID: <200604110353.52067.mb@bu3sch.de>
References: <20060410040120.GA4860@ens-lyon.fr> <20060410042228.GN27596@ens-lyon.fr> <1144719972.19353.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
   Benoit Boissinot <benoit.boissinot-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1144719972.19353.24.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

On Tuesday 11 April 2006 03:46, you wrote:
> 
> > Yes, I know they hit the message, that's from a message in some forum
> > that i got interested in the issue. It probably comes from an allocation
> > from:
> > http://www.linux-m32r.org/lxr/http/source/arch/powerpc/kernel/pci_direct_iommu.c#L32
> > 
> > Either the ppc code is wrong (it doesn't enforce dma_mask) either the
> > driver still works without the check.
> > 
> > Maybe ppc should do the same thing as i386:
> > 
> > 47         if (dev == NULL || (dev->coherent_dma_mask < 0xffffffff))
> > 48                 gfp |= GFP_DMA;
> 
> PPC doesn't have a ZONE_DMA... PPC assumes that the whole memory is
> DMA'able... What happens here is that it works by "chance" on x86 ;)
> ZONE_DMA is a thing of the past that represents ISA DMA (below 16M iirc
> or something like that). Thus x86 historically maintained a separate
> allocation zone down there for ISA devices. What happens here is that
> the x86 code sort-of detects that the DMA mask isn't the full 32 bits
> and kicks everything down into ZONE_DMA. Makes things work, though the
> pressure on ZONE_DMA can often be high enough that you'll have a lot of
> failed allocations ...
> 
> PPC doesn't have ZONE_DMA, thus can't provide memory guaranteed to be
> below that limit.
> 
> Now, for ppc32, it should still sort-of work because all of lowmem is
> below 1Gb and people generally don't hack their lowmem size (well, I do
> but heh, that doesn't count :) and I don't think you'll get skb's in
> highmem. But ppc64 hits the problem and at this point, there is nothing
> I can do other than either implementing a split zone allocation mecanism
> in the ppc64 architecture

> for the sole sake of bcm43xx (ick !)

Nope. For every broadcom device, which has this stupid DMA engine.
That is b44 and bcm43xx, as far as I can tell. But likely there are more.

> or doing some trick with the iommu...

-- 
Greetings Michael.
