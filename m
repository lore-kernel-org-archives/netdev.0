From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: RE: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Sun, 4 Apr 2010 19:03:09 +0900
Message-ID: <20100404190116N.fujita.tomonori@lab.ntt.co.jp>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDB@SJEXCHCCR02.corp.ad.broadcom.com>
	<20100404.013920.120463402.davem@davemloft.net>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:60062 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599Ab0DDKDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 06:03:16 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 Apr 2010 02:15:52 -0700
"Vladislav Zolotarov" <vladz@broadcom.com> wrote:

> According to the changes in a PCI-DMA-mapping.txt it sounds like the
> trend is to stop using the pci_dma_* API and start using the dma_*
> API instead. Does this mean that using the pci_dma_* API is
> deprecated?

Sorry that I didn't put the enough information in the patch
description.

In the long term, I want to remove the pci_dma_* API.

We had the various bus-specific DMA API (pci, sbus, etc). It was the
headache for driver writers that handle multiple bus devices. So we
invented the generic DMA API long ago. Now we have only two bus
specific APIs: pci and ssb so I want to remove them and make sure that
driver writers are always able to use the generic DMA API with any
bus.

http://lwn.net/Articles/374137/


I don't plan to convert the whole tree to use the DMA API over the PCI
DMA API all together. I convert the drivers gradually. I already
removed the PCI DMA API from the docs under Documentation/. It would
be nice if some driver maintainers (or others) convert their drivers.

The patchset convert only the pci state API (such as
DECLARE_PCI_UNMAP_ADDR) because akpm complained of the API and I
promised him to clean up it:

http://lkml.org/lkml/2010/2/12/415


I'll send a patch if you like me to convert bnx2x to use the the DMA
API completely.

