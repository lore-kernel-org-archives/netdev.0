From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/3] sh_eth: SH_ETH should depend on HAS_DMA
Date: Wed, 10 Jul 2013 23:03:34 +0200
Message-ID: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `sh_eth_free_dma_buffer':
drivers/net/ethernet/renesas/sh_eth.c:1103: undefined reference to `dma_free_coherent'
drivers/net/ethernet/renesas/sh_eth.c:1110: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `sh_eth_ring_init':
drivers/net/ethernet/renesas/sh_eth.c:1065: undefined reference to `dma_alloc_coherent'
drivers/net/ethernet/renesas/sh_eth.c:1086: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `sh_eth_ring_format':
drivers/net/ethernet/renesas/sh_eth.c:988: undefined reference to `dma_map_single'
drivers/built-in.o: In function `sh_eth_txfree':
drivers/net/ethernet/renesas/sh_eth.c:1220: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `sh_eth_rx':
drivers/net/ethernet/renesas/sh_eth.c:1323: undefined reference to `dma_map_single'
drivers/built-in.o: In function `sh_eth_start_xmit':
drivers/net/ethernet/renesas/sh_eth.c:1954: undefined reference to `dma_map_single'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/renesas/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 544514e..19a8a04 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -4,6 +4,7 @@
 
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
+	depends on HAS_DMA
 	select CRC32
 	select MII
 	select MDIO_BITBANG
-- 
1.7.9.5
