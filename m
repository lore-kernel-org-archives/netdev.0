From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: remove static table from zd_mac.h
Date: Tue,  1 May 2007 04:02:18 +0100 (BST)
Message-ID: <20070501030218.596E97B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

The header zd_mac.h did contain static declaration of tables,
which are only used in zd_mac.c. These tables have been moved into
the C file itself.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c |   74 +++++++++++++++++++++++
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.h |   74 -----------------------
 2 files changed, 74 insertions(+), 74 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index c3f8d30..6cc0b4d 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -28,6 +28,80 @@
 #include "zd_rf.h"
 #include "zd_util.h"
 
+/* TODO: remove this once we have a general modes/channels/rates filling func */
+static const struct ieee80211_rate zd_rates[] = {
+	{ .rate = 10,
+	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_1M,
+	  .flags = IEEE80211_RATE_CCK },
+	{ .rate = 20,
+	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_2M,
+	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_2M | ZD_CS_CCK_PREA_SHORT,
+	  .flags = IEEE80211_RATE_CCK_2 },
+	{ .rate = 55,
+	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_5_5M,
+	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_5_5M | ZD_CS_CCK_PREA_SHORT,
+	  .flags = IEEE80211_RATE_CCK_2 },
+	{ .rate = 110,
+	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_11M,
+	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_11M | ZD_CS_CCK_PREA_SHORT,
+	  .flags = IEEE80211_RATE_CCK_2 },
+	{ .rate = 60,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_6M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 90,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_9M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 120,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_12M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 180,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_18M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 240,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_24M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 360,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_36M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 480,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_48M,
+	  .flags = IEEE80211_RATE_OFDM },
+	{ .rate = 540,
+	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_54M,
+	  .flags = IEEE80211_RATE_OFDM },
+};
+
+static const struct ieee80211_channel zd_channels[] = {
+	{ .chan = 1,
+	  .freq = 2412},
+	{ .chan = 2,
+	  .freq = 2417},
+	{ .chan = 3,
+	  .freq = 2422},
+	{ .chan = 4,
+	  .freq = 2427},
+	{ .chan = 5,
+	  .freq = 2432},
+	{ .chan = 6,
+	  .freq = 2437},
+	{ .chan = 7,
+	  .freq = 2442},
+	{ .chan = 8,
+	  .freq = 2447},
+	{ .chan = 9,
+	  .freq = 2452},
+	{ .chan = 10,
+	  .freq = 2457},
+	{ .chan = 11,
+	  .freq = 2462},
+	{ .chan = 12,
+	  .freq = 2467},
+	{ .chan = 13,
+	  .freq = 2472},
+	{ .chan = 14,
+	  .freq = 2484}
+};
+
 static void housekeeping_init(struct zd_mac *mac);
 static void housekeeping_enable(struct zd_mac *mac);
 static void housekeeping_disable(struct zd_mac *mac);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
index 615c5fb..5faa562 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.h
@@ -196,78 +196,4 @@ void zd_dump_rx_status(const struct rx_status *status);
 #define zd_dump_rx_status(status)
 #endif /* DEBUG */
 
-/* TODO: remove this once we have a general modes/channels/rates filling func */
-static const struct ieee80211_rate zd_rates[] = {
-	{ .rate = 10,
-	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_1M,
-	  .flags = IEEE80211_RATE_CCK },
-	{ .rate = 20,
-	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_2M,
-	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_2M | ZD_CS_CCK_PREA_SHORT,
-	  .flags = IEEE80211_RATE_CCK_2 },
-	{ .rate = 55,
-	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_5_5M,
-	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_5_5M | ZD_CS_CCK_PREA_SHORT,
-	  .flags = IEEE80211_RATE_CCK_2 },
-	{ .rate = 110,
-	  .val = ZD_CS_CCK | ZD_CS_CCK_RATE_11M,
-	  .val2 = ZD_CS_CCK | ZD_CS_CCK_RATE_11M | ZD_CS_CCK_PREA_SHORT,
-	  .flags = IEEE80211_RATE_CCK_2 },
-	{ .rate = 60,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_6M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 90,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_9M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 120,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_12M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 180,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_18M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 240,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_24M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 360,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_36M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 480,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_48M,
-	  .flags = IEEE80211_RATE_OFDM },
-	{ .rate = 540,
-	  .val = ZD_CS_OFDM | ZD_OFDM_RATE_54M,
-	  .flags = IEEE80211_RATE_OFDM },
-};
-
-static const struct ieee80211_channel zd_channels[] = {
-	{ .chan = 1,
-	  .freq = 2412},
-	{ .chan = 2,
-	  .freq = 2417},
-	{ .chan = 3,
-	  .freq = 2422},
-	{ .chan = 4,
-	  .freq = 2427},
-	{ .chan = 5,
-	  .freq = 2432},
-	{ .chan = 6,
-	  .freq = 2437},
-	{ .chan = 7,
-	  .freq = 2442},
-	{ .chan = 8,
-	  .freq = 2447},
-	{ .chan = 9,
-	  .freq = 2452},
-	{ .chan = 10,
-	  .freq = 2457},
-	{ .chan = 11,
-	  .freq = 2462},
-	{ .chan = 12,
-	  .freq = 2467},
-	{ .chan = 13,
-	  .freq = 2472},
-	{ .chan = 14,
-	  .freq = 2484}
-};
-
 #endif /* _ZD_MAC_H */
-- 
1.5.1.2
