From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 14:24:53 -0400
Message-ID: <4638D775.3010905@garzik.org>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com> <4638AE42.5000908@garzik.org> <1178130232.4820.62.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60732 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767127AbXEBSY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 14:24:57 -0400
In-Reply-To: <1178130232.4820.62.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Wed, 2007-05-02 at 11:29 -0400, Jeff Garzik wrote:
>> Michael Chan wrote:
>>> A non-IOMMU system using 64-bit dma_addr_t will always set
>>> CONFIG_HIGHMEM, right?
>> No.
>>
> May be I misunderstood the code in illegal_highdma() in net/core/dev.c
> where it is checking to see if it needs to linearize the SKB when the
> device does not support 64-bit DMA.  I'm using similar assumptions for
> the 40-bit address check in the patch.

That function is just checking for highmem pages, no more, no less.

Your question quoted far above presumes that no 64-bit systems exist 
lacking IOMMUs, which is not the case.  64-bit platforms with a 64-bit 
dma_addr_t will /not/ set CONFIG_HIGHMEM, regardless of IOMMU presence.

Probably you want to base your actions on some combination of

* CONFIG_64BIT
* sizeof(dma_addr_t)
* pci_set_dma_mask() for >32 bit platforms

Regards,

	Jeff



