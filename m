From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] ti: wl1251: Convert wl1251_info to wl1251_debug
Date: Mon,  7 Mar 2016 16:19:37 -0800
Message-ID: <b8b1d2c63f9499fad26eda0db1b976c29d873f70.1457395071.git.joe@perches.com>
References: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0093.hostedemail.com ([216.40.44.93]:33143 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933690AbcCHAUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 19:20:32 -0500
In-Reply-To: <cover.1457395071.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These logging messages are always emitted at KERN_DEBUG.

Add a DEBUG_ALWAYS enum to the debug type enum and convert the
macro and uses from wl1251_info( to wl1251_debug(DEBUG_ALWAYS,

Miscellanea:

o Remove the now unused wl1251_info macro

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wl1251/init.c   | 10 +++++-----
 drivers/net/wireless/ti/wl1251/main.c   |  4 ++--
 drivers/net/wireless/ti/wl1251/sdio.c   |  4 ++--
 drivers/net/wireless/ti/wl1251/wl1251.h |  6 ++----
 4 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/ti/wl1251/init.c
index 796ccf4..29a990d 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -411,11 +411,11 @@ int wl1251_hw_init(struct wl1251 *wl)
 		goto out_free_data_path;
 
 	wl_mem_map = wl->target_mem_map;
-	wl1251_info("%d tx blocks at 0x%x, %d rx blocks at 0x%x",
-		    wl_mem_map->num_tx_mem_blocks,
-		    wl->data_path->tx_control_addr,
-		    wl_mem_map->num_rx_mem_blocks,
-		    wl->data_path->rx_control_addr);
+	wl1251_debug(DEBUG_ALWAYS, "%d tx blocks at 0x%x, %d rx blocks at 0x%x",
+		     wl_mem_map->num_tx_mem_blocks,
+		     wl->data_path->tx_control_addr,
+		     wl_mem_map->num_rx_mem_blocks,
+		     wl->data_path->rx_control_addr);
 
 	return 0;
 
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 593bed9..32b8c98 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -423,7 +423,7 @@ static int wl1251_op_start(struct ieee80211_hw *hw)
 
 	wl->state = WL1251_STATE_ON;
 
-	wl1251_info("firmware booted (%s)", wl->fw_ver);
+	wl1251_debug(DEBUG_ALWAYS, "firmware booted (%s)", wl->fw_ver);
 
 	/* update hw/fw version info in wiphy struct */
 	wiphy->hw_version = wl->chip_id;
@@ -442,7 +442,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 {
 	struct wl1251 *wl = hw->priv;
 
-	wl1251_info("down");
+	wl1251_debug(DEBUG_ALWAYS, "down");
 
 	wl1251_debug(DEBUG_MAC80211, "mac80211 stop");
 
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index cc52a97..d2fb7d1 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -290,12 +290,12 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		wl1251_sdio_ops.enable_irq = wl1251_enable_line_irq;
 		wl1251_sdio_ops.disable_irq = wl1251_disable_line_irq;
 
-		wl1251_info("using dedicated interrupt line");
+		wl1251_debug(DEBUG_ALWAYS, "using dedicated interrupt line");
 	} else {
 		wl1251_sdio_ops.enable_irq = wl1251_sdio_enable_irq;
 		wl1251_sdio_ops.disable_irq = wl1251_sdio_disable_irq;
 
-		wl1251_info("using SDIO interrupt");
+		wl1251_debug(DEBUG_ALWAYS, "using SDIO interrupt");
 	}
 
 	ret = wl1251_init_ieee80211(wl);
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 62a40cc..705573f 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -47,6 +47,7 @@ enum {
 	DEBUG_MAC80211	= BIT(11),
 	DEBUG_CMD	= BIT(12),
 	DEBUG_ACX	= BIT(13),
+	DEBUG_ALWAYS	= BIT(31),
 	DEBUG_ALL	= ~0,
 };
 
@@ -54,12 +55,9 @@ enum {
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1251_info(fmt, arg...) \
-	printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg)
-
 #define wl1251_debug(level, fmt, arg...) \
 	do { \
-		if (level & DEBUG_LEVEL) \
+		if (level == DEBUG_ALWAYS || (level & DEBUG_LEVEL))	\
 			printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg); \
 	} while (0)
 
-- 
2.6.3.368.gf34be46
