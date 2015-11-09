From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: hisilicon: NET_VENDOR_HISILICON should depend on HAS_DMA
Date: Mon,  9 Nov 2015 10:34:30 +0100
Message-ID: <1447061670-19681-1-git-send-email-geert@linux-m68k.org>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    ERROR: "dma_set_mask" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_unmap_page" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_map_page" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_supported" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
    ERROR: "dma_set_mask" [drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko] undefined!
    ERROR: "dma_supported" [drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
    ERROR: "dma_unmap_page" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
    ERROR: "dma_map_page" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
    ERROR: "dma_alloc_coherent" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
    ERROR: "dma_free_coherent" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
    ERROR: "dma_alloc_coherent" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
    ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
    ERROR: "dma_free_coherent" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!

As this affects all of HNS_ENET, HNS_DSAF, HNS, HIX5HD2_GMAC, and
HIP04_ETH, add a dependency on HAS_DMA to the main NET_VENDOR_HISILICON
symbol to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/hisilicon/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index f250dec488fd2a2b..74beb1867230c9cf 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -5,7 +5,8 @@
 config NET_VENDOR_HISILICON
 	bool "Hisilicon devices"
 	default y
-	depends on OF && (ARM || ARM64 || COMPILE_TEST)
+	depends on OF && HAS_DMA
+	depends on ARM || ARM64 || COMPILE_TEST
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
-- 
1.9.1
