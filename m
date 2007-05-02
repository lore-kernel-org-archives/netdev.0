From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 16:28:22 -0700
Message-ID: <1178148502.4820.117.camel@dell>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
 <20070502.124000.116378720.davem@davemloft.net>
 <1178141269.4820.109.camel@dell>
 <20070502.144538.68132264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2202 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766800AbXEBWl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 18:41:28 -0400
In-Reply-To: <20070502.144538.68132264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 14:45 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 02 May 2007 14:27:49 -0700
> 
> > I see.  So IA64 always uses the SWIOTLB when it doesn't have IOMMU then?
> > 
> > I'm a bit confused.  Is it enough to just set the DMA mask to 40-bit and
> > forget about all this checking?  I thought that wasn't enough.  A tx
> > packet can be anywhere in 64-bit memory.  When it gets to the driver,
> > pci_map will not do any translation even if DMA mask is set to 40-bit if
> > it doesn't have IOMMU.  Is that right?
> 
> If the buffer doesn't meet the DMA mask specification, it should do
> bounce buffering.
> 
> Have a look at lib/swiotlb.c, that is exactly what it appears to
> be doing.
> 

OK.  Is it correct to assume that all 64-bit systems using 64-bit
dma_addr_t will either have real IOMMUs or will use SWIOTLB?  If this is
true, we can just set the DMA mask to what is supported by the hardware
and let pci_map_xxx() handle all necessary translations or bounce
buffering.

