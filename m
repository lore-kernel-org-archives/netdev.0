From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 06:22:28 +0200
Message-ID: <20060410042228.GN27596@ens-lyon.fr>
References: <20060410040120.GA4860@ens-lyon.fr> <200604100607.33362.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	benh@kernel.crashing.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750972AbWDJEVc@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200604100607.33362.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2006 at 06:07:32AM +0200, Michael Buesch wrote:
> On Monday 10 April 2006 06:01, you wrote:
> > Since the driver already sets the correct dma_mask, there is no reason
> > to bail there. In fact if you have an iommu, I think you can have a
> > address above 1G which will be ok for the device (if it isn't true then
> > the powerpc dma_alloc_coherent with iommu needs to be fixed because it
> > doesn't respect the the dma_mask).
> > 
> > Please comment or apply.
> 
> NACK. Don't apply that patch.
> I know it is odd, but people are actually hitting these messages.
> Maybe benh can explain the issues. I don't know...
> 
Yes, I know they hit the message, that's from a message in some forum
that i got interested in the issue. It probably comes from an allocation
from:
http://www.linux-m32r.org/lxr/http/source/arch/powerpc/kernel/pci_direct_iommu.c#L32

Either the ppc code is wrong (it doesn't enforce dma_mask) either the
driver still works without the check.

Maybe ppc should do the same thing as i386:

47         if (dev == NULL || (dev->coherent_dma_mask < 0xffffffff))
48                 gfp |= GFP_DMA;

thanks,

Benoit

-- 
powered by bash/screen/(urxvt/fvwm|linux-console)/gentoo/gnu/linux OS
