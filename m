From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Fix SSI reporting
Date: Sun,  1 Jul 2007 17:40:37 +0100 (BST)
Message-ID: <20070701164037.6ACC87B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Cc: flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

zd1211rw-mac80211 currently reports different values for signal level
than zd1211rw-softmac. This is because the softmac driver passes the raw
strength value, whereas zd1211rw-mac80211 is performing some other
calculation.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c |    8 --------
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.h |    1 -
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c  |    2 +-
 3 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index 75728bb..662e66e 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -1464,14 +1464,6 @@ u8 zd_rx_qual_percent(const void *rx_frame, unsigned int size,
 		cck_qual_percent(status->signal_quality_cck);
 }
 
-u8 zd_rx_strength_percent(u8 rssi)
-{
-	int r = (rssi*100) / 41;
-	if (r > 100)
-		r = 100;
-	return (u8) r;
-}
-
 u16 zd_rx_rate(const void *rx_frame, const struct rx_status *status)
 {
 	static const u16 ofdm_rates[] = {
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
index 96ada90..5229290 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
@@ -877,7 +877,6 @@ struct rx_status;
 
 u8 zd_rx_qual_percent(const void *rx_frame, unsigned int size,
 	               const struct rx_status *status);
-u8 zd_rx_strength_percent(u8 rssi);
 
 u16 zd_rx_rate(const void *rx_frame, const struct rx_status *status);
 
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 49633d4..373916a 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -652,7 +652,7 @@ static int fill_rx_stats(struct ieee80211_rx_status *stats,
 	stats->channel = _zd_chip_get_channel(&mac->chip);
 	stats->freq = zd_channels[stats->channel - 1].freq;
 	stats->phymode = MODE_IEEE80211G;
-	stats->ssi = zd_rx_strength_percent(status->signal_strength);
+	stats->ssi = status->signal_strength;
 	stats->signal = zd_rx_qual_percent(buffer,
 		                          length - sizeof(struct rx_status),
 		                          status);
-- 
1.5.2.2
