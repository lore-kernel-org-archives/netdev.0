From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] can: CAN_GRCAN should depend on HAS_DMA
Date: Thu, 23 Apr 2015 20:04:51 +0200
Message-ID: <1429812291-9400-1-git-send-email-geert@linux-m68k.org>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    drivers/built-in.o: In function `grcan_free_dma_buffers':
    grcan.c:(.text+0x2d7716): undefined reference to `dma_free_coherent'
    drivers/built-in.o: In function `grcan_allocate_dma_buffers':
    grcan.c:(.text+0x2d779c): undefined reference to `dma_alloc_coherent'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/can/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 58808f6514520c86..e8c96b8e86f48e66 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -112,7 +112,7 @@ config PCH_CAN
 
 config CAN_GRCAN
 	tristate "Aeroflex Gaisler GRCAN and GRHCAN CAN devices"
-	depends on OF
+	depends on OF && HAS_DMA
 	---help---
 	  Say Y here if you want to use Aeroflex Gaisler GRCAN or GRHCAN.
 	  Note that the driver supports little endian, even though little
-- 
1.9.1

