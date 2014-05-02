From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] Altera TSE: ALTERA_TSE should depend on HAS_DMA
Date: Fri,  2 May 2014 06:29:21 +0200
Message-ID: <1399004962-19530-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Vince Bridgers <vbridgers2013@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:42332 "EHLO
	michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbaEBE3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 00:29:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NO_DMA=y:

drivers/built-in.o: In function `altera_tse_probe':
altera_tse_main.c:(.text+0x25ec2e): undefined reference to `dma_set_mask'
altera_tse_main.c:(.text+0x25ec78): undefined reference to `dma_supported'
altera_tse_main.c:(.text+0x25ecb6): undefined reference to `dma_supported'
drivers/built-in.o: In function `sgdma_async_read':
altera_sgdma.c:(.text+0x25f620): undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `sgdma_uninitialize':
(.text+0x25f678): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `sgdma_uninitialize':
(.text+0x25f696): undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `sgdma_initialize':
(.text+0x25f6f0): undefined reference to `dma_map_single'
drivers/built-in.o: In function `sgdma_initialize':
(.text+0x25f702): undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `sgdma_tx_buffer':
(.text+0x25f92a): undefined reference to `dma_sync_single_for_cpu'
drivers/built-in.o: In function `sgdma_rx_status':
(.text+0x25fa24): undefined reference to `dma_sync_single_for_cpu'
make[3]: *** [vmlinux] Error 1

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/altera/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/altera/Kconfig b/drivers/net/ethernet/altera/Kconfig
index 80c1ab74a4b8..fdddba51473e 100644
--- a/drivers/net/ethernet/altera/Kconfig
+++ b/drivers/net/ethernet/altera/Kconfig
@@ -1,5 +1,6 @@
 config ALTERA_TSE
 	tristate "Altera Triple-Speed Ethernet MAC support"
+	depends on HAS_DMA
 	select PHYLIB
 	---help---
 	  This driver supports the Altera Triple-Speed (TSE) Ethernet MAC.
-- 
1.7.9.5
