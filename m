From: Xander Huff <xander.huff-acOepvfBmUk@public.gmane.org>
Subject: [PATCH] wlcore: Allow scans when in AP mode
Date: Fri, 7 Oct 2016 10:45:57 -0500
Message-ID: <1475855157-21271-1-git-send-email-xander.huff@ni.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        James Minor <james.minor-acOepvfBmUk@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        xander.huff-acOepvfBmUk@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: James Minor <james.minor-acOepvfBmUk@public.gmane.org>

When in AP mode, scans can be done without changing firmware to
the multi-role firmware. Allow the interface to scan if forced
in the scan request.

Signed-off-by: James Minor <james.minor-acOepvfBmUk@public.gmane.org>
Signed-off-by: Xander Huff <xander.huff-acOepvfBmUk@public.gmane.org>
Reviewed-by: Ben Shelton <ben.shelton-acOepvfBmUk@public.gmane.org>
Reviewed-by: Jaeden Amero <jaeden.amero-acOepvfBmUk@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 471521a..01ca370 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -6120,6 +6120,8 @@ static int wl1271_init_ieee80211(struct wl1271 *wl)
 				WIPHY_FLAG_SUPPORTS_SCHED_SCAN |
 				WIPHY_FLAG_HAS_CHANNEL_SWITCH;
 
+	wl->hw->wiphy->features |= NL80211_FEATURE_AP_SCAN;
+
 	/* make sure all our channels fit in the scanned_ch bitmask */
 	BUILD_BUG_ON(ARRAY_SIZE(wl1271_channels) +
 		     ARRAY_SIZE(wl1271_channels_5ghz) >
-- 
1.9.1
