From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] soc: ti/knav_dma: include dmaengine header
Date: Tue, 05 Sep 2017 09:12:55 -0700 (PDT)
Message-ID: <20170905.091255.625612405262199546.davem@davemloft.net>
References: <20170905083146.1289546-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arm@kernel.org, dave.jiang@intel.com, netdev@vger.kernel.org,
        m-karicheri2@ti.com, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdIEQM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:12:56 -0400
In-Reply-To: <20170905083146.1289546-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  5 Sep 2017 10:31:35 +0200

> A header file cleanup apparently caused a build regression
> with one driver using the knav infrastructure:
> 
> In file included from drivers/net/ethernet/ti/netcp_core.c:30:0:
> include/linux/soc/ti/knav_dma.h:129:30: error: field 'direction' has incomplete type
>   enum dma_transfer_direction direction;
>                               ^~~~~~~~~
> drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_txpipe_open':
> drivers/net/ethernet/ti/netcp_core.c:1349:21: error: 'DMA_MEM_TO_DEV' undeclared (first use in this function); did you mean 'DMA_MEMORY_MAP'?
>   config.direction = DMA_MEM_TO_DEV;
>                      ^~~~~~~~~~~~~~
>                      DMA_MEMORY_MAP
> drivers/net/ethernet/ti/netcp_core.c:1349:21: note: each undeclared identifier is reported only once for each function it appears in
> drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_setup_navigator_resources':
> drivers/net/ethernet/ti/netcp_core.c:1659:22: error: 'DMA_DEV_TO_MEM' undeclared (first use in this function); did you mean 'DMA_DESC_HOST'?
>   config.direction  = DMA_DEV_TO_MEM;
> 
> As the header is no longer included implicitly through netdevice.h,
> we should include it in the header that references the enum.
> 
> Fixes: 0dd5759dbb1c ("net: remove dmaengine.h inclusion from netdevice.h")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> If the cleanup patch hasn't been submitted for mainline yet, please
> add this fixup to the net-next tree, otherwise I'll merge it through
> arm-soc.

Applied to net-next.
