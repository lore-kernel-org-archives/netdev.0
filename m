From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: via: VIA_RHINE and VIA_VELOCITY should depend on HAS_DMA
Date: Fri, 26 Jun 2015 14:08:22 +0200
Message-ID: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_set_mask" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_alloc_coherent" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-rhine.ko] undefined!
    ERROR: "dma_map_page" [drivers/net/ethernet/via/via-velocity.ko] undefined!
    ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/via/via-velocity.ko] undefined!
    ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-velocity.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-velocity.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/via/via-velocity.ko] undefined!
    ERROR: "dma_alloc_coherent" [drivers/net/ethernet/via/via-velocity.ko] undefined!

Before, the symbols depended implicitly on HAS_DMA through PCI or
USE_OF.  Add explicit dependencies on HAS_DMA to fix this.

Fixes: commit b7d3282a245f4428 ("net: via/Kconfig: replace USE_OF with OF_???")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/via/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 8b0b1d6aca72c4a3..2f1264b882b9555f 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -18,6 +18,7 @@ if NET_VENDOR_VIA
 config VIA_RHINE
 	tristate "VIA Rhine support"
 	depends on (PCI || OF_IRQ)
+	depends on HAS_DMA
 	select CRC32
 	select MII
 	---help---
@@ -42,6 +43,7 @@ config VIA_RHINE_MMIO
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
 	depends on (PCI || (OF_ADDRESS && OF_IRQ))
+	depends on HAS_DMA
 	select CRC32
 	select CRC_CCITT
 	select MII
-- 
1.9.1
