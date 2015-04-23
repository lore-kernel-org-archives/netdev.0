From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/2] ethernet: amd: AMD_XGBE should depend on HAS_DMA
Date: Thu, 23 Apr 2015 19:59:33 +0200
Message-ID: <1429811974-7975-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:40164 "EHLO
	baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030389AbbDWSAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NO_DMA=y:

    drivers/built-in.o: In function `xgbe_probe':
    xgbe-main.c:(.text+0x2def0a): undefined reference to `dma_set_mask'
    xgbe-main.c:(.text+0x2def20): undefined reference to `dma_supported'
    drivers/built-in.o: In function `xgbe_rx_poll':
    xgbe-drv.c:(.text+0x2e0320): undefined reference to `dma_sync_single_for_cpu'
    xgbe-drv.c:(.text+0x2e035e): undefined reference to `dma_sync_single_for_cpu'
    drivers/built-in.o: In function `xgbe_unmap_rdata':
    xgbe-desc.c:(.text+0x2e5fe4): undefined reference to `dma_unmap_page'
    xgbe-desc.c:(.text+0x2e5ffa): undefined reference to `dma_unmap_single'
    xgbe-desc.c:(.text+0x2e604a): undefined reference to `dma_unmap_page'
    xgbe-desc.c:(.text+0x2e6084): undefined reference to `dma_unmap_page'
    drivers/built-in.o: In function `xgbe_alloc_pages':
    xgbe-desc.c:(.text+0x2e6156): undefined reference to `dma_map_page'
    xgbe-desc.c:(.text+0x2e6164): undefined reference to `dma_mapping_error'
    drivers/built-in.o: In function `xgbe_free_ring':
    xgbe-desc.c:(.text+0x2e63d4): undefined reference to `dma_unmap_page'
    xgbe-desc.c:(.text+0x2e640e): undefined reference to `dma_unmap_page'
    xgbe-desc.c:(.text+0x2e644a): undefined reference to `dma_free_coherent'
    drivers/built-in.o: In function `xgbe_init_ring':
    xgbe-desc.c:(.text+0x2e64d4): undefined reference to `dma_alloc_coherent'
    drivers/built-in.o: In function `xgbe_map_tx_skb':
    xgbe-desc.c:(.text+0x2e6628): undefined reference to `dma_map_single'
    xgbe-desc.c:(.text+0x2e6638): undefined reference to `dma_mapping_error'
    xgbe-desc.c:(.text+0x2e66b2): undefined reference to `dma_map_single'
    xgbe-desc.c:(.text+0x2e66c2): undefined reference to `dma_mapping_error'
    xgbe-desc.c:(.text+0x2e6762): undefined reference to `dma_map_page'
    xgbe-desc.c:(.text+0x2e6772): undefined reference to `dma_mapping_error'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/amd/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index c638c85f3954bc68..089c269637b725da 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -179,7 +179,7 @@ config SUNLANCE
 
 config AMD_XGBE
 	tristate "AMD 10GbE Ethernet driver"
-	depends on (OF_NET || ACPI) && HAS_IOMEM
+	depends on (OF_NET || ACPI) && HAS_IOMEM && HAS_DMA
 	select PHYLIB
 	select AMD_XGBE_PHY
 	select BITREVERSE
-- 
1.9.1
