From: David Miller <davem@davemloft.net>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 17 Apr 2015 15:12:08 -0400 (EDT)
Message-ID: <20150417.151208.1757850423694976996.davem@davemloft.net>
References: <20150417.131956.2235150293184897656.davem@davemloft.net>
	<1429292769.6668.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<20150417190448.GA9462@l.oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org, Ian.Jackson@eu.citrix.com,
	prashant@broadcom.com, cascardo@linux.vnet.ibm.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	vyasevich@gmail.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, siva.kallam@broadcom.com,
	sanjeevb@broadcom.com
To: konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbbDQTMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 15:12:12 -0400
In-Reply-To: <20150417190448.GA9462@l.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Fri, 17 Apr 2015 15:04:48 -0400

> From 9e417af099e3cee2b219ab28ffc1e96b0564b213 Mon Sep 17 00:00:00 2001
> From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Date: Fri, 17 Apr 2015 14:55:47 -0400
> Subject: [PATCH] config: Enable NEED_DMA_MAP_STATE when SWIOTLB is selected
> 
> A huge amount of NIC drivers use the DMA API, however if compiled
> under 32-bit an very important part of the DMA API can be ommitted leading
> to the drivers not working at all (especially if used with
> 'swiotlb=force iommu=soft').
> 
> As Prashant Sreedharan explains it: "the driver [tg3] uses
> DEFINE_DMA_UNMAP_ADDR(), dma_unmap_addr_set() to keep a copy of the dma
> "mapping" and dma_unmap_addr() to get the "mapping" value. On most of
> the platforms this is a no-op, but ... with "iommu=soft and
> swiotlb=force" this house keeping is required, ... otherwise
> we pass 0 while calling pci_unmap_/pci_dma_sync_ instead of the
> DMA address."
> 
> As such enable this even when using 32-bit kernels.
> 
> Reported-by: Ian Jackson <Ian.Jackson@eu.citrix.com>
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Acked-by: David S. Miller <davem@davemloft.net>
