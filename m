From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 13:02:41 -0700
Message-ID: <1178136161.4820.91.camel@dell>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
 <4638AE42.5000908@garzik.org> <1178130232.4820.62.camel@dell>
 <4638D775.3010905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4965 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766898AbXEBUHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 16:07:12 -0400
In-Reply-To: <4638D775.3010905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 14:24 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> > On Wed, 2007-05-02 at 11:29 -0400, Jeff Garzik wrote:
> >> Michael Chan wrote:
> >>> A non-IOMMU system using 64-bit dma_addr_t will always set
> >>> CONFIG_HIGHMEM, right?
> >> No.
> >>
> > May be I misunderstood the code in illegal_highdma() in net/core/dev.c
> > where it is checking to see if it needs to linearize the SKB when the
> > device does not support 64-bit DMA.  I'm using similar assumptions for
> > the 40-bit address check in the patch.
> 
> That function is just checking for highmem pages, no more, no less.
> 

Let's say I have a 32-bit card that cannot do dual address cycle on a
64-bit dma_addr_t system without IOMMU.  If CONFIG_HIGHMEM is not set,
wouldn't the device get > 32-bit DMA addresses that it cannot handle?

> Your question quoted far above presumes that no 64-bit systems exist 
> lacking IOMMUs, which is not the case.  64-bit platforms with a 64-bit 
> dma_addr_t will /not/ set CONFIG_HIGHMEM, regardless of IOMMU presence.

I know that there are 64-bit systems without IOMMUs.  That's why we need
the workaround code.  Otherwise we can always just set the DMA mask to
40-bit and let the IOMMU handle the translation.  I'm trying to come up
with the right conditions to determine whether the address checking is
needed or not.  These systems without IOMMU must support 32-bit only
cards, right?  How do they do that if they are not using CONFIG_HIGHMEM?

> 
> Probably you want to base your actions on some combination of
> 
> * CONFIG_64BIT
> * sizeof(dma_addr_t)
> * pci_set_dma_mask() for >32 bit platforms
> 

Sure I can use these if CONFIG_HIGHMEM is not right.



