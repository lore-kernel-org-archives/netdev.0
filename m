From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: synchronize DMA API usage by
 free_skb_rx_queue w/ gfar_new_page
Date: Mon, 30 Jan 2017 11:20:06 -0500 (EST)
Message-ID: <20170130.112006.2176540808791679531.davem@davemloft.net>
References: <20170129125220.12538-1-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@nxp.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asolokha@kb.kras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932165AbdA3QUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:20:18 -0500
In-Reply-To: <20170129125220.12538-1-asolokha@kb.kras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arseny Solokha <asolokha@kb.kras.ru>
Date: Sun, 29 Jan 2017 19:52:20 +0700

> From: Arseny Solokha <asolokha@kb.kras.ru>
> 
> In spite of switching to paged allocation of Rx buffers, the driver still
> called dma_unmap_single() in the Rx queues tear-down path.
> 
> The DMA region unmapping code in free_skb_rx_queue() basically predates
> the introduction of paged allocation to the driver. While being refactored,
> it apparently hasn't reflected the change in the DMA API usage by its
> counterpart gfar_new_page().
> 
> As a result, setting an interface to the DOWN state now yields the following:
 ...
> Even though the issue was discovered in 4.9 kernel, the code in question
> is identical in the current net and net-next trees.
> 
> Fixes: 75354148ce69 ("gianfar: Add paged allocation and Rx S/G")
> Signed-off-by: Arseny Solokha <asolokha@kb.kras.ru>

Applied, thanks.
