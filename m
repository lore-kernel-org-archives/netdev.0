From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH 1/2] ath9k: Use macro to decrease code when priting recv stats.
Date: Thu, 12 Apr 2012 10:03:59 -0700
Message-ID: <1334250240-21038-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

This hides some repetitive code, and will help if the
column widths ever need to change.

Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
---
:100644 100644 04edce9... 78f2962... M	drivers/net/wireless/ath/ath9k/debug.c
 drivers/net/wireless/ath/ath9k/debug.c |   72 +++++++++++---------------------
 1 files changed, 24 insertions(+), 48 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 04edce9..78f2962 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -881,6 +881,13 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 	len += snprintf(buf + len, size - len, "%22s : %10u\n", s, \
 			sc->debug.stats.rxstats.phy_err_stats[p]);
 
+#define RXS_ERR(s, e)					    \
+	do {						    \
+		len += snprintf(buf + len, size - len,	    \
+				"%22s : %10u\n", s,	    \
+				sc->debug.stats.rxstats.e); \
+	} while (0)
+
 	struct ath_softc *sc = file->private_data;
 	char *buf;
 	unsigned int len = 0, size = 1600;
@@ -890,42 +897,18 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 	if (buf == NULL)
 		return -ENOMEM;
 
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "CRC ERR",
-			sc->debug.stats.rxstats.crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "DECRYPT CRC ERR",
-			sc->debug.stats.rxstats.decrypt_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "PHY ERR",
-			sc->debug.stats.rxstats.phy_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "MIC ERR",
-			sc->debug.stats.rxstats.mic_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "PRE-DELIM CRC ERR",
-			sc->debug.stats.rxstats.pre_delim_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "POST-DELIM CRC ERR",
-			sc->debug.stats.rxstats.post_delim_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "DECRYPT BUSY ERR",
-			sc->debug.stats.rxstats.decrypt_busy_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-LENGTH-ERR",
-			sc->debug.stats.rxstats.rx_len_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-OOM-ERR",
-			sc->debug.stats.rxstats.rx_oom_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-RATE-ERR",
-			sc->debug.stats.rxstats.rx_rate_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-DROP-RXFLUSH",
-			sc->debug.stats.rxstats.rx_drop_rxflush);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-TOO-MANY-FRAGS",
-			sc->debug.stats.rxstats.rx_too_many_frags_err);
+	RXS_ERR("CRC ERR", crc_err);
+	RXS_ERR("DECRYPT CRC ERR", decrypt_crc_err);
+	RXS_ERR("PHY ERR", phy_err);
+	RXS_ERR("MIC ERR", mic_err);
+	RXS_ERR("PRE-DELIM CRC ERR", pre_delim_crc_err);
+	RXS_ERR("POST-DELIM CRC ERR", post_delim_crc_err);
+	RXS_ERR("DECRYPT BUSY ERR", decrypt_busy_err);
+	RXS_ERR("RX-LENGTH-ERR", rx_len_err);
+	RXS_ERR("RX-OOM-ERR", rx_oom_err);
+	RXS_ERR("RX-RATE-ERR", rx_rate_err);
+	RXS_ERR("RX-DROP-RXFLUSH", rx_drop_rxflush);
+	RXS_ERR("RX-TOO-MANY-FRAGS", rx_too_many_frags_err);
 
 	PHY_ERR("UNDERRUN ERR", ATH9K_PHYERR_UNDERRUN);
 	PHY_ERR("TIMING ERR", ATH9K_PHYERR_TIMING);
@@ -954,18 +937,10 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 	PHY_ERR("HT-LENGTH ERR", ATH9K_PHYERR_HT_LENGTH_ILLEGAL);
 	PHY_ERR("HT-RATE ERR", ATH9K_PHYERR_HT_RATE_ILLEGAL);
 
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Pkts-All",
-			sc->debug.stats.rxstats.rx_pkts_all);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Bytes-All",
-			sc->debug.stats.rxstats.rx_bytes_all);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Beacons",
-			sc->debug.stats.rxstats.rx_beacons);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Frags",
-			sc->debug.stats.rxstats.rx_frags);
+	RXS_ERR("RX-Pkts-All", rx_pkts_all);
+	RXS_ERR("RX-Bytes-All", rx_bytes_all);
+	RXS_ERR("RX-Beacons", rx_beacons);
+	RXS_ERR("RX-Frags", rx_frags);
 
 	if (len > size)
 		len = size;
@@ -975,6 +950,7 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 
 	return retval;
 
+#undef RXS_ERR
 #undef PHY_ERR
 }
 
-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
