From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Fix dma check map error when
 DMA_API_DEBUG is enabled
Date: Wed, 10 Dec 2014 13:13:47 -0500 (EST)
Message-ID: <20141210.131347.2165044584202384761.davem@davemloft.net>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
	<1418135075-17349-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haokexin@gmail.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbaLJSNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:13:50 -0500
In-Reply-To: <1418135075-17349-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 9 Dec 2014 16:24:35 +0200

> From: Kevin Hao <haokexin@gmail.com>
> 
> We need to use dma_mapping_error() to check the dma address returned
> by dma_map_single/page(). Otherwise we would get warning like this:
 ...
> For TX, we need to unmap the pages which has already been mapped and
> free the skb before return. For RX, just let the rxbdp as unempty.
> We can retry to initialize it to empty in next round.
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

The RX behavior needs to be adjusted.

You should never leave holes in the RX ring, ever.

Instead, try allocating the new RX skb first, and only if
you are successful should you pass up the original SKB.  If
it fails, then reuse the original SKB in the RX ring.
