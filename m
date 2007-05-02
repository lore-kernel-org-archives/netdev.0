From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 14:27:49 -0700
Message-ID: <1178141269.4820.109.camel@dell>
References: <20070502.001243.70193466.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
 <20070502.124000.116378720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2688 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767011AbXEBUlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 16:41:05 -0400
In-Reply-To: <20070502.124000.116378720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 12:40 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 2 May 2007 08:23:40 -0700
> 
> > A non-IOMMU system using 64-bit dma_addr_t will always set
> > CONFIG_HIGHMEM, right?
> 
> Nope, IA-64 is at least one example.
> 
> IA-64 has both IOMMU and non-IOMMU configurations, and
> never sets HIGHMEM.
> 

I see.  So IA64 always uses the SWIOTLB when it doesn't have IOMMU then?

I'm a bit confused.  Is it enough to just set the DMA mask to 40-bit and
forget about all this checking?  I thought that wasn't enough.  A tx
packet can be anywhere in 64-bit memory.  When it gets to the driver,
pci_map will not do any translation even if DMA mask is set to 40-bit if
it doesn't have IOMMU.  Is that right?

