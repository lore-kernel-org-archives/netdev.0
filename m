From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: pxa168_eth: PXA168_ETH should depend on HAS_DMA
Date: Thu,  9 Oct 2014 16:15:42 +0200
Message-ID: <1412864142-21468-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:44960 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755584AbaJIOPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 10:15:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NO_DMA=y:

drivers/built-in.o: In function `rxq_deinit':
pxa168_eth.c:(.text+0x2a2f2e): undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `txq_reclaim':
pxa168_eth.c:(.text+0x2a3044): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `txq_deinit':
pxa168_eth.c:(.text+0x2a310a): undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `txq_init':
pxa168_eth.c:(.text+0x2a3226): undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `rxq_init':
pxa168_eth.c:(.text+0x2a32d4): undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `init_hash_table':
pxa168_eth.c:(.text+0x2a3354): undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `rxq_refill':
pxa168_eth.c:(.text+0x2a345a): undefined reference to `dma_map_single'
drivers/built-in.o: In function `rxq_process':
pxa168_eth.c:(.text+0x2a39cc): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `pxa168_eth_remove':
pxa168_eth.c:(.text+0x2a3b84): undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `pxa168_eth_start_xmit':
pxa168_eth.c:(.text+0x2a3e8a): undefined reference to `dma_map_single'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/marvell/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index b3b72ad92d4a9de4..d323a695dfbcb4e3 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -64,7 +64,8 @@ config MVPP2
 
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
-	depends on (CPU_PXA168 || ARCH_BERLIN || COMPILE_TEST) && HAS_IOMEM
+	depends on HAS_IOMEM && HAS_DMA
+	depends on CPU_PXA168 || ARCH_BERLIN || COMPILE_TEST
 	select PHYLIB
 	---help---
 	  This driver supports the pxa168 Ethernet ports.
-- 
1.9.1
