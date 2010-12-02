From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] ath: Fix ath_dbg uses missing newlines and access beyond array bound
Date: Wed,  1 Dec 2010 21:13:32 -0800
Message-ID: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2109 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab0LBFNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 00:13:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing newlines to ath_dbg uses
ar9300RateSize is not a power of 4, fix to print array line by line.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   29 ++---------------------
 drivers/net/wireless/ath/ath9k/calib.c         |    4 +-
 drivers/net/wireless/ath/ath9k/gpio.c          |    6 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c  |    7 ++---
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |    2 +-
 5 files changed, 12 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index e6ae62b..beb3e87 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3342,7 +3342,7 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
 	goto fail;
 
 found:
-	ath_dbg(common, ATH_DBG_EEPROM, "Found valid EEPROM data");
+	ath_dbg(common, ATH_DBG_EEPROM, "Found valid EEPROM data\n");
 
 	for (it = 0; it < MSTATE; it++) {
 		if (!read(ah, cptr, word, COMP_HDR_LEN))
@@ -4084,22 +4084,9 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
 	    ar9003_hw_eeprom_get_ht40_tgt_pwr(ah, HT_TARGET_RATE_23, freq,
 					      is2GHz) + ht40PowerIncForPdadc;
 
-	while (i < ar9300RateSize) {
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-
+	for (i = 0; i < ar9300RateSize; i++) {
 		ath_dbg(common, ATH_DBG_EEPROM,
 			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
-		i++;
 	}
 }
 
@@ -4687,17 +4674,7 @@ static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 
 	for (i = 0; i < ar9300RateSize; i++) {
 		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
-		i++;
-		ath_dbg(common, ATH_DBG_EEPROM,
-			"TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
-		i++;
+			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
 	}
 
 	/*
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index 0b6c623..b68a1ac 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -324,12 +324,12 @@ static void ath9k_hw_nf_sanitize(struct ath_hw *ah, s16 *nf)
 
 		if (nf[i] > ATH9K_NF_TOO_HIGH) {
 			ath_dbg(common, ATH_DBG_CALIBRATE,
-				"NF[%d] (%d) > MAX (%d), correcting to MAX",
+				"NF[%d] (%d) > MAX (%d), correcting to MAX\n",
 				i, nf[i], ATH9K_NF_TOO_HIGH);
 			nf[i] = limit->max;
 		} else if (nf[i] < limit->min) {
 			ath_dbg(common, ATH_DBG_CALIBRATE,
-				"NF[%d] (%d) < MIN (%d), correcting to NOM",
+				"NF[%d] (%d) < MIN (%d), correcting to NOM\n",
 				i, nf[i], limit->min);
 			nf[i] = limit->nominal;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 60b2fb7..1337640 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -237,12 +237,12 @@ static void ath_detect_bt_priority(struct ath_softc *sc)
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
 			ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
-				"BT scan detected");
+				"BT scan detected\n");
 			sc->sc_flags |= (SC_OP_BT_SCAN |
 					 SC_OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
 			ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
-				"BT priority traffic detected");
+				"BT priority traffic detected\n");
 			sc->sc_flags |= SC_OP_BT_PRIORITY_DETECTED;
 		}
 
@@ -379,7 +379,7 @@ void ath9k_btcoex_timer_resume(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 
 	ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-		"Starting btcoex timers");
+		"Starting btcoex timers\n");
 
 	/* make sure duty cycle timer is also stopped when resuming */
 	if (btcoex->hw_timer_enabled)
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
index d8685f0..283ff97 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
@@ -21,12 +21,12 @@ static void ath_detect_bt_priority(struct ath9k_htc_priv *priv)
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
 			ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-				"BT scan detected");
+				"BT scan detected\n");
 			priv->op_flags |= (OP_BT_SCAN |
 					 OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
 			ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-				"BT priority traffic detected");
+				"BT priority traffic detected\n");
 			priv->op_flags |= OP_BT_PRIORITY_DETECTED;
 		}
 
@@ -114,8 +114,7 @@ void ath_htc_resume_btcoex_work(struct ath9k_htc_priv *priv)
 	struct ath_btcoex *btcoex = &priv->btcoex;
 	struct ath_hw *ah = priv->ah;
 
-	ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-		"Starting btcoex work");
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX, "Starting btcoex work\n");
 
 	btcoex->bt_priority_cnt = 0;
 	btcoex->bt_priority_time = jiffies;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 1af31b5..87731c2 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -1133,7 +1133,7 @@ static int ath9k_htc_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 			spin_unlock_bh(&priv->tx_lock);
 		} else {
 			ath_dbg(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
-				"Tx failed");
+				"Tx failed\n");
 		}
 		goto fail_tx;
 	}
-- 
1.7.3.2.245.g03276.dirty

