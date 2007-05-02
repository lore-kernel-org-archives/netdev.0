From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 15:48:02 -0700 (PDT)
Message-ID: <20070502.154802.26506902.davem@davemloft.net>
References: <1178141269.4820.109.camel@dell>
	<20070502.144538.68132264.davem@davemloft.net>
	<1178148502.4820.117.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767154AbXEBWsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:48:01 -0400
In-Reply-To: <1178148502.4820.117.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 02 May 2007 16:28:22 -0700

> Is it correct to assume that all 64-bit systems using 64-bit
> dma_addr_t will either have real IOMMUs or will use SWIOTLB?  If
> this is true, we can just set the DMA mask to what is supported by
> the hardware and let pci_map_xxx() handle all necessary translations
> or bounce buffering.

This should work.

Especailly since every platform has to support 32-bit DMA masks, the
worst possible case is that the 40-bit DMA mask set fails, and you
have to fall back to 32-bit.

But since every driver has that fallback logic, it should be totally
transparent.

We might want to formalize that at some point to save driver code.
Ie. we'd have an interface that takes a prioritized array of DMA
masks the driver wants to use, and you get back the index that was
selected or an error if none of them could be accomodated.

It's just a tangental future cleanup idea, since we're discussing
this.
