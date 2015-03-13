From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH] wl18xx: show rx_frames_per_rates as an array as it really is
Date: Fri, 13 Mar 2015 15:17:14 +0800
Message-ID: <1426231034-20163-1-git-send-email-nicolas.iooss_linux@m4x.org>
References: <55018919.3050902@m4x.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: kvalo@codeaurora.org, eliad@wizery.com,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55018919.3050902@m4x.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In struct wl18xx_acx_rx_rate_stat, rx_frames_per_rates field is an
array, not a number.  This means WL18XX_DEBUGFS_FWSTATS_FILE can't be
used to display this field in debugfs (it would display a pointer, not
the actual data).  Use WL18XX_DEBUGFS_FWSTATS_FILE_ARRAY instead.

This bug has been found by adding a __printf attribute to
wl1271_format_buffer.  gcc complained about "format '%u' expects
argument of type 'unsigned int', but argument 5 has type 'u32 *'".

Fixes: c5d94169e818 ("wl18xx: use new fw stats structures")
Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
---

This patch is only compile-tested as I haven't got the hardware to
test it live.

 drivers/net/wireless/ti/wl18xx/debugfs.c | 2 +-
 drivers/net/wireless/ti/wlcore/debugfs.h | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wl18xx/debugfs.c b/drivers/net/wireless/ti/wl18xx/debugfs.c
index c93fae95baac..5fbd2230f372 100644
--- a/drivers/net/wireless/ti/wl18xx/debugfs.c
+++ b/drivers/net/wireless/ti/wl18xx/debugfs.c
@@ -139,7 +139,7 @@ WL18XX_DEBUGFS_FWSTATS_FILE(rx_filter, protection_filter, "%u");
 WL18XX_DEBUGFS_FWSTATS_FILE(rx_filter, accum_arp_pend_requests, "%u");
 WL18XX_DEBUGFS_FWSTATS_FILE(rx_filter, max_arp_queue_dep, "%u");
 
-WL18XX_DEBUGFS_FWSTATS_FILE(rx_rate, rx_frames_per_rates, "%u");
+WL18XX_DEBUGFS_FWSTATS_FILE_ARRAY(rx_rate, rx_frames_per_rates, 50);
 
 WL18XX_DEBUGFS_FWSTATS_FILE_ARRAY(aggr_size, tx_agg_vs_rate,
 				  AGGR_STATS_TX_AGG*AGGR_STATS_TX_RATE);
diff --git a/drivers/net/wireless/ti/wlcore/debugfs.h b/drivers/net/wireless/ti/wlcore/debugfs.h
index 0f2cfb0d2a9e..bf14676e6515 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.h
+++ b/drivers/net/wireless/ti/wlcore/debugfs.h
@@ -26,8 +26,8 @@
 
 #include "wlcore.h"
 
-int wl1271_format_buffer(char __user *userbuf, size_t count,
-			 loff_t *ppos, char *fmt, ...);
+__printf(4, 5) int wl1271_format_buffer(char __user *userbuf, size_t count,
+					loff_t *ppos, char *fmt, ...);
 
 int wl1271_debugfs_init(struct wl1271 *wl);
 void wl1271_debugfs_exit(struct wl1271 *wl);
-- 
2.3.2
