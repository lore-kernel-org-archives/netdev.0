From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Thu, 14 Nov 2013 16:37:57 -0500 (EST)
Message-ID: <20131114.163757.1438409591991025913.davem@davemloft.net>
References: <1384394230-23380-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757995Ab3KNVh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:37:59 -0500
In-Reply-To: <1384394230-23380-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Thu, 14 Nov 2013 09:57:10 +0800

> The driver fails to check the results of DMA mapping and results in
> the following warning: (with kernel config "CONFIG_DMA_API_DEBUG" enable)
 ...
> Because dma-debug add new interfaces to debug dma mapping errors, pls refer
> to: http://lwn.net/Articles/516640/
> 
> After dma mapping, it must call dma_mapping_error() to check mapping error,
> otherwise the map_err_type alway is MAP_ERR_NOT_CHECKED, check_unmap() define
> the mapping is not checked and dump the error msg. So,add dma_mapping_error()
> checking to fix the WARNING
> 
> And RX DMA buffers are used repeatedly and the driver copies it into an skb,
> fec_enet_rx() should not map or unmap, use dma_sync_single_for_cpu()/dma_sync_single_for_device()
> instead of dma_map_single()/dma_unmap_single().
> 
> There have another potential issue:  fec_enet_rx() passes the DMA address to __va().
> Physical and DMA addresses are *not* the same thing. They may differ if the device
> is behind an IOMMU or bounce buffering was required, or just because there is a fixed
> offset between the device and host physical addresses. Also fix it in this patch.
> 
> =============================================
> V2: add net_ratelimit() to limit map err message.
>     use dma_sync_single_for_cpu() instead of dma_map_single().
>     fix the issue that pass DMA addresses to __va() to get virture address.
> V1: initial send
> =============================================
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks a lot.
