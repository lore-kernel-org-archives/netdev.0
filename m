From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 05/12] net/wireless: ATH9K should depend on HAS_DMA
Date: Thu,  9 May 2013 23:04:47 +0200
Message-ID: <1368133494-22198-5-git-send-email-geert@linux-m68k.org>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `ath9k_beacon_generate':
drivers/net/wireless/ath/ath9k/beacon.c:146: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath9k/beacon.c:174: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath9k/beacon.c:176: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath9k_beacon_remove_slot':
drivers/net/wireless/ath/ath9k/beacon.c:252: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath_descdma_setup':
drivers/net/wireless/ath/ath9k/init.c:382: undefined reference to `dmam_alloc_coherent'
drivers/built-in.o: In function `ath_edma_get_buffers':
drivers/net/wireless/ath/ath9k/recv.c:616: undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `ath_get_next_rx_buf':
drivers/net/wireless/ath/ath9k/recv.c:740: undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `ath_rx_edma_cleanup':
drivers/net/wireless/ath/ath9k/recv.c:176: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath_rx_cleanup':
drivers/net/wireless/ath/ath9k/recv.c:340: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath_rx_edma_buf_link':
drivers/net/wireless/ath/ath9k/recv.c:122: undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `ath_rx_tasklet':
drivers/net/wireless/ath/ath9k/recv.c:1275: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath9k/recv.c:1277: undefined reference to `dma_mapping_error'
drivers/net/wireless/ath/ath9k/recv.c:1283: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath_rx_edma_init':
drivers/net/wireless/ath/ath9k/recv.c:226: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath9k/recv.c:229: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath_rx_init':
drivers/net/wireless/ath/ath9k/recv.c:303: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath9k/recv.c:306: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath_tx_complete_buf':
drivers/net/wireless/ath/ath9k/xmit.c:2088: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath_txstatus_setup':
drivers/net/wireless/ath/ath9k/xmit.c:2344: undefined reference to `dmam_alloc_coherent'
drivers/built-in.o: In function `ath_tx_set_retry':
drivers/net/wireless/ath/ath9k/xmit.c:307: undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `ath_tx_setup_buffer':
drivers/net/wireless/ath/ath9k/xmit.c:1887: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath9k/xmit.c:1889: undefined reference to `dma_mapping_error'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Luis R. Rodriguez <mcgrof@qca.qualcomm.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/ath/ath9k/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/ath/ath9k/Kconfig
index 17507dc..f3dc124 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -17,7 +17,7 @@ config ATH9K_BTCOEX_SUPPORT
 
 config ATH9K
 	tristate "Atheros 802.11n wireless cards support"
-	depends on MAC80211
+	depends on MAC80211 && HAS_DMA
 	select ATH9K_HW
 	select MAC80211_LEDS
 	select LEDS_CLASS
-- 
1.7.0.4
