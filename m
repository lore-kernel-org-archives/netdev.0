From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/5] ti: wl1251: Convert wl1251_notice to wiphy_info/pr_info
Date: Mon,  7 Mar 2016 16:19:36 -0800
Message-ID: <861469e68f880e98a4bfd4e3bc46a0947b702bf8.1457395071.git.joe@perches.com>
References: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1457395071.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common logging mechanisms.

Convert to wiphy_info as these wl1251_notice uses were actually
emitted at KERN_INFO.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wl1251/main.c   | 4 ++--
 drivers/net/wireless/ti/wl1251/sdio.c   | 2 +-
 drivers/net/wireless/ti/wl1251/wl1251.h | 3 ---
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index a0576e7..593bed9 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1469,7 +1469,7 @@ static int wl1251_register_hw(struct wl1251 *wl)
 
 	wl->mac80211_registered = true;
 
-	wl1251_notice("loaded");
+	wiphy_info(wl->hw->wiphy, "loaded\n");
 
 	return 0;
 }
@@ -1503,7 +1503,7 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
 		goto out;
 
 	wl1251_debugfs_init(wl);
-	wl1251_notice("initialized");
+	wiphy_info(wl->hw->wiphy, "initialized\n");
 
 	ret = 0;
 
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index f48e985..cc52a97 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -382,7 +382,7 @@ static int __init wl1251_sdio_init(void)
 static void __exit wl1251_sdio_exit(void)
 {
 	sdio_unregister_driver(&wl1251_sdio_driver);
-	wl1251_notice("unloaded");
+	pr_info("unloaded\n");
 }
 
 module_init(wl1251_sdio_init);
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 5d520d2..62a40cc 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -54,9 +54,6 @@ enum {
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1251_notice(fmt, arg...) \
-	printk(KERN_INFO DRIVER_PREFIX fmt "\n", ##arg)
-
 #define wl1251_info(fmt, arg...) \
 	printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg)
 
-- 
2.6.3.368.gf34be46
