From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] wlcore: fix 64K page support
Date: Thu, 11 May 2017 13:52:09 +0200
Message-ID: <20170511115307.3060650-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org,
        "Reizer, Eyal" <eyalr@ti.com>, Tony Lindgren <tony@atomide.com>,
        Wei Yongjun <weiyj.lk@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the stable linux-3.16 branch, I ran into a warning in the
wlcore driver:

drivers/net/wireless/ti/wlcore/spi.c: In function 'wl12xx_spi_raw_write':
drivers/net/wireless/ti/wlcore/spi.c:315:1: error: the frame size of 12848 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

Newer kernels no longer show the warning, but the bug is still there,
as the allocation is based on the CPU page size rather than the
actual capabilities of the hardware.

This replaces the PAGE_SIZE macro with the SZ_4K macro, i.e. 4096 bytes
per buffer.

Cc: stable@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ti/wlcore/spi.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index f949ad2bd898..fa3547e06424 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -70,10 +70,10 @@
 #define WSPI_MAX_CHUNK_SIZE    4092
 
 /*
- * wl18xx driver aggregation buffer size is (13 * PAGE_SIZE) compared to
- * (4 * PAGE_SIZE) for wl12xx, so use the larger buffer needed for wl18xx
+ * wl18xx driver aggregation buffer size is (13 * 4K) compared to
+ * (4 * 4K) for wl12xx, so use the larger buffer needed for wl18xx
  */
-#define SPI_AGGR_BUFFER_SIZE (13 * PAGE_SIZE)
+#define SPI_AGGR_BUFFER_SIZE (13 * SZ_4K)
 
 /* Maximum number of SPI write chunks */
 #define WSPI_MAX_NUM_OF_CHUNKS \
-- 
2.9.0
