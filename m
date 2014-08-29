From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] brcmfmac: BRCMFMAC should depend on HAS_DMA
Date: Fri, 29 Aug 2014 18:24:23 +0200
Message-ID: <1409329464-768-1-git-send-email-geert@linux-m68k.org>
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Brett Rudley <brudley@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `brcmf_msgbuf_release_array':
msgbuf.c:(.text+0x34dbbe): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `brcmf_proto_msgbuf_detach':
(.text+0x34dca4): undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `brcmf_msgbuf_get_pktid':
msgbuf.c:(.text+0x34dd2a): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `brcmf_msgbuf_alloc_pktid':
msgbuf.c:(.text+0x34de12): undefined reference to `dma_map_single'
msgbuf.c:(.text+0x34de20): undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `brcmf_msgbuf_remove_flowring':
msgbuf.c:(.text+0x34e3d6): undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `brcmf_msgbuf_flowring_create':
msgbuf.c:(.text+0x34e4f8): undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `brcmf_proto_msgbuf_attach':
(.text+0x34f5fe): undefined reference to `dma_alloc_coherent'
drivers/built-in.o: In function `brcmf_proto_msgbuf_attach':
(.text+0x34f798): undefined reference to `dma_free_coherent'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/wireless/brcm80211/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/brcm80211/Kconfig
index b8e2561ea645..2e0da8925834 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -19,7 +19,7 @@ config BRCMSMAC
 
 config BRCMFMAC
 	tristate "Broadcom IEEE802.11n embedded FullMAC WLAN driver"
-	depends on CFG80211
+	depends on CFG80211A && HAS_DMA
 	select BRCMUTIL
 	---help---
 	  This module adds support for embedded wireless adapters based on
-- 
1.9.1
