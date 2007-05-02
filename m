From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 14:45:38 -0700 (PDT)
Message-ID: <20070502.144538.68132264.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
	<20070502.124000.116378720.davem@davemloft.net>
	<1178141269.4820.109.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767085AbXEBVpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 17:45:38 -0400
In-Reply-To: <1178141269.4820.109.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 02 May 2007 14:27:49 -0700

> I see.  So IA64 always uses the SWIOTLB when it doesn't have IOMMU then?
> 
> I'm a bit confused.  Is it enough to just set the DMA mask to 40-bit and
> forget about all this checking?  I thought that wasn't enough.  A tx
> packet can be anywhere in 64-bit memory.  When it gets to the driver,
> pci_map will not do any translation even if DMA mask is set to 40-bit if
> it doesn't have IOMMU.  Is that right?

If the buffer doesn't meet the DMA mask specification, it should do
bounce buffering.

Have a look at lib/swiotlb.c, that is exactly what it appears to
be doing.
