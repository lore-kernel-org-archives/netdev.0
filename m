From: David Miller <davem@davemloft.net>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 17 Apr 2015 13:19:56 -0400 (EDT)
Message-ID: <20150417.131956.2235150293184897656.davem@davemloft.net>
References: <21807.60995.462892.714138@mariner.uk.xensource.com>
	<1429224694.4720.68.camel@prashant>
	<21809.13544.303033.990277@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com,
	cascardo@linux.vnet.ibm.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	vyasevich@gmail.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, siva.kallam@broadcom.com,
	sanjeevb@broadcom.com
To: Ian.Jackson@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbDQRUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:20:00 -0400
In-Reply-To: <21809.13544.303033.990277@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Date: Fri, 17 Apr 2015 17:29:28 +0100

> Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
>> Ok this is what is causing the problem, the driver uses
>> DEFINE_DMA_UNMAP_ADDR(), dma_unmap_addr_set() to keep a copy of the dma
>> "mapping" and dma_unmap_addr() to get the "mapping" value. On most of
>> the platforms this is a no-op, but it appears with "iommu=soft and
>> swiotlb=force" this house keeping is required, when I pass the correct
>> dma_addr instead of 0 while calling pci_unmap_/pci_dma_sync_ I don't see
>> the corruption. ie If you set CONFIG_NEED_DMA_MAP_STATE=y in your kernel
>> config you should not see the problem. Can you confirm ? Thanks
> 
> That kernel config option is an automatically computed one:
> 
> config NEED_DMA_MAP_STATE
>         def_bool y
>         depends on X86_64 || INTEL_IOMMU || DMA_API_DEBUG
> 
> and grepping my .config shows:
> 
> # CONFIG_INTEL_IOMMU is not set
> # CONFIG_DMA_API_DEBUG is not set
> 
> It's a 32-bit kernel so it hasn't got X86_64 enabled either.
> 
> Arguably at least some of osstest's kernels should have INTEL_IOMMU
> enabled to detect conflicts between Xen's use of the iommu and
> possible attempts bo Linux to do the same thing, but not having it
> enabled should not cause a driver bug.

So the gist of the situation is, that NEED_DMA_MAP_STATE can be 'n' in
situations where we might actually need it to be 'y' based upon kernel
comman line boot options given.

Right?
