From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 04/12] net/ethernet: STMMAC_ETH should depend on HAS_DMA
Date: Thu,  9 May 2013 23:04:46 +0200
Message-ID: <1368133494-22198-4-git-send-email-geert@linux-m68k.org>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `dma_free_tx_skbufs':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1141: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `dma_free_rx_skbufs':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1120: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `free_dma_desc_resources':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1159: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `stmmac_init_rx_buffers':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:980: undefined reference to `dma_map_single'
drivers/built-in.o: In function `init_dma_desc_rings':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1015: undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `stmmac_tx_clean':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1250: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `stmmac_rx':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2044: undefined reference to `dma_unmap_single'
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:2082: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `stmmac_rx_refill':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1967: undefined reference to `dma_map_single'
drivers/built-in.o: In function `stmmac_xmit':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1845: undefined reference to `dma_map_single'
drivers/built-in.o: In function `skb_frag_dma_map':
include/linux/skbuff.h:2184: undefined reference to `dma_map_page'
drivers/built-in.o: In function `stmmac_jumbo_frm':
drivers/net/ethernet/stmicro/stmmac/ring_mode.c:40: undefined reference to `dma_map_single'
drivers/built-in.o: In function `stmmac_jumbo_frm':
drivers/net/ethernet/stmicro/stmmac/chain_mode.c:48: undefined reference to `dma_map_single'
drivers/net/ethernet/stmicro/stmmac/chain_mode.c:55: undefined reference to `dma_map_single'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index f695a50..43c1f32 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -1,6 +1,6 @@
 config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && HAS_DMA
 	select NET_CORE
 	select MII
 	select PHYLIB
-- 
1.7.0.4
