From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ps3: Fix gelic RX DMA restart
Date: Thu, 14 Jul 2011 16:03:40 -0700 (PDT)
Message-ID: <20110714.160340.670777033431904110.davem@davemloft.net>
References: <4E1F242E.7070509@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437Ab1GNXGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 19:06:51 -0400
In-Reply-To: <4E1F242E.7070509@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoff@infradead.org>
Date: Thu, 14 Jul 2011 10:15:26 -0700

> Fix the condition where PS3 network RX hangs when no network
> TX is occurring by calling gelic_card_enable_rxdmac() during
> RX_DMA_CHAIN_END event processing.
> 
> The gelic hardware automatically clears its RX_DMA_EN flag when
> it detects an RX_DMA_CHAIN_END event.  In its processing of
> RX_DMA_CHAIN_END the gelic driver is required to set RX_DMA_EN
> (with a call to gelic_card_enable_rxdmac()) to restart RX DMA
> transfers.  The existing gelic driver code does not set
> RX_DMA_EN directly in its processing of the RX_DMA_CHAIN_END
> event, but uses a flag variable card->rx_dma_restart_required
> to schedule the setting of RX_DMA_EN until next inside the
> interrupt handler.
> 
> It seems this delayed setting of RX_DMA_EN causes the hang since
> the next RX interrupt after the RX_DMA_CHAIN_END event where
> RX_DMA_EN is scheduled to be set will not occur since RX_DMA_EN
> was not set.  In the case were network TX is occuring, RX_DMA_EN
> is set in the next TX interrupt and RX processing continues.
> 
> Signed-off-by: Geoff Levand <geoff@infradead.org>

Applied.
