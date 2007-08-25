From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/4] Net: ath5k, remove some ieee80211 re-defines
Date: Sat, 25 Aug 2007 03:59:28 -0400
Message-ID: <1856013654315953929@pripojeni.net>
References: <149438602455517207@pripojeni.net>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <149438602455517207-+5AFNAhbZwkm4RdzfppkhA@public.gmane.org>
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ath5k, remove some ieee80211 re-defines

use mac80211 defines directly instead. this means MODULATION_* to
IEEE80211_RATE_* switch.

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

---
commit c858c1b27bfb4c58c9ebfa24de0d6442e364db97
tree 1add137b1e95ca1b4905441b5e30c779f8801c36
parent 0a11d301ccb5caf1c9738a7307002a5295aecd58
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:25:32 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:25:32 +0200

 drivers/net/wireless/ath5k.h      |   92 ++++++++++++++++++-------------------
 drivers/net/wireless/ath5k_base.c |    2 -
 drivers/net/wireless/ath5k_hw.c   |    9 ++--
 3 files changed, 50 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/ath5k.h b/drivers/net/wireless/ath5k.h
index ad5e196..78d7cb2 100644
--- a/drivers/net/wireless/ath5k.h
+++ b/drivers/net/wireless/ath5k.h
@@ -82,7 +82,7 @@
 #define AR5K_TUNE_ADDITIONAL_SWBA_BACKOFF	0
 #define AR5K_TUNE_RADAR_ALERT			false
 #define AR5K_TUNE_MIN_TX_FIFO_THRES		1
-#define AR5K_TUNE_MAX_TX_FIFO_THRES		((MAX_PDU_LENGTH / 64) + 1)
+#define AR5K_TUNE_MAX_TX_FIFO_THRES		((IEEE80211_MAX_LEN / 64) + 1)
 #define AR5K_TUNE_RSSI_THRES			1792
 #define AR5K_TUNE_REGISTER_TIMEOUT		20000
 #define AR5K_TUNE_REGISTER_DWELL_TIME		20000
@@ -187,18 +187,14 @@ struct ath5k_srev_name {
 
 #define IEEE80211_MAX_LEN       2500
 
-#define MAX_PDU_LENGTH		IEEE80211_MAX_LEN
-#define MODULATION_CCK		IEEE80211_RATE_CCK
-#define MODULATION_OFDM		IEEE80211_RATE_OFDM
-#define MODULATION_TURBO	IEEE80211_RATE_TURBO
+/* TODO Merge this to mac80211 */
 #define MODULATION_XR 		0x00000200 /*XR thingie*/
-#define MODULATION_CCK_SP 	IEEE80211_RATE_CCK_2 /*CCK + Shortpreamble*/
 
 #define AR5K_SET_SHORT_PREAMBLE 0x04 /* adding this flag to rate_code
 					enables short preamble, see
 					ar5212_reg.h */
-#define HAS_SHPREAMBLE(_ix) (rt->rates[_ix].modulation == MODULATION_CCK_SP)
-#define SHPREAMBLE_FLAG(_ix) HAS_SHPREAMBLE(_ix)?AR5K_SET_SHORT_PREAMBLE:0
+#define HAS_SHPREAMBLE(_ix) (rt->rates[_ix].modulation == IEEE80211_RATE_CCK_2)
+#define SHPREAMBLE_FLAG(_ix) (HAS_SHPREAMBLE(_ix) ? AR5K_SET_SHORT_PREAMBLE : 0)
 
 /****************\
   TX DEFINITIONS
@@ -598,56 +594,56 @@ struct ath5k_rate_table {
 	255, 255, 255, 255, 255, 255, 255, 255, 6, 4, 2, 0,	\
 	7, 5, 3, 1, 255, 255, 255, 255, 255, 255, 255, 255,	\
 	255, 255, 255, 255, 255, 255, 255, 255 }, {		\
-	{ 1, MODULATION_OFDM, 6000, 11, 140, 0 },		\
-	{ 1, MODULATION_OFDM, 9000, 15, 18, 0 },		\
-	{ 1, MODULATION_OFDM, 12000, 10, 152, 2 },		\
-	{ 1, MODULATION_OFDM, 18000, 14, 36, 2 },		\
-	{ 1, MODULATION_OFDM, 24000, 9, 176, 4 },		\
-	{ 1, MODULATION_OFDM, 36000, 13, 72, 4 },		\
-	{ 1, MODULATION_OFDM, 48000, 8, 96, 4 },		\
-	{ 1, MODULATION_OFDM, 54000, 12, 108, 4 } }		\
+	{ 1, IEEE80211_RATE_OFDM, 6000, 11, 140, 0 },		\
+	{ 1, IEEE80211_RATE_OFDM, 9000, 15, 18, 0 },		\
+	{ 1, IEEE80211_RATE_OFDM, 12000, 10, 152, 2 },		\
+	{ 1, IEEE80211_RATE_OFDM, 18000, 14, 36, 2 },		\
+	{ 1, IEEE80211_RATE_OFDM, 24000, 9, 176, 4 },		\
+	{ 1, IEEE80211_RATE_OFDM, 36000, 13, 72, 4 },		\
+	{ 1, IEEE80211_RATE_OFDM, 48000, 8, 96, 4 },		\
+	{ 1, IEEE80211_RATE_OFDM, 54000, 12, 108, 4 } }		\
 }
 
 #define AR5K_RATES_11B { 4, {						\
 	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,	\
 	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,	\
 	3, 2, 1, 0, 255, 255, 255, 255 }, {				\
-	{ 1, MODULATION_CCK, 1000, 27, 130, 0 },	\
-	{ 1, MODULATION_CCK_SP, 2000, 26, 132, 1 },	\
-	{ 1, MODULATION_CCK_SP, 5500, 25, 139, 1 },	\
-	{ 1, MODULATION_CCK_SP, 11000, 24, 150, 1 } }	\
+	{ 1, IEEE80211_RATE_CCK, 1000, 27, 130, 0 },	\
+	{ 1, IEEE80211_RATE_CCK_2, 2000, 26, 132, 1 },	\
+	{ 1, IEEE80211_RATE_CCK_2, 5500, 25, 139, 1 },	\
+	{ 1, IEEE80211_RATE_CCK_2, 11000, 24, 150, 1 } }	\
 }
 
 #define AR5K_RATES_11G { 12, {					\
 	255, 255, 255, 255, 255, 255, 255, 255, 10, 8, 6, 4,	\
 	11, 9, 7, 5, 255, 255, 255, 255, 255, 255, 255, 255,	\
 	3, 2, 1, 0, 255, 255, 255, 255 }, {			\
-	{ 1, MODULATION_CCK, 1000, 27, 2, 0 },		\
-	{ 1, MODULATION_CCK_SP, 2000, 26, 4, 1 },		\
-	{ 1, MODULATION_CCK_SP, 5500, 25, 11, 1 },		\
-	{ 1, MODULATION_CCK_SP, 11000, 24, 22, 1 },	\
-	{ 0, MODULATION_OFDM, 6000, 11, 12, 4 },	\
-	{ 0, MODULATION_OFDM, 9000, 15, 18, 4 },	\
-	{ 1, MODULATION_OFDM, 12000, 10, 24, 6 },	\
-	{ 1, MODULATION_OFDM, 18000, 14, 36, 6 },	\
-	{ 1, MODULATION_OFDM, 24000, 9, 48, 8 },	\
-	{ 1, MODULATION_OFDM, 36000, 13, 72, 8 },	\
-	{ 1, MODULATION_OFDM, 48000, 8, 96, 8 },	\
-	{ 1, MODULATION_OFDM, 54000, 12, 108, 8 } }	\
+	{ 1, IEEE80211_RATE_CCK, 1000, 27, 2, 0 },		\
+	{ 1, IEEE80211_RATE_CCK_2, 2000, 26, 4, 1 },		\
+	{ 1, IEEE80211_RATE_CCK_2, 5500, 25, 11, 1 },		\
+	{ 1, IEEE80211_RATE_CCK_2, 11000, 24, 22, 1 },	\
+	{ 0, IEEE80211_RATE_OFDM, 6000, 11, 12, 4 },	\
+	{ 0, IEEE80211_RATE_OFDM, 9000, 15, 18, 4 },	\
+	{ 1, IEEE80211_RATE_OFDM, 12000, 10, 24, 6 },	\
+	{ 1, IEEE80211_RATE_OFDM, 18000, 14, 36, 6 },	\
+	{ 1, IEEE80211_RATE_OFDM, 24000, 9, 48, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 36000, 13, 72, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 48000, 8, 96, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 54000, 12, 108, 8 } }	\
 }
 
 #define AR5K_RATES_TURBO { 8, {					\
 	255, 255, 255, 255, 255, 255, 255, 255, 6, 4, 2, 0,	\
 	7, 5, 3, 1, 255, 255, 255, 255, 255, 255, 255, 255,	\
 	255, 255, 255, 255, 255, 255, 255, 255 }, {		\
-	{ 1, MODULATION_TURBO, 6000, 11, 140, 0 },	\
-	{ 1, MODULATION_TURBO, 9000, 15, 18, 0 },	\
-	{ 1, MODULATION_TURBO, 12000, 10, 152, 2 },	\
-	{ 1, MODULATION_TURBO, 18000, 14, 36, 2 },	\
-	{ 1, MODULATION_TURBO, 24000, 9, 176, 4 },	\
-	{ 1, MODULATION_TURBO, 36000, 13, 72, 4 },	\
-	{ 1, MODULATION_TURBO, 48000, 8, 96, 4 },	\
-	{ 1, MODULATION_TURBO, 54000, 12, 108, 4 } }	\
+	{ 1, IEEE80211_RATE_TURBO, 6000, 11, 140, 0 },	\
+	{ 1, IEEE80211_RATE_TURBO, 9000, 15, 18, 0 },	\
+	{ 1, IEEE80211_RATE_TURBO, 12000, 10, 152, 2 },	\
+	{ 1, IEEE80211_RATE_TURBO, 18000, 14, 36, 2 },	\
+	{ 1, IEEE80211_RATE_TURBO, 24000, 9, 176, 4 },	\
+	{ 1, IEEE80211_RATE_TURBO, 36000, 13, 72, 4 },	\
+	{ 1, IEEE80211_RATE_TURBO, 48000, 8, 96, 4 },	\
+	{ 1, IEEE80211_RATE_TURBO, 54000, 12, 108, 4 } }	\
 }
 
 #define AR5K_RATES_XR { 12, {					\
@@ -658,14 +654,14 @@ struct ath5k_rate_table {
 	{ 1, MODULATION_XR, 1000, 2, 139, 1 },		\
 	{ 1, MODULATION_XR, 2000, 6, 150, 2 },		\
 	{ 1, MODULATION_XR, 3000, 1, 150, 3 },		\
-	{ 1, MODULATION_OFDM, 6000, 11, 140, 4 },	\
-	{ 1, MODULATION_OFDM, 9000, 15, 18, 4 },	\
-	{ 1, MODULATION_OFDM, 12000, 10, 152, 6 },	\
-	{ 1, MODULATION_OFDM, 18000, 14, 36, 6 },	\
-	{ 1, MODULATION_OFDM, 24000, 9, 176, 8 },	\
-	{ 1, MODULATION_OFDM, 36000, 13, 72, 8 },	\
-	{ 1, MODULATION_OFDM, 48000, 8, 96, 8 },	\
-	{ 1, MODULATION_OFDM, 54000, 12, 108, 8 } }	\
+	{ 1, IEEE80211_RATE_OFDM, 6000, 11, 140, 4 },	\
+	{ 1, IEEE80211_RATE_OFDM, 9000, 15, 18, 4 },	\
+	{ 1, IEEE80211_RATE_OFDM, 12000, 10, 152, 6 },	\
+	{ 1, IEEE80211_RATE_OFDM, 18000, 14, 36, 6 },	\
+	{ 1, IEEE80211_RATE_OFDM, 24000, 9, 176, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 36000, 13, 72, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 48000, 8, 96, 8 },	\
+	{ 1, IEEE80211_RATE_OFDM, 54000, 12, 108, 8 } }	\
 }
 
 /*
diff --git a/drivers/net/wireless/ath5k_base.c b/drivers/net/wireless/ath5k_base.c
index 7f938c4..4bbccf9 100644
--- a/drivers/net/wireless/ath5k_base.c
+++ b/drivers/net/wireless/ath5k_base.c
@@ -1089,7 +1089,7 @@ static void ath_setcurmode(struct ath_softc *sc, unsigned int mode)
 			}
 			sc->hwmap[i].txflags = IEEE80211_RADIOTAP_F_DATAPAD;
 			if (SHPREAMBLE_FLAG(ix) || rt->rates[ix].modulation ==
-					MODULATION_OFDM)
+					IEEE80211_RATE_OFDM)
 				sc->hwmap[i].txflags |=
 						IEEE80211_RADIOTAP_F_SHORTPRE;
 			/* receive frames include FCS */
diff --git a/drivers/net/wireless/ath5k_hw.c b/drivers/net/wireless/ath5k_hw.c
index 887213d..3501b4c 100644
--- a/drivers/net/wireless/ath5k_hw.c
+++ b/drivers/net/wireless/ath5k_hw.c
@@ -142,15 +142,16 @@ ath_hal_computetxtime(struct ath_hw *hal, const struct ath5k_rate_table *rates,
 	 * Calculate the transmission time by operation (PHY) mode
 	 */
 	switch (rate->modulation) {
-	case MODULATION_CCK:
+	case IEEE80211_RATE_CCK:
 		/*
 		 * CCK / DS mode (802.11b)
 		 */
 		value = AR5K_CCK_TX_TIME(rate->rate_kbps, frame_length,
-		    (short_preamble && (rate->modulation == MODULATION_CCK_SP)));
+			short_preamble &&
+			rate->modulation == IEEE80211_RATE_CCK_2);
 		break;
 
-	case MODULATION_OFDM:
+	case IEEE80211_RATE_OFDM:
 		/*
 		 * Orthogonal Frequency Division Multiplexing
 		 */
@@ -159,7 +160,7 @@ ath_hal_computetxtime(struct ath_hw *hal, const struct ath5k_rate_table *rates,
 		value = AR5K_OFDM_TX_TIME(rate->rate_kbps, frame_length);
 		break;
 
-	case MODULATION_TURBO:
+	case IEEE80211_RATE_TURBO:
 		/*
 		 * Orthogonal Frequency Division Multiplexing
 		 * Atheros "Turbo Mode" (doubled rates)
