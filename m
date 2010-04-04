From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Sun, 4 Apr 2010 03:24:46 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDD@SJEXCHCCR02.corp.ad.broadcom.com>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDB@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100404.013920.120463402.davem@davemloft.net>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100404190116N.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1095 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab0DDKY4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 06:24:56 -0400
In-Reply-To: <20100404190116N.fujita.tomonori@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok. Got it now. Thanks, Fujita. I think we should patch the bnx2x to use the generic model (not just the mapping macros).

One last question: since which kernel version the generic DMA layer may be used instead of PCI DMA layer?

Thanks,
vlad

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of FUJITA Tomonori
> Sent: Sunday, April 04, 2010 1:03 PM
> To: Vladislav Zolotarov
> Cc: davem@davemloft.net; fujita.tomonori@lab.ntt.co.jp; 
> netdev@vger.kernel.org; Eilon Greenstein
> Subject: RE: [PATCH] bnx2x: use the dma state API instead of 
> the pci equivalents
> 
> On Sun, 4 Apr 2010 02:15:52 -0700
> "Vladislav Zolotarov" <vladz@broadcom.com> wrote:
> 
> > According to the changes in a PCI-DMA-mapping.txt it sounds like the
> > trend is to stop using the pci_dma_* API and start using the dma_*
> > API instead. Does this mean that using the pci_dma_* API is
> > deprecated?
> 
> Sorry that I didn't put the enough information in the patch
> description.
> 
> In the long term, I want to remove the pci_dma_* API.
> 
> We had the various bus-specific DMA API (pci, sbus, etc). It was the
> headache for driver writers that handle multiple bus devices. So we
> invented the generic DMA API long ago. Now we have only two bus
> specific APIs: pci and ssb so I want to remove them and make sure that
> driver writers are always able to use the generic DMA API with any
> bus.
> 
> http://lwn.net/Articles/374137/
> 
> 
> I don't plan to convert the whole tree to use the DMA API over the PCI
> DMA API all together. I convert the drivers gradually. I already
> removed the PCI DMA API from the docs under Documentation/. It would
> be nice if some driver maintainers (or others) convert their drivers.
> 
> The patchset convert only the pci state API (such as
> DECLARE_PCI_UNMAP_ADDR) because akpm complained of the API and I
> promised him to clean up it:
> 
> http://lkml.org/lkml/2010/2/12/415
> 
> 
> I'll send a patch if you like me to convert bnx2x to use the the DMA
> API completely.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
