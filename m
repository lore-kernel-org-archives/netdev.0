From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 2/2] ethernet: arc: ARC_EMAC and EMAC_ROCKCHIP should depend on HAS_DMA
Date: Thu, 23 Apr 2015 19:59:34 +0200
Message-ID: <1429811974-7975-2-git-send-email-geert@linux-m68k.org>
References: <1429811974-7975-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429811974-7975-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    drivers/built-in.o: In function `arc_emac_tx_clean':
    emac_main.c:(.text+0x2decde): undefined reference to `dma_unmap_single'
    drivers/built-in.o: In function `arc_emac_rx':
    emac_main.c:(.text+0x2dee1c): undefined reference to `dma_unmap_single'
    emac_main.c:(.text+0x2dee72): undefined reference to `dma_map_single'
    emac_main.c:(.text+0x2dee7e): undefined reference to `dma_mapping_error'
    drivers/built-in.o: In function `arc_emac_probe':
    (.text+0x2df2ee): undefined reference to `dmam_alloc_coherent'
    drivers/built-in.o: In function `arc_emac_open':
    emac_main.c:(.text+0x2df6d8): undefined reference to `dma_map_single'
    emac_main.c:(.text+0x2df6e4): undefined reference to `dma_mapping_error'
    drivers/built-in.o: In function `arc_emac_tx':
    emac_main.c:(.text+0x2df9e4): undefined reference to `dma_map_single'
    emac_main.c:(.text+0x2df9f0): undefined reference to `dma_mapping_error'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/arc/Kconfig | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 8e262e2b39b63fc5..dea29ee24da4a28c 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -25,8 +25,7 @@ config ARC_EMAC_CORE
 config ARC_EMAC
 	tristate "ARC EMAC support"
 	select ARC_EMAC_CORE
-	depends on OF_IRQ
-	depends on OF_NET
+	depends on OF_IRQ && OF_NET && HAS_DMA
 	---help---
 	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
 	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
@@ -35,7 +34,7 @@ config ARC_EMAC
 config EMAC_ROCKCHIP
 	tristate "Rockchip EMAC support"
 	select ARC_EMAC_CORE
-	depends on OF_IRQ && OF_NET && REGULATOR
+	depends on OF_IRQ && OF_NET && REGULATOR && HAS_DMA
 	---help---
 	  Support for Rockchip RK3066/RK3188 EMAC ethernet controllers.
 	  This selects Rockchip SoC glue layer support for the
-- 
1.9.1
