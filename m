From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] ath: Convert ath_print to ath_dbg
Date: Thu,  2 Dec 2010 19:12:37 -0800
Message-ID: <84a2e60c05d84171487104f3d347cf28588a22bb.1291333544.git.joe@perches.com>
References: <20101202190239.GE7399@tux>
Cc: Peter Stuge <peter@stuge.se>, Felix Fietkau <nbd@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, netdev@vger.kernel.org,
	ath9k-devel@lists.ath9k.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	Bob Copeland <me@bobcopeland.com>,
	Jouni Malinen <jmalinen@athe
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101202190239.GE7399@tux>
In-Reply-To: <cover.1291333543.git.joe@perches.com>
References: <cover.1291333543.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove ath/debug.h and the includes of these files.
Coalesce long formats.
Correct a few misspellings and missing "\n"s from these logging messages.
Remove unnecessary trailing space before a newline.
Remove ARRAY_SIZE casts, use printf type %zu

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath5k/base.c           |    1 -
 drivers/net/wireless/ath/ath5k/debug.c          |    1 -
 drivers/net/wireless/ath/ath9k/ani.c            |   97 +++++------
 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |  187 +++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9002_calib.c   |  220 +++++++++++------------
 drivers/net/wireless/ath/ath9k/ar9002_mac.c     |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c   |  217 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c  |  173 +++++++++---------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c     |   16 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c     |  205 ++++++++++-----------
 drivers/net/wireless/ath/ath9k/beacon.c         |   65 ++++----
 drivers/net/wireless/ath/ath9k/calib.c          |   59 +++---
 drivers/net/wireless/ath/ath9k/common.c         |    4 +-
 drivers/net/wireless/ath/ath9k/common.h         |    1 -
 drivers/net/wireless/ath/ath9k/eeprom.c         |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |   61 +++----
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |   26 ++--
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |   53 +++---
 drivers/net/wireless/ath/ath9k/gpio.c           |   16 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |   20 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c   |   15 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |   36 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   |  133 +++++++-------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |    8 +-
 drivers/net/wireless/ath/ath9k/hw.c             |   83 +++++-----
 drivers/net/wireless/ath/ath9k/hw.h             |    1 -
 drivers/net/wireless/ath/ath9k/init.c           |   22 ++--
 drivers/net/wireless/ath/ath9k/mac.c            |   86 +++++-----
 drivers/net/wireless/ath/ath9k/main.c           |  129 +++++++-------
 drivers/net/wireless/ath/ath9k/rc.c             |   14 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   33 ++--
 drivers/net/wireless/ath/ath9k/virtual.c        |    7 +-
 drivers/net/wireless/ath/ath9k/wmi.c            |   12 +-
 drivers/net/wireless/ath/ath9k/xmit.c           |   54 +++---
 drivers/net/wireless/ath/debug.h                |   22 ---
 drivers/net/wireless/ath/key.c                  |   13 +-
 36 files changed, 1009 insertions(+), 1105 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/debug.h

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index a8d380a..46f3cd6 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -62,7 +62,6 @@
 #include "reg.h"
 #include "debug.h"
 #include "ani.h"
-#include "../debug.h"
 
 static int modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index 5341dd2..d2f84d7 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -60,7 +60,6 @@
 
 #include "base.h"
 #include "debug.h"
-#include "../debug.h"
 
 static unsigned int ath5k_debug;
 module_param_named(debug, ath5k_debug, uint, 0);
diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index 29a045d..e2ffac3 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -135,8 +135,8 @@ static void ath9k_ani_restart(struct ath_hw *ah)
 		cck_base = AR_PHY_COUNTMAX - ah->config.cck_trig_high;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
-		  "Writing ofdmbase=%u   cckbase=%u\n", ofdm_base, cck_base);
+	ath_dbg(common, ATH_DBG_ANI,
+		"Writing ofdmbase=%u   cckbase=%u\n", ofdm_base, cck_base);
 
 	ENABLE_REGWRITE_BUFFER(ah);
 
@@ -267,11 +267,11 @@ static void ath9k_hw_set_ofdm_nil(struct ath_hw *ah, u8 immunityLevel)
 
 	aniState->noiseFloor = BEACON_RSSI(ah);
 
-	ath_print(common, ATH_DBG_ANI,
-		  "**** ofdmlevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
-		  aniState->ofdmNoiseImmunityLevel,
-		  immunityLevel, aniState->noiseFloor,
-		  aniState->rssiThrLow, aniState->rssiThrHigh);
+	ath_dbg(common, ATH_DBG_ANI,
+		"**** ofdmlevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
+		aniState->ofdmNoiseImmunityLevel,
+		immunityLevel, aniState->noiseFloor,
+		aniState->rssiThrLow, aniState->rssiThrHigh);
 
 	aniState->ofdmNoiseImmunityLevel = immunityLevel;
 
@@ -334,11 +334,11 @@ static void ath9k_hw_set_cck_nil(struct ath_hw *ah, u_int8_t immunityLevel)
 	const struct ani_cck_level_entry *entry_cck;
 
 	aniState->noiseFloor = BEACON_RSSI(ah);
-	ath_print(common, ATH_DBG_ANI,
-		  "**** ccklevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
-		  aniState->cckNoiseImmunityLevel, immunityLevel,
-		  aniState->noiseFloor, aniState->rssiThrLow,
-		  aniState->rssiThrHigh);
+	ath_dbg(common, ATH_DBG_ANI,
+		"**** ccklevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
+		aniState->cckNoiseImmunityLevel, immunityLevel,
+		aniState->noiseFloor, aniState->rssiThrLow,
+		aniState->rssiThrHigh);
 
 	if ((ah->opmode == NL80211_IFTYPE_STATION ||
 	     ah->opmode == NL80211_IFTYPE_ADHOC) &&
@@ -478,8 +478,8 @@ static void ath9k_ani_reset_old(struct ath_hw *ah, bool is_scanning)
 
 	if (ah->opmode != NL80211_IFTYPE_STATION
 	    && ah->opmode != NL80211_IFTYPE_ADHOC) {
-		ath_print(common, ATH_DBG_ANI,
-			  "Reset ANI state opmode %u\n", ah->opmode);
+		ath_dbg(common, ATH_DBG_ANI,
+			"Reset ANI state opmode %u\n", ah->opmode);
 		ah->stats.ast_ani_reset++;
 
 		if (ah->opmode == NL80211_IFTYPE_AP) {
@@ -584,16 +584,14 @@ void ath9k_ani_reset(struct ath_hw *ah, bool is_scanning)
 		    ATH9K_ANI_OFDM_DEF_LEVEL ||
 		    aniState->cckNoiseImmunityLevel !=
 		    ATH9K_ANI_CCK_DEF_LEVEL) {
-			ath_print(common, ATH_DBG_ANI,
-				  "Restore defaults: opmode %u "
-				  "chan %d Mhz/0x%x is_scanning=%d "
-				  "ofdm:%d cck:%d\n",
-				  ah->opmode,
-				  chan->channel,
-				  chan->channelFlags,
-				  is_scanning,
-				  aniState->ofdmNoiseImmunityLevel,
-				  aniState->cckNoiseImmunityLevel);
+			ath_dbg(common, ATH_DBG_ANI,
+				"Restore defaults: opmode %u chan %d Mhz/0x%x is_scanning=%d ofdm:%d cck:%d\n",
+				ah->opmode,
+				chan->channel,
+				chan->channelFlags,
+				is_scanning,
+				aniState->ofdmNoiseImmunityLevel,
+				aniState->cckNoiseImmunityLevel);
 
 			ath9k_hw_set_ofdm_nil(ah, ATH9K_ANI_OFDM_DEF_LEVEL);
 			ath9k_hw_set_cck_nil(ah, ATH9K_ANI_CCK_DEF_LEVEL);
@@ -602,16 +600,14 @@ void ath9k_ani_reset(struct ath_hw *ah, bool is_scanning)
 		/*
 		 * restore historical levels for this channel
 		 */
-		ath_print(common, ATH_DBG_ANI,
-			  "Restore history: opmode %u "
-			  "chan %d Mhz/0x%x is_scanning=%d "
-			  "ofdm:%d cck:%d\n",
-			  ah->opmode,
-			  chan->channel,
-			  chan->channelFlags,
-			  is_scanning,
-			  aniState->ofdmNoiseImmunityLevel,
-			  aniState->cckNoiseImmunityLevel);
+		ath_dbg(common, ATH_DBG_ANI,
+			"Restore history: opmode %u chan %d Mhz/0x%x is_scanning=%d ofdm:%d cck:%d\n",
+			ah->opmode,
+			chan->channel,
+			chan->channelFlags,
+			is_scanning,
+			aniState->ofdmNoiseImmunityLevel,
+			aniState->cckNoiseImmunityLevel);
 
 			ath9k_hw_set_ofdm_nil(ah,
 					      aniState->ofdmNoiseImmunityLevel);
@@ -666,19 +662,17 @@ static bool ath9k_hw_ani_read_counters(struct ath_hw *ah)
 
 	if (!use_new_ani(ah) && (phyCnt1 < ofdm_base || phyCnt2 < cck_base)) {
 		if (phyCnt1 < ofdm_base) {
-			ath_print(common, ATH_DBG_ANI,
-				  "phyCnt1 0x%x, resetting "
-				  "counter value to 0x%x\n",
-				  phyCnt1, ofdm_base);
+			ath_dbg(common, ATH_DBG_ANI,
+				"phyCnt1 0x%x, resetting counter value to 0x%x\n",
+				phyCnt1, ofdm_base);
 			REG_WRITE(ah, AR_PHY_ERR_1, ofdm_base);
 			REG_WRITE(ah, AR_PHY_ERR_MASK_1,
 				  AR_PHY_ERR_OFDM_TIMING);
 		}
 		if (phyCnt2 < cck_base) {
-			ath_print(common, ATH_DBG_ANI,
-				  "phyCnt2 0x%x, resetting "
-				  "counter value to 0x%x\n",
-				  phyCnt2, cck_base);
+			ath_dbg(common, ATH_DBG_ANI,
+				"phyCnt2 0x%x, resetting counter value to 0x%x\n",
+				phyCnt2, cck_base);
 			REG_WRITE(ah, AR_PHY_ERR_2, cck_base);
 			REG_WRITE(ah, AR_PHY_ERR_MASK_2,
 				  AR_PHY_ERR_CCK_TIMING);
@@ -719,13 +713,12 @@ void ath9k_hw_ani_monitor(struct ath_hw *ah, struct ath9k_channel *chan)
 	cckPhyErrRate =  aniState->cckPhyErrCount * 1000 /
 			 aniState->listenTime;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "listenTime=%d OFDM:%d errs=%d/s CCK:%d "
-		  "errs=%d/s ofdm_turn=%d\n",
-		  aniState->listenTime,
-		  aniState->ofdmNoiseImmunityLevel,
-		  ofdmPhyErrRate, aniState->cckNoiseImmunityLevel,
-		  cckPhyErrRate, aniState->ofdmsTurn);
+	ath_dbg(common, ATH_DBG_ANI,
+		"listenTime=%d OFDM:%d errs=%d/s CCK:%d errs=%d/s ofdm_turn=%d\n",
+		aniState->listenTime,
+		aniState->ofdmNoiseImmunityLevel,
+		ofdmPhyErrRate, aniState->cckNoiseImmunityLevel,
+		cckPhyErrRate, aniState->ofdmsTurn);
 
 	if (aniState->listenTime > 5 * ah->aniperiod) {
 		if (ofdmPhyErrRate <= ah->config.ofdm_trig_low &&
@@ -755,7 +748,7 @@ void ath9k_enable_mib_counters(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_ANI, "Enable MIB counters\n");
+	ath_dbg(common, ATH_DBG_ANI, "Enable MIB counters\n");
 
 	ath9k_hw_update_mibstats(ah, &ah->ah_mibStats);
 
@@ -777,7 +770,7 @@ void ath9k_hw_disable_mib_counters(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_ANI, "Disable MIB counters\n");
+	ath_dbg(common, ATH_DBG_ANI, "Disable MIB counters\n");
 
 	REG_WRITE(ah, AR_MIBC, AR_MIBC_FMC);
 	ath9k_hw_update_mibstats(ah, &ah->ah_mibStats);
@@ -852,7 +845,7 @@ void ath9k_hw_ani_init(struct ath_hw *ah)
 	struct ath_common *common = ath9k_hw_common(ah);
 	int i;
 
-	ath_print(common, ATH_DBG_ANI, "Initialize ANI\n");
+	ath_dbg(common, ATH_DBG_ANI, "Initialize ANI\n");
 
 	if (use_new_ani(ah)) {
 		ah->config.ofdm_trig_high = ATH9K_ANI_OFDM_TRIG_HIGH_NEW;
diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
index 9af9f23..059330a 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -130,9 +130,8 @@ static void ar5008_hw_force_bias(struct ath_hw *ah, u16 synth_freq)
 	/* pre-reverse this field */
 	tmp_reg = ath9k_hw_reverse_bits(new_bias, 3);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Force rf_pwd_icsyndiv to %1d on %4d\n",
-		  new_bias, synth_freq);
+	ath_dbg(common, ATH_DBG_CONFIG, "Force rf_pwd_icsyndiv to %1d on %4d\n",
+		new_bias, synth_freq);
 
 	/* swizzle rf_pwd_icsyndiv */
 	ar5008_hw_phy_modify_rx_buffer(ah->analogBank6Data, tmp_reg, 3, 181, 3);
@@ -1054,10 +1053,9 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(ah->totalSizeDesired)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "level out of range (%u > %u)\n",
-				  level,
-				  (unsigned)ARRAY_SIZE(ah->totalSizeDesired));
+			ath_dbg(common, ATH_DBG_ANI,
+				"level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(ah->totalSizeDesired));
 			return false;
 		}
 
@@ -1159,10 +1157,9 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "level out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(firstep));
+			ath_dbg(common, ATH_DBG_ANI,
+				"level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(firstep));
 			return false;
 		}
 		REG_RMW_FIELD(ah, AR_PHY_FIND_SIG,
@@ -1180,10 +1177,9 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "level out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(cycpwrThr1));
+			ath_dbg(common, ATH_DBG_ANI,
+				"level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(cycpwrThr1));
 			return false;
 		}
 		REG_RMW_FIELD(ah, AR_PHY_TIMING5,
@@ -1199,25 +1195,22 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
-			  "invalid cmd %u\n", cmd);
+		ath_dbg(common, ATH_DBG_ANI, "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI, "ANI parameters:\n");
-	ath_print(common, ATH_DBG_ANI,
-		  "noiseImmunityLevel=%d, spurImmunityLevel=%d, "
-		  "ofdmWeakSigDetectOff=%d\n",
-		  aniState->noiseImmunityLevel,
-		  aniState->spurImmunityLevel,
-		  !aniState->ofdmWeakSigDetectOff);
-	ath_print(common, ATH_DBG_ANI,
-		  "cckWeakSigThreshold=%d, "
-		  "firstepLevel=%d, listenTime=%d\n",
-		  aniState->cckWeakSigThreshold,
-		  aniState->firstepLevel,
-		  aniState->listenTime);
-	ath_print(common, ATH_DBG_ANI,
+	ath_dbg(common, ATH_DBG_ANI, "ANI parameters:\n");
+	ath_dbg(common, ATH_DBG_ANI,
+		"noiseImmunityLevel=%d, spurImmunityLevel=%d, ofdmWeakSigDetectOff=%d\n",
+		aniState->noiseImmunityLevel,
+		aniState->spurImmunityLevel,
+		!aniState->ofdmWeakSigDetectOff);
+	ath_dbg(common, ATH_DBG_ANI,
+		"cckWeakSigThreshold=%d, firstepLevel=%d, listenTime=%d\n",
+		aniState->cckWeakSigThreshold,
+		aniState->firstepLevel,
+		aniState->listenTime);
+	ath_dbg(common, ATH_DBG_ANI,
 		"ofdmPhyErrCount=%d, cckPhyErrCount=%d\n\n",
 		aniState->ofdmPhyErrCount,
 		aniState->cckPhyErrCount);
@@ -1302,12 +1295,12 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 				    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);
 
 		if (!on != aniState->ofdmWeakSigDetectOff) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: ofdm weak signal: %s=>%s\n",
-				  chan->channel,
-				  !aniState->ofdmWeakSigDetectOff ?
-					"on" : "off",
-				  on ? "on" : "off");
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: ofdm weak signal: %s=>%s\n",
+				chan->channel,
+				!aniState->ofdmWeakSigDetectOff ?
+				"on" : "off",
+				on ? "on" : "off");
 			if (on)
 				ah->stats.ast_ani_ofdmon++;
 			else
@@ -1320,11 +1313,9 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep_table)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "ATH9K_ANI_FIRSTEP_LEVEL: level "
-				  "out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(firstep_table));
+			ath_dbg(common, ATH_DBG_ANI,
+				"ATH9K_ANI_FIRSTEP_LEVEL: level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(firstep_table));
 			return false;
 		}
 
@@ -1359,24 +1350,22 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 			      AR_PHY_FIND_SIG_FIRSTEP_LOW, value2);
 
 		if (level != aniState->firstepLevel) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "firstep[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->firstepLevel,
-				  level,
-				  ATH9K_ANI_FIRSTEP_LVL_NEW,
-				  value,
-				  aniState->iniDef.firstep);
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "firstep_low[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->firstepLevel,
-				  level,
-				  ATH9K_ANI_FIRSTEP_LVL_NEW,
-				  value2,
-				  aniState->iniDef.firstepLow);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] firstep[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->firstepLevel,
+				level,
+				ATH9K_ANI_FIRSTEP_LVL_NEW,
+				value,
+				aniState->iniDef.firstep);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] firstep_low[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->firstepLevel,
+				level,
+				ATH9K_ANI_FIRSTEP_LVL_NEW,
+				value2,
+				aniState->iniDef.firstepLow);
 			if (level > aniState->firstepLevel)
 				ah->stats.ast_ani_stepup++;
 			else if (level < aniState->firstepLevel)
@@ -1389,11 +1378,9 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1_table)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level "
-				  "out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(cycpwrThr1_table));
+			ath_dbg(common, ATH_DBG_ANI,
+				"ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(cycpwrThr1_table));
 			return false;
 		}
 		/*
@@ -1427,24 +1414,22 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 			      AR_PHY_EXT_TIMING5_CYCPWR_THR1, value2);
 
 		if (level != aniState->spurImmunityLevel) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "cycpwrThr1[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->spurImmunityLevel,
-				  level,
-				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
-				  value,
-				  aniState->iniDef.cycpwrThr1);
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "cycpwrThr1Ext[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->spurImmunityLevel,
-				  level,
-				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
-				  value2,
-				  aniState->iniDef.cycpwrThr1Ext);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] cycpwrThr1[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->spurImmunityLevel,
+				level,
+				ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
+				value,
+				aniState->iniDef.cycpwrThr1);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] cycpwrThr1Ext[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->spurImmunityLevel,
+				level,
+				ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
+				value2,
+				aniState->iniDef.cycpwrThr1Ext);
 			if (level > aniState->spurImmunityLevel)
 				ah->stats.ast_ani_spurup++;
 			else if (level < aniState->spurImmunityLevel)
@@ -1463,22 +1448,19 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
-			  "invalid cmd %u\n", cmd);
+		ath_dbg(common, ATH_DBG_ANI, "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
-		  "ANI parameters: SI=%d, ofdmWS=%s FS=%d "
-		  "MRCcck=%s listenTime=%d "
-		  "ofdmErrs=%d cckErrs=%d\n",
-		  aniState->spurImmunityLevel,
-		  !aniState->ofdmWeakSigDetectOff ? "on" : "off",
-		  aniState->firstepLevel,
-		  !aniState->mrcCCKOff ? "on" : "off",
-		  aniState->listenTime,
-		  aniState->ofdmPhyErrCount,
-		  aniState->cckPhyErrCount);
+	ath_dbg(common, ATH_DBG_ANI,
+		"ANI parameters: SI=%d, ofdmWS=%s FS=%d MRCcck=%s listenTime=%d ofdmErrs=%d cckErrs=%d\n",
+		aniState->spurImmunityLevel,
+		!aniState->ofdmWeakSigDetectOff ? "on" : "off",
+		aniState->firstepLevel,
+		!aniState->mrcCCKOff ? "on" : "off",
+		aniState->listenTime,
+		aniState->ofdmPhyErrCount,
+		aniState->cckPhyErrCount);
 	return true;
 }
 
@@ -1524,13 +1506,12 @@ static void ar5008_hw_ani_cache_ini_regs(struct ath_hw *ah)
 
 	iniDef = &aniState->iniDef;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "ver %d.%d opmode %u chan %d Mhz/0x%x\n",
-		  ah->hw_version.macVersion,
-		  ah->hw_version.macRev,
-		  ah->opmode,
-		  chan->channel,
-		  chan->channelFlags);
+	ath_dbg(common, ATH_DBG_ANI, "ver %d.%d opmode %u chan %d Mhz/0x%x\n",
+		ah->hw_version.macVersion,
+		ah->hw_version.macRev,
+		ah->opmode,
+		chan->channel,
+		chan->channelFlags);
 
 	val = REG_READ(ah, AR_PHY_SFCORR);
 	iniDef->m1Thresh = MS(val, AR_PHY_SFCORR_M1_THRESH);
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index 15f62cd..01880aa 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -39,18 +39,18 @@ static void ar9002_hw_setup_calibration(struct ath_hw *ah,
 	switch (currCal->calData->calType) {
 	case IQ_MISMATCH_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_IQ);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "starting IQ Mismatch Calibration\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"starting IQ Mismatch Calibration\n");
 		break;
 	case ADC_GAIN_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_ADC_GAIN);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "starting ADC Gain Calibration\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"starting ADC Gain Calibration\n");
 		break;
 	case ADC_DC_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_ADC_DC_PER);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "starting ADC DC Calibration\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"starting ADC DC Calibration\n");
 		break;
 	}
 
@@ -107,11 +107,11 @@ static void ar9002_hw_iqcal_collect(struct ath_hw *ah)
 			REG_READ(ah, AR_PHY_CAL_MEAS_1(i));
 		ah->totalIqCorrMeas[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_2(i));
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-			  "%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
-			  ah->cal_samples, i, ah->totalPowerMeasI[i],
-			  ah->totalPowerMeasQ[i],
-			  ah->totalIqCorrMeas[i]);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+			"%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
+			ah->cal_samples, i, ah->totalPowerMeasI[i],
+			ah->totalPowerMeasQ[i],
+			ah->totalIqCorrMeas[i]);
 	}
 }
 
@@ -129,14 +129,13 @@ static void ar9002_hw_adc_gaincal_collect(struct ath_hw *ah)
 		ah->totalAdcQEvenPhase[i] +=
 			REG_READ(ah, AR_PHY_CAL_MEAS_3(i));
 
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-			  "%d: Chn %d oddi=0x%08x; eveni=0x%08x; "
-			  "oddq=0x%08x; evenq=0x%08x;\n",
-			  ah->cal_samples, i,
-			  ah->totalAdcIOddPhase[i],
-			  ah->totalAdcIEvenPhase[i],
-			  ah->totalAdcQOddPhase[i],
-			  ah->totalAdcQEvenPhase[i]);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+			"%d: Chn %d oddi=0x%08x; eveni=0x%08x; oddq=0x%08x; evenq=0x%08x;\n",
+			ah->cal_samples, i,
+			ah->totalAdcIOddPhase[i],
+			ah->totalAdcIEvenPhase[i],
+			ah->totalAdcQOddPhase[i],
+			ah->totalAdcQEvenPhase[i]);
 	}
 }
 
@@ -154,14 +153,13 @@ static void ar9002_hw_adc_dccal_collect(struct ath_hw *ah)
 		ah->totalAdcDcOffsetQEvenPhase[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_3(i));
 
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-			  "%d: Chn %d oddi=0x%08x; eveni=0x%08x; "
-			  "oddq=0x%08x; evenq=0x%08x;\n",
-			  ah->cal_samples, i,
-			  ah->totalAdcDcOffsetIOddPhase[i],
-			  ah->totalAdcDcOffsetIEvenPhase[i],
-			  ah->totalAdcDcOffsetQOddPhase[i],
-			  ah->totalAdcDcOffsetQEvenPhase[i]);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+			"%d: Chn %d oddi=0x%08x; eveni=0x%08x; oddq=0x%08x; evenq=0x%08x;\n",
+			ah->cal_samples, i,
+			ah->totalAdcDcOffsetIOddPhase[i],
+			ah->totalAdcDcOffsetIEvenPhase[i],
+			ah->totalAdcDcOffsetQOddPhase[i],
+			ah->totalAdcDcOffsetQEvenPhase[i]);
 	}
 }
 
@@ -178,13 +176,13 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		powerMeasQ = ah->totalPowerMeasQ[i];
 		iqCorrMeas = ah->totalIqCorrMeas[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Starting IQ Cal and Correction for Chain %d\n",
-			  i);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Starting IQ Cal and Correction for Chain %d\n",
+			i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Orignal: Chn %diq_corr_meas = 0x%08x\n",
-			  i, ah->totalIqCorrMeas[i]);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Orignal: Chn %diq_corr_meas = 0x%08x\n",
+			i, ah->totalIqCorrMeas[i]);
 
 		iqCorrNeg = 0;
 
@@ -193,12 +191,12 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iqCorrNeg = 1;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
-		ath_print(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
-			  iqCorrNeg);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
+		ath_dbg(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
+			iqCorrNeg);
 
 		iCoffDenom = (powerMeasI / 2 + powerMeasQ / 2) / 128;
 		qCoffDenom = powerMeasQ / 64;
@@ -207,14 +205,14 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		    (qCoffDenom != 0)) {
 			iCoff = iqCorrMeas / iCoffDenom;
 			qCoff = powerMeasI / qCoffDenom - 64;
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d iCoff = 0x%08x\n", i, iCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d qCoff = 0x%08x\n", i, qCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d iCoff = 0x%08x\n", i, iCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d qCoff = 0x%08x\n", i, qCoff);
 
 			iCoff = iCoff & 0x3f;
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "New: Chn %d iCoff = 0x%08x\n", i, iCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"New: Chn %d iCoff = 0x%08x\n", i, iCoff);
 			if (iqCorrNeg == 0x0)
 				iCoff = 0x40 - iCoff;
 
@@ -223,9 +221,9 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			else if (qCoff <= -16)
 				qCoff = -16;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
-				  i, iCoff, qCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
+				i, iCoff, qCoff);
 
 			REG_RMW_FIELD(ah, AR_PHY_TIMING_CTRL4(i),
 				      AR_PHY_TIMING_CTRL4_IQCORR_Q_I_COFF,
@@ -233,9 +231,9 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			REG_RMW_FIELD(ah, AR_PHY_TIMING_CTRL4(i),
 				      AR_PHY_TIMING_CTRL4_IQCORR_Q_Q_COFF,
 				      qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "IQ Cal and Correction done for Chain %d\n",
-				  i);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"IQ Cal and Correction done for Chain %d\n",
+				i);
 		}
 	}
 
@@ -255,21 +253,21 @@ static void ar9002_hw_adc_gaincal_calibrate(struct ath_hw *ah, u8 numChains)
 		qOddMeasOffset = ah->totalAdcQOddPhase[i];
 		qEvenMeasOffset = ah->totalAdcQEvenPhase[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Starting ADC Gain Cal for Chain %d\n", i);
-
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_odd_i = 0x%08x\n", i,
-			  iOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_even_i = 0x%08x\n", i,
-			  iEvenMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_odd_q = 0x%08x\n", i,
-			  qOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_even_q = 0x%08x\n", i,
-			  qEvenMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Starting ADC Gain Cal for Chain %d\n", i);
+
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_odd_i = 0x%08x\n", i,
+			iOddMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_even_i = 0x%08x\n", i,
+			iEvenMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_odd_q = 0x%08x\n", i,
+			qOddMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_even_q = 0x%08x\n", i,
+			qEvenMeasOffset);
 
 		if (iOddMeasOffset != 0 && qEvenMeasOffset != 0) {
 			iGainMismatch =
@@ -279,20 +277,20 @@ static void ar9002_hw_adc_gaincal_calibrate(struct ath_hw *ah, u8 numChains)
 				((qOddMeasOffset * 32) /
 				 qEvenMeasOffset) & 0x3f;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d gain_mismatch_i = 0x%08x\n", i,
-				  iGainMismatch);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d gain_mismatch_q = 0x%08x\n", i,
-				  qGainMismatch);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d gain_mismatch_i = 0x%08x\n", i,
+				iGainMismatch);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d gain_mismatch_q = 0x%08x\n", i,
+				qGainMismatch);
 
 			val = REG_READ(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i));
 			val &= 0xfffff000;
 			val |= (qGainMismatch) | (iGainMismatch << 6);
 			REG_WRITE(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i), val);
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "ADC Gain Cal done for Chain %d\n", i);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"ADC Gain Cal done for Chain %d\n", i);
 		}
 	}
 
@@ -317,41 +315,41 @@ static void ar9002_hw_adc_dccal_calibrate(struct ath_hw *ah, u8 numChains)
 		qOddMeasOffset = ah->totalAdcDcOffsetQOddPhase[i];
 		qEvenMeasOffset = ah->totalAdcDcOffsetQEvenPhase[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			   "Starting ADC DC Offset Cal for Chain %d\n", i);
-
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_odd_i = %d\n", i,
-			  iOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_even_i = %d\n", i,
-			  iEvenMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_odd_q = %d\n", i,
-			  qOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_even_q = %d\n", i,
-			  qEvenMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Starting ADC DC Offset Cal for Chain %d\n", i);
+
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_odd_i = %d\n", i,
+			iOddMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_even_i = %d\n", i,
+			iEvenMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_odd_q = %d\n", i,
+			qOddMeasOffset);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_even_q = %d\n", i,
+			qEvenMeasOffset);
 
 		iDcMismatch = (((iEvenMeasOffset - iOddMeasOffset) * 2) /
 			       numSamples) & 0x1ff;
 		qDcMismatch = (((qOddMeasOffset - qEvenMeasOffset) * 2) /
 			       numSamples) & 0x1ff;
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d dc_offset_mismatch_i = 0x%08x\n", i,
-			  iDcMismatch);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d dc_offset_mismatch_q = 0x%08x\n", i,
-			  qDcMismatch);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d dc_offset_mismatch_i = 0x%08x\n", i,
+			iDcMismatch);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d dc_offset_mismatch_q = 0x%08x\n", i,
+			qDcMismatch);
 
 		val = REG_READ(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i));
 		val &= 0xc0000fff;
 		val |= (qDcMismatch << 12) | (iDcMismatch << 21);
 		REG_WRITE(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i), val);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "ADC DC Offset Cal done for Chain %d\n", i);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"ADC DC Offset Cal done for Chain %d\n", i);
 	}
 
 	REG_WRITE(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(0),
@@ -540,7 +538,7 @@ static inline void ar9285_hw_pa_cal(struct ath_hw *ah, bool is_reset)
 		{ 0x7838, 0 },
 	};
 
-	ath_print(common, ATH_DBG_CALIBRATE, "Running PA Calibration\n");
+	ath_dbg(common, ATH_DBG_CALIBRATE, "Running PA Calibration\n");
 
 	/* PA CAL is not needed for high power solution */
 	if (ah->eep_ops->get_eeprom(ah, EEP_TXGAIN_TYPE) ==
@@ -721,9 +719,8 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 		REG_SET_BIT(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL);
 		if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL,
 				  AR_PHY_AGC_CONTROL_CAL, 0, AH_WAIT_TIMEOUT)) {
-			ath_print(common, ATH_DBG_CALIBRATE, "offset "
-				  "calibration failed to complete in "
-				  "1ms; noisy ??\n");
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"offset calibration failed to complete in 1ms; noisy environment?\n");
 			return false;
 		}
 		REG_CLR_BIT(ah, AR_PHY_TURBO, AR_PHY_FC_DYN2040_EN);
@@ -736,8 +733,8 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 	REG_SET_BIT(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL);
 	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
 			  0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE, "offset calibration "
-			  "failed to complete in 1ms; noisy ??\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"offset calibration failed to complete in 1ms; noisy environment?\n");
 		return false;
 	}
 
@@ -829,9 +826,8 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 		if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL,
 				   AR_PHY_AGC_CONTROL_CAL,
 				   0, AH_WAIT_TIMEOUT)) {
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "offset calibration failed to "
-				  "complete in 1ms; noisy environment?\n");
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"offset calibration failed to complete in 1ms; noisy environment?\n");
 			return false;
 		}
 
@@ -866,19 +862,19 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 
 			INIT_CAL(&ah->adcgain_caldata);
 			INSERT_CAL(ah, &ah->adcgain_caldata);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "enabling ADC Gain Calibration.\n");
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"enabling ADC Gain Calibration.\n");
 
 			INIT_CAL(&ah->adcdc_caldata);
 			INSERT_CAL(ah, &ah->adcdc_caldata);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "enabling ADC DC Calibration.\n");
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"enabling ADC DC Calibration.\n");
 		}
 
 		INIT_CAL(&ah->iq_caldata);
 		INSERT_CAL(ah, &ah->iq_caldata);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "enabling IQ Calibration.\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"enabling IQ Calibration.\n");
 
 		ah->cal_list_curr = ah->cal_list;
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_mac.c b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
index f0268e5..f3f9c58 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
@@ -111,8 +111,8 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		}
 
 		if (isr & AR_ISR_RXORN) {
-			ath_print(common, ATH_DBG_INTERRUPT,
-				  "receive FIFO overrun interrupt\n");
+			ath_dbg(common, ATH_DBG_INTERRUPT,
+				"receive FIFO overrun interrupt\n");
 		}
 
 		*masked |= mask2;
@@ -147,25 +147,25 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 
 		if (fatal_int) {
 			if (sync_cause & AR_INTR_SYNC_HOST1_FATAL) {
-				ath_print(common, ATH_DBG_ANY,
-					  "received PCI FATAL interrupt\n");
+				ath_dbg(common, ATH_DBG_ANY,
+					"received PCI FATAL interrupt\n");
 			}
 			if (sync_cause & AR_INTR_SYNC_HOST1_PERR) {
-				ath_print(common, ATH_DBG_ANY,
-					  "received PCI PERR interrupt\n");
+				ath_dbg(common, ATH_DBG_ANY,
+					"received PCI PERR interrupt\n");
 			}
 			*masked |= ATH9K_INT_FATAL;
 		}
 		if (sync_cause & AR_INTR_SYNC_RADM_CPL_TIMEOUT) {
-			ath_print(common, ATH_DBG_INTERRUPT,
-				  "AR_INTR_SYNC_RADM_CPL_TIMEOUT\n");
+			ath_dbg(common, ATH_DBG_INTERRUPT,
+				"AR_INTR_SYNC_RADM_CPL_TIMEOUT\n");
 			REG_WRITE(ah, AR_RC, AR_RC_HOSTIF);
 			REG_WRITE(ah, AR_RC, 0);
 			*masked |= ATH9K_INT_FATAL;
 		}
 		if (sync_cause & AR_INTR_SYNC_LOCAL_TIMEOUT) {
-			ath_print(common, ATH_DBG_INTERRUPT,
-				  "AR_INTR_SYNC_LOCAL_TIMEOUT\n");
+			ath_dbg(common, ATH_DBG_INTERRUPT,
+				"AR_INTR_SYNC_LOCAL_TIMEOUT\n");
 		}
 
 		REG_WRITE(ah, AR_INTR_SYNC_CAUSE_CLR, sync_cause);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 4c94c9e..16d2029 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -40,8 +40,8 @@ static void ar9003_hw_setup_calibration(struct ath_hw *ah,
 		currCal->calData->calCountMax);
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_IQ);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "starting IQ Mismatch Calibration\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"starting IQ Mismatch Calibration\n");
 
 		/* Kick-off cal */
 		REG_SET_BIT(ah, AR_PHY_TIMING4, AR_PHY_TIMING4_DO_CAL);
@@ -52,8 +52,8 @@ static void ar9003_hw_setup_calibration(struct ath_hw *ah,
 		REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_THERM,
 			      AR_PHY_65NM_CH0_THERM_START, 1);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "starting Temperature Compensation Calibration\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"starting Temperature Compensation Calibration\n");
 		break;
 	}
 }
@@ -181,11 +181,11 @@ static void ar9003_hw_iqcal_collect(struct ath_hw *ah)
 			REG_READ(ah, AR_PHY_CAL_MEAS_1(i));
 		ah->totalIqCorrMeas[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_2(i));
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-			  "%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
-			  ah->cal_samples, i, ah->totalPowerMeasI[i],
-			  ah->totalPowerMeasQ[i],
-			  ah->totalIqCorrMeas[i]);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+			"%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
+			ah->cal_samples, i, ah->totalPowerMeasI[i],
+			ah->totalPowerMeasQ[i],
+			ah->totalIqCorrMeas[i]);
 	}
 }
 
@@ -207,13 +207,13 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		powerMeasQ = ah->totalPowerMeasQ[i];
 		iqCorrMeas = ah->totalIqCorrMeas[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Starting IQ Cal and Correction for Chain %d\n",
-			  i);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Starting IQ Cal and Correction for Chain %d\n",
+			i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Orignal: Chn %diq_corr_meas = 0x%08x\n",
-			  i, ah->totalIqCorrMeas[i]);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Orignal: Chn %diq_corr_meas = 0x%08x\n",
+			i, ah->totalIqCorrMeas[i]);
 
 		iqCorrNeg = 0;
 
@@ -222,12 +222,12 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iqCorrNeg = 1;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
-		ath_print(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
-			  iqCorrNeg);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
+		ath_dbg(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
+			iqCorrNeg);
 
 		iCoffDenom = (powerMeasI / 2 + powerMeasQ / 2) / 256;
 		qCoffDenom = powerMeasQ / 64;
@@ -235,10 +235,10 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		if ((iCoffDenom != 0) && (qCoffDenom != 0)) {
 			iCoff = iqCorrMeas / iCoffDenom;
 			qCoff = powerMeasI / qCoffDenom - 64;
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d iCoff = 0x%08x\n", i, iCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d qCoff = 0x%08x\n", i, qCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d iCoff = 0x%08x\n", i, iCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d qCoff = 0x%08x\n", i, qCoff);
 
 			/* Force bounds on iCoff */
 			if (iCoff >= 63)
@@ -259,14 +259,13 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iCoff = iCoff & 0x7f;
 			qCoff = qCoff & 0x7f;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
-				  i, iCoff, qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Register offset (0x%04x) "
-				  "before update = 0x%x\n",
-				  offset_array[i],
-				  REG_READ(ah, offset_array[i]));
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
+				i, iCoff, qCoff);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Register offset (0x%04x) before update = 0x%x\n",
+				offset_array[i],
+				REG_READ(ah, offset_array[i]));
 
 			REG_RMW_FIELD(ah, offset_array[i],
 				      AR_PHY_RX_IQCAL_CORR_IQCORR_Q_I_COFF,
@@ -274,33 +273,29 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			REG_RMW_FIELD(ah, offset_array[i],
 				      AR_PHY_RX_IQCAL_CORR_IQCORR_Q_Q_COFF,
 				      qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Register offset (0x%04x) QI COFF "
-				  "(bitfields 0x%08x) after update = 0x%x\n",
-				  offset_array[i],
-				  AR_PHY_RX_IQCAL_CORR_IQCORR_Q_I_COFF,
-				  REG_READ(ah, offset_array[i]));
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Register offset (0x%04x) QQ COFF "
-				  "(bitfields 0x%08x) after update = 0x%x\n",
-				  offset_array[i],
-				  AR_PHY_RX_IQCAL_CORR_IQCORR_Q_Q_COFF,
-				  REG_READ(ah, offset_array[i]));
-
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "IQ Cal and Correction done for Chain %d\n",
-				  i);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Register offset (0x%04x) QI COFF (bitfields 0x%08x) after update = 0x%x\n",
+				offset_array[i],
+				AR_PHY_RX_IQCAL_CORR_IQCORR_Q_I_COFF,
+				REG_READ(ah, offset_array[i]));
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Register offset (0x%04x) QQ COFF (bitfields 0x%08x) after update = 0x%x\n",
+				offset_array[i],
+				AR_PHY_RX_IQCAL_CORR_IQCORR_Q_Q_COFF,
+				REG_READ(ah, offset_array[i]));
+
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"IQ Cal and Correction done for Chain %d\n", i);
 		}
 	}
 
 	REG_SET_BIT(ah, AR_PHY_RX_IQCAL_CORR_B0,
 		    AR_PHY_RX_IQCAL_CORR_IQCORR_ENABLE);
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "IQ Cal and Correction (offset 0x%04x) enabled "
-		  "(bit position 0x%08x). New Value 0x%08x\n",
-		  (unsigned) (AR_PHY_RX_IQCAL_CORR_B0),
-		  AR_PHY_RX_IQCAL_CORR_IQCORR_ENABLE,
-		  REG_READ(ah, AR_PHY_RX_IQCAL_CORR_B0));
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"IQ Cal and Correction (offset 0x%04x) enabled (bit position 0x%08x). New Value 0x%08x\n",
+		(unsigned) (AR_PHY_RX_IQCAL_CORR_B0),
+		AR_PHY_RX_IQCAL_CORR_IQCORR_ENABLE,
+		REG_READ(ah, AR_PHY_RX_IQCAL_CORR_B0));
 }
 
 static const struct ath9k_percal_data iq_cal_single_sample = {
@@ -340,7 +335,7 @@ static bool ar9003_hw_solve_iq_cal(struct ath_hw *ah,
 	f2 = (f1 * f1 + f3 * f3) / result_shift;
 
 	if (!f2) {
-		ath_print(common, ATH_DBG_CALIBRATE, "Divide by 0\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE, "Divide by 0\n");
 		return false;
 	}
 
@@ -461,11 +456,14 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	if ((i2_p_q2_a0_d0 == 0) || (i2_p_q2_a0_d1 == 0) ||
 	    (i2_p_q2_a1_d0 == 0) || (i2_p_q2_a1_d1 == 0)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Divide by 0:\na0_d0=%d\n"
-			  "a0_d1=%d\na2_d0=%d\na1_d1=%d\n",
-			  i2_p_q2_a0_d0, i2_p_q2_a0_d1,
-			  i2_p_q2_a1_d0, i2_p_q2_a1_d1);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Divide by 0:\n"
+			"a0_d0=%d\n"
+			"a0_d1=%d\n"
+			"a2_d0=%d\n"
+			"a1_d1=%d\n",
+			i2_p_q2_a0_d0, i2_p_q2_a0_d1,
+			i2_p_q2_a1_d0, i2_p_q2_a1_d1);
 		return false;
 	}
 
@@ -498,9 +496,9 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	mag2 = ar9003_hw_find_mag_approx(ah, cos_2phi_2, sin_2phi_2);
 
 	if ((mag1 == 0) || (mag2 == 0)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Divide by 0: mag1=%d, mag2=%d\n",
-			  mag1, mag2);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Divide by 0: mag1=%d, mag2=%d\n",
+			mag1, mag2);
 		return false;
 	}
 
@@ -517,8 +515,8 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 			     mag_a0_d0, phs_a0_d0,
 			     mag_a1_d0,
 			     phs_a1_d0, solved_eq)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Call to ar9003_hw_solve_iq_cal() failed.\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Call to ar9003_hw_solve_iq_cal() failed.\n");
 		return false;
 	}
 
@@ -527,14 +525,14 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	mag_rx = solved_eq[2];
 	phs_rx = solved_eq[3];
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "chain %d: mag mismatch=%d phase mismatch=%d\n",
-		  chain_idx, mag_tx/res_scale, phs_tx/res_scale);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"chain %d: mag mismatch=%d phase mismatch=%d\n",
+		chain_idx, mag_tx/res_scale, phs_tx/res_scale);
 
 	if (res_scale == mag_tx) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Divide by 0: mag_tx=%d, res_scale=%d\n",
-			  mag_tx, res_scale);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Divide by 0: mag_tx=%d, res_scale=%d\n",
+			mag_tx, res_scale);
 		return false;
 	}
 
@@ -545,9 +543,9 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	q_q_coff = (mag_corr_tx * 128 / res_scale);
 	q_i_coff = (phs_corr_tx * 256 / res_scale);
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "tx chain %d: mag corr=%d  phase corr=%d\n",
-		  chain_idx, q_q_coff, q_i_coff);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"tx chain %d: mag corr=%d  phase corr=%d\n",
+		chain_idx, q_q_coff, q_i_coff);
 
 	if (q_i_coff < -63)
 		q_i_coff = -63;
@@ -560,14 +558,14 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	iqc_coeff[0] = (q_q_coff * 128) + q_i_coff;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "tx chain %d: iq corr coeff=%x\n",
-		  chain_idx, iqc_coeff[0]);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"tx chain %d: iq corr coeff=%x\n",
+		chain_idx, iqc_coeff[0]);
 
 	if (-mag_rx == res_scale) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Divide by 0: mag_rx=%d, res_scale=%d\n",
-			  mag_rx, res_scale);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Divide by 0: mag_rx=%d, res_scale=%d\n",
+			mag_rx, res_scale);
 		return false;
 	}
 
@@ -578,9 +576,9 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	q_q_coff = (mag_corr_rx * 128 / res_scale);
 	q_i_coff = (phs_corr_rx * 256 / res_scale);
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "rx chain %d: mag corr=%d  phase corr=%d\n",
-		  chain_idx, q_q_coff, q_i_coff);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"rx chain %d: mag corr=%d  phase corr=%d\n",
+		chain_idx, q_q_coff, q_i_coff);
 
 	if (q_i_coff < -63)
 		q_i_coff = -63;
@@ -593,9 +591,9 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	iqc_coeff[1] = (q_q_coff * 128) + q_i_coff;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "rx chain %d: iq corr coeff=%x\n",
-		  chain_idx, iqc_coeff[1]);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"rx chain %d: iq corr coeff=%x\n",
+		chain_idx, iqc_coeff[1]);
 
 	return true;
 }
@@ -643,19 +641,19 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 	if (!ath9k_hw_wait(ah, AR_PHY_TX_IQCAL_START,
 			   AR_PHY_TX_IQCAL_START_DO_CAL,
 			   0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Tx IQ Cal not complete.\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Tx IQ Cal not complete.\n");
 		goto TX_IQ_CAL_FAILED;
 	}
 
 	for (i = 0; i < num_chains; i++) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Doing Tx IQ Cal for chain %d.\n", i);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Doing Tx IQ Cal for chain %d.\n", i);
 
 		if (REG_READ(ah, txiqcal_status[i]) &
 			     AR_PHY_TX_IQCAL_STATUS_FAILED) {
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Tx IQ Cal failed for chain %d.\n", i);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Tx IQ Cal failed for chain %d.\n", i);
 			goto TX_IQ_CAL_FAILED;
 		}
 
@@ -677,20 +675,20 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 							  chan_info_tab[i] +
 							  offset);
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "IQ RES[%d]=0x%x IQ_RES[%d]=0x%x\n",
-				  idx, iq_res[idx], idx+1, iq_res[idx+1]);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"IQ RES[%d]=0x%x IQ_RES[%d]=0x%x\n",
+				idx, iq_res[idx], idx+1, iq_res[idx+1]);
 		}
 
 		if (!ar9003_hw_calc_iq_corr(ah, i, iq_res, iqc_coeff)) {
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "Failed in calculation of IQ correction.\n");
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"Failed in calculation of IQ correction.\n");
 			goto TX_IQ_CAL_FAILED;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "IQ_COEFF[0] = 0x%x IQ_COEFF[1] = 0x%x\n",
-			  iqc_coeff[0], iqc_coeff[1]);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"IQ_COEFF[0] = 0x%x IQ_COEFF[1] = 0x%x\n",
+			iqc_coeff[0], iqc_coeff[1]);
 
 		REG_RMW_FIELD(ah, tx_corr_coeff[i],
 			      AR_PHY_TX_IQCAL_CORR_COEFF_01_COEFF_TABLE,
@@ -711,7 +709,7 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 	return;
 
 TX_IQ_CAL_FAILED:
-	ath_print(common, ATH_DBG_CALIBRATE, "Tx IQ Cal failed\n");
+	ath_dbg(common, ATH_DBG_CALIBRATE, "Tx IQ Cal failed\n");
 }
 
 static bool ar9003_hw_init_cal(struct ath_hw *ah,
@@ -721,7 +719,7 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	int val;
 
 	val = REG_READ(ah, AR_ENT_OTP);
-	ath_print(common, ATH_DBG_CALIBRATE, "ath9k: AR_ENT_OTP 0x%x\n", val);
+	ath_dbg(common, ATH_DBG_CALIBRATE, "ath9k: AR_ENT_OTP 0x%x\n", val);
 
 	if (val & AR_ENT_OTP_CHAIN2_DISABLE)
 		ar9003_hw_set_chain_masks(ah, 0x3, 0x3);
@@ -746,9 +744,8 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	/* Poll for offset calibration complete */
 	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
 			   0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "offset calibration failed to "
-			  "complete in 1ms; noisy environment?\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"offset calibration failed to complete in 1ms; noisy environment?\n");
 		return false;
 	}
 
@@ -764,15 +761,15 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	if (ah->supp_cals & IQ_MISMATCH_CAL) {
 		INIT_CAL(&ah->iq_caldata);
 		INSERT_CAL(ah, &ah->iq_caldata);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "enabling IQ Calibration.\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"enabling IQ Calibration.\n");
 	}
 
 	if (ah->supp_cals & TEMP_COMP_CAL) {
 		INIT_CAL(&ah->tempCompCalData);
 		INSERT_CAL(ah, &ah->tempCompCalData);
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "enabling Temperature Compensation Calibration.\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"enabling Temperature Compensation Calibration.\n");
 	}
 
 	/* Initialize current pointer to first element in list */
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 4aecc10..7b13a2e 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3069,8 +3069,8 @@ static bool ar9300_read_eeprom(struct ath_hw *ah, int address, u8 *buffer,
 	int i;
 
 	if ((address < 0) || ((address + count) / 2 > AR9300_EEPROM_SIZE - 1)) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "eeprom address not in range\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"eeprom address not in range\n");
 		return false;
 	}
 
@@ -3101,8 +3101,8 @@ static bool ar9300_read_eeprom(struct ath_hw *ah, int address, u8 *buffer,
 	return true;
 
 error:
-	ath_print(common, ATH_DBG_EEPROM,
-		  "unable to read eeprom region at offset %d\n", address);
+	ath_dbg(common, ATH_DBG_EEPROM,
+		"unable to read eeprom region at offset %d\n", address);
 	return false;
 }
 
@@ -3186,17 +3186,15 @@ static bool ar9300_uncompress_block(struct ath_hw *ah,
 		length &= 0xff;
 
 		if (length > 0 && spot >= 0 && spot+length <= mdataSize) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Restore at %d: spot=%d "
-				  "offset=%d length=%d\n",
-				   it, spot, offset, length);
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Restore at %d: spot=%d offset=%d length=%d\n",
+				it, spot, offset, length);
 			memcpy(&mptr[spot], &block[it+2], length);
 			spot += length;
 		} else if (length > 0) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Bad restore at %d: spot=%d "
-				  "offset=%d length=%d\n",
-				  it, spot, offset, length);
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Bad restore at %d: spot=%d offset=%d length=%d\n",
+				it, spot, offset, length);
 			return false;
 		}
 	}
@@ -3217,14 +3215,15 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 	switch (code) {
 	case _CompressNone:
 		if (length != mdata_size) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "EEPROM structure size mismatch"
-				  "memory=%d eeprom=%d\n", mdata_size, length);
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"EEPROM structure size mismatch memory=%d eeprom=%d\n",
+				mdata_size, length);
 			return -1;
 		}
 		memcpy(mptr, (u8 *) (word + COMP_HDR_LEN), length);
-		ath_print(common, ATH_DBG_EEPROM, "restored eeprom %d:"
-			  " uncompressed, length %d\n", it, length);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"restored eeprom %d: uncompressed, length %d\n",
+			it, length);
 		break;
 	case _CompressBlock:
 		if (reference == 0) {
@@ -3232,22 +3231,22 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 		} else {
 			eep = ar9003_eeprom_struct_find_by_id(reference);
 			if (eep == NULL) {
-				ath_print(common, ATH_DBG_EEPROM,
-					  "cant find reference eeprom"
-					  "struct %d\n", reference);
+				ath_dbg(common, ATH_DBG_EEPROM,
+					"cant find reference eeprom struct %d\n",
+					reference);
 				return -1;
 			}
 			memcpy(mptr, eep, mdata_size);
 		}
-		ath_print(common, ATH_DBG_EEPROM,
-			  "restore eeprom %d: block, reference %d,"
-			  " length %d\n", it, reference, length);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"restore eeprom %d: block, reference %d, length %d\n",
+			it, reference, length);
 		ar9300_uncompress_block(ah, mptr, mdata_size,
 					(u8 *) (word + COMP_HDR_LEN), length);
 		break;
 	default:
-		ath_print(common, ATH_DBG_EEPROM, "unknown compression"
-			  " code %d\n", code);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"unknown compression code %d\n", code);
 		return -1;
 	}
 	return 0;
@@ -3318,26 +3317,26 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
 
 	read = ar9300_read_eeprom;
 	cptr = AR9300_BASE_ADDR;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_dbg(common, ATH_DBG_EEPROM,
 		"Trying EEPROM accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	cptr = AR9300_BASE_ADDR_512;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_dbg(common, ATH_DBG_EEPROM,
 		"Trying EEPROM accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	read = ar9300_read_otp;
 	cptr = AR9300_BASE_ADDR;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_dbg(common, ATH_DBG_EEPROM,
 		"Trying OTP accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	cptr = AR9300_BASE_ADDR_512;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_dbg(common, ATH_DBG_EEPROM,
 		"Trying OTP accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
@@ -3345,7 +3344,7 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
 	goto fail;
 
 found:
-	ath_print(common, ATH_DBG_EEPROM, "Found valid EEPROM data");
+	ath_dbg(common, ATH_DBG_EEPROM, "Found valid EEPROM data\n");
 
 	for (it = 0; it < MSTATE; it++) {
 		if (!read(ah, cptr, word, COMP_HDR_LEN))
@@ -3356,13 +3355,12 @@ found:
 
 		ar9300_comp_hdr_unpack(word, &code, &reference,
 				       &length, &major, &minor);
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Found block at %x: code=%d ref=%d"
-			  "length=%d major=%d minor=%d\n", cptr, code,
-			  reference, length, major, minor);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Found block at %x: code=%d ref=%d length=%d major=%d minor=%d\n",
+			cptr, code, reference, length, major, minor);
 		if (length >= 1024) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Skipping bad header\n");
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Skipping bad header\n");
 			cptr -= COMP_HDR_LEN;
 			continue;
 		}
@@ -3372,14 +3370,14 @@ found:
 		checksum = ar9300_comp_cksum(&word[COMP_HDR_LEN], length);
 		mchecksum = word[COMP_HDR_LEN + osize] |
 		    (word[COMP_HDR_LEN + osize + 1] << 8);
-		ath_print(common, ATH_DBG_EEPROM,
-			  "checksum %x %x\n", checksum, mchecksum);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"checksum %x %x\n", checksum, mchecksum);
 		if (checksum == mchecksum) {
 			ar9300_compress_decision(ah, it, code, reference, mptr,
 						 word, length, mdata_size);
 		} else {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "skipping block with bad checksum\n");
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"skipping block with bad checksum\n");
 		}
 		cptr -= (COMP_HDR_LEN + osize + COMP_CKSUM_LEN);
 	}
@@ -4089,20 +4087,20 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
 					      is2GHz) + ht40PowerIncForPdadc;
 
 	while (i < ar9300RateSize) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
 		i++;
 	}
 }
@@ -4122,18 +4120,17 @@ static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	if (ichain >= AR9300_MAX_CHAINS) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Invalid chain index, must be less than %d\n",
-			  AR9300_MAX_CHAINS);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Invalid chain index, must be less than %d\n",
+			AR9300_MAX_CHAINS);
 		return -1;
 	}
 
 	if (mode) {		/* 5GHz */
 		if (ipier >= AR9300_NUM_5G_CAL_PIERS) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Invalid 5GHz cal pier index, must "
-				  "be less than %d\n",
-				  AR9300_NUM_5G_CAL_PIERS);
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Invalid 5GHz cal pier index, must be less than %d\n",
+				AR9300_NUM_5G_CAL_PIERS);
 			return -1;
 		}
 		pCalPier = &(eep->calFreqPier5G[ipier]);
@@ -4141,9 +4138,9 @@ static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
 		is2GHz = 0;
 	} else {
 		if (ipier >= AR9300_NUM_2G_CAL_PIERS) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Invalid 2GHz cal pier index, must "
-				  "be less than %d\n", AR9300_NUM_2G_CAL_PIERS);
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Invalid 2GHz cal pier index, must be less than %d\n",
+				AR9300_NUM_2G_CAL_PIERS);
 			return -1;
 		}
 
@@ -4293,11 +4290,11 @@ static int ar9003_hw_calibration_apply(struct ath_hw *ah, int frequency)
 
 	/* interpolate  */
 	for (ichain = 0; ichain < AR9300_MAX_CHAINS; ichain++) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "ch=%d f=%d low=%d %d h=%d %d\n",
-			  ichain, frequency, lfrequency[ichain],
-			  lcorrection[ichain], hfrequency[ichain],
-			  hcorrection[ichain]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"ch=%d f=%d low=%d %d h=%d %d\n",
+			ichain, frequency, lfrequency[ichain],
+			lcorrection[ichain], hfrequency[ichain],
+			hcorrection[ichain]);
 		/* they're the same, so just pick one */
 		if (hfrequency[ichain] == lfrequency[ichain]) {
 			correction[ichain] = lcorrection[ichain];
@@ -4349,9 +4346,9 @@ static int ar9003_hw_calibration_apply(struct ath_hw *ah, int frequency)
 	ar9003_hw_power_control_override(ah, frequency, correction, voltage,
 					 temperature);
 
-	ath_print(common, ATH_DBG_EEPROM,
-		  "for frequency=%d, calibration correction = %d %d %d\n",
-		  frequency, correction[0], correction[1], correction[2]);
+	ath_dbg(common, ATH_DBG_EEPROM,
+		"for frequency=%d, calibration correction = %d %d %d\n",
+		frequency, correction[0], correction[1], correction[2]);
 
 	return 0;
 }
@@ -4556,11 +4553,10 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 		else
 			freq = centers.ctl_center;
 
-		ath_print(common, ATH_DBG_REGULATORY,
-			  "LOOP-Mode ctlMode %d < %d, isHt40CtlMode %d, "
-			  "EXT_ADDITIVE %d\n",
-			  ctlMode, numCtlModes, isHt40CtlMode,
-			  (pCtlMode[ctlMode] & EXT_ADDITIVE));
+		ath_dbg(common, ATH_DBG_REGULATORY,
+			"LOOP-Mode ctlMode %d < %d, isHt40CtlMode %d, EXT_ADDITIVE %d\n",
+			ctlMode, numCtlModes, isHt40CtlMode,
+			(pCtlMode[ctlMode] & EXT_ADDITIVE));
 
 		/* walk through each CTL index stored in EEPROM */
 		if (is2ghz) {
@@ -4572,12 +4568,10 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 		}
 
 		for (i = 0; (i < ctlNum) && ctlIndex[i]; i++) {
-			ath_print(common, ATH_DBG_REGULATORY,
-				  "LOOP-Ctlidx %d: cfgCtl 0x%2.2x "
-				  "pCtlMode 0x%2.2x ctlIndex 0x%2.2x "
-				  "chan %dn",
-				  i, cfgCtl, pCtlMode[ctlMode], ctlIndex[i],
-				  chan->channel);
+			ath_dbg(common, ATH_DBG_REGULATORY,
+				"LOOP-Ctlidx %d: cfgCtl 0x%2.2x pCtlMode 0x%2.2x ctlIndex 0x%2.2x chan %d\n",
+				i, cfgCtl, pCtlMode[ctlMode], ctlIndex[i],
+				chan->channel);
 
 				/*
 				 * compare test group from regulatory
@@ -4616,11 +4610,10 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 
 			minCtlPower = (u8)min(twiceMaxEdgePower, scaledPower);
 
-			ath_print(common, ATH_DBG_REGULATORY,
-				  "SEL-Min ctlMode %d pCtlMode %d 2xMaxEdge %d "
-				  "sP %d minCtlPwr %d\n",
-				  ctlMode, pCtlMode[ctlMode], twiceMaxEdgePower,
-				  scaledPower, minCtlPower);
+			ath_dbg(common, ATH_DBG_REGULATORY,
+				"SEL-Min ctlMode %d pCtlMode %d 2xMaxEdge %d sP %d minCtlPwr %d\n",
+				ctlMode, pCtlMode[ctlMode], twiceMaxEdgePower,
+				scaledPower, minCtlPower);
 
 			/* Apply ctl mode to correct target power set */
 			switch (pCtlMode[ctlMode]) {
@@ -4695,17 +4688,17 @@ static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 		return;
 
 	for (i = 0; i < ar9300RateSize; i++) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
-			  "TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
 		i++;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index f5896aa..bfba6a2 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -182,8 +182,8 @@ static bool ar9003_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		}
 
 		if (sync_cause & AR_INTR_SYNC_LOCAL_TIMEOUT)
-			ath_print(common, ATH_DBG_INTERRUPT,
-				  "AR_INTR_SYNC_LOCAL_TIMEOUT\n");
+			ath_dbg(common, ATH_DBG_INTERRUPT,
+				"AR_INTR_SYNC_LOCAL_TIMEOUT\n");
 
 		REG_WRITE(ah, AR_INTR_SYNC_CAUSE_CLR, sync_cause);
 		(void) REG_READ(ah, AR_INTR_SYNC_CAUSE_CLR);
@@ -249,8 +249,8 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 
 	if ((MS(ads->ds_info, AR_DescId) != ATHEROS_VENDOR_ID) ||
 	    (MS(ads->ds_info, AR_TxRxDesc) != 1)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
-			  "Tx Descriptor error %x\n", ads->ds_info);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_XMIT,
+			"Tx Descriptor error %x\n", ads->ds_info);
 		memset(ads, 0, sizeof(*ads));
 		return -EIO;
 	}
@@ -658,10 +658,10 @@ void ath9k_hw_reset_txstatus_ring(struct ath_hw *ah)
 	memset((void *) ah->ts_ring, 0,
 		ah->ts_size * sizeof(struct ar9003_txs));
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
-		  "TS Start 0x%x End 0x%x Virt %p, Size %d\n",
-		   ah->ts_paddr_start, ah->ts_paddr_end,
-		   ah->ts_ring, ah->ts_size);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_XMIT,
+		"TS Start 0x%x End 0x%x Virt %p, Size %d\n",
+		ah->ts_paddr_start, ah->ts_paddr_end,
+		ah->ts_ring, ah->ts_size);
 
 	REG_WRITE(ah, AR_Q_STATUS_RING_START, ah->ts_paddr_start);
 	REG_WRITE(ah, AR_Q_STATUS_RING_END, ah->ts_paddr_end);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index b34a9e9..63b6d56 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -824,12 +824,12 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 				    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);
 
 		if (!on != aniState->ofdmWeakSigDetectOff) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: ofdm weak signal: %s=>%s\n",
-				  chan->channel,
-				  !aniState->ofdmWeakSigDetectOff ?
-					"on" : "off",
-				  on ? "on" : "off");
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: ofdm weak signal: %s=>%s\n",
+				chan->channel,
+				!aniState->ofdmWeakSigDetectOff ?
+				"on" : "off",
+				on ? "on" : "off");
 			if (on)
 				ah->stats.ast_ani_ofdmon++;
 			else
@@ -842,11 +842,9 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep_table)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "ATH9K_ANI_FIRSTEP_LEVEL: level "
-				  "out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(firstep_table));
+			ath_dbg(common, ATH_DBG_ANI,
+				"ATH9K_ANI_FIRSTEP_LEVEL: level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(firstep_table));
 			return false;
 		}
 
@@ -881,24 +879,22 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 			      AR_PHY_FIND_SIG_LOW_FIRSTEP_LOW, value2);
 
 		if (level != aniState->firstepLevel) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "firstep[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->firstepLevel,
-				  level,
-				  ATH9K_ANI_FIRSTEP_LVL_NEW,
-				  value,
-				  aniState->iniDef.firstep);
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "firstep_low[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->firstepLevel,
-				  level,
-				  ATH9K_ANI_FIRSTEP_LVL_NEW,
-				  value2,
-				  aniState->iniDef.firstepLow);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] firstep[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->firstepLevel,
+				level,
+				ATH9K_ANI_FIRSTEP_LVL_NEW,
+				value,
+				aniState->iniDef.firstep);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] firstep_low[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->firstepLevel,
+				level,
+				ATH9K_ANI_FIRSTEP_LVL_NEW,
+				value2,
+				aniState->iniDef.firstepLow);
 			if (level > aniState->firstepLevel)
 				ah->stats.ast_ani_stepup++;
 			else if (level < aniState->firstepLevel)
@@ -911,11 +907,9 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1_table)) {
-			ath_print(common, ATH_DBG_ANI,
-				  "ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level "
-				  "out of range (%u > %u)\n",
-				  level,
-				  (unsigned) ARRAY_SIZE(cycpwrThr1_table));
+			ath_dbg(common, ATH_DBG_ANI,
+				"ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level out of range (%u > %zu)\n",
+				level, ARRAY_SIZE(cycpwrThr1_table));
 			return false;
 		}
 		/*
@@ -949,24 +943,22 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 			      AR_PHY_EXT_CYCPWR_THR1, value2);
 
 		if (level != aniState->spurImmunityLevel) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "cycpwrThr1[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->spurImmunityLevel,
-				  level,
-				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
-				  value,
-				  aniState->iniDef.cycpwrThr1);
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: level %d=>%d[def:%d] "
-				  "cycpwrThr1Ext[level]=%d ini=%d\n",
-				  chan->channel,
-				  aniState->spurImmunityLevel,
-				  level,
-				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
-				  value2,
-				  aniState->iniDef.cycpwrThr1Ext);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] cycpwrThr1[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->spurImmunityLevel,
+				level,
+				ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
+				value,
+				aniState->iniDef.cycpwrThr1);
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: level %d=>%d[def:%d] cycpwrThr1Ext[level]=%d ini=%d\n",
+				chan->channel,
+				aniState->spurImmunityLevel,
+				level,
+				ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
+				value2,
+				aniState->iniDef.cycpwrThr1Ext);
 			if (level > aniState->spurImmunityLevel)
 				ah->stats.ast_ani_spurup++;
 			else if (level < aniState->spurImmunityLevel)
@@ -986,11 +978,11 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		REG_RMW_FIELD(ah, AR_PHY_MRC_CCK_CTRL,
 			      AR_PHY_MRC_CCK_MUX_REG, is_on);
 		if (!is_on != aniState->mrcCCKOff) {
-			ath_print(common, ATH_DBG_ANI,
-				  "** ch %d: MRC CCK: %s=>%s\n",
-				  chan->channel,
-				  !aniState->mrcCCKOff ? "on" : "off",
-				  is_on ? "on" : "off");
+			ath_dbg(common, ATH_DBG_ANI,
+				"** ch %d: MRC CCK: %s=>%s\n",
+				chan->channel,
+				!aniState->mrcCCKOff ? "on" : "off",
+				is_on ? "on" : "off");
 		if (is_on)
 			ah->stats.ast_ani_ccklow++;
 		else
@@ -1002,22 +994,19 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
-			  "invalid cmd %u\n", cmd);
+		ath_dbg(common, ATH_DBG_ANI, "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
-		  "ANI parameters: SI=%d, ofdmWS=%s FS=%d "
-		  "MRCcck=%s listenTime=%d "
-		  "ofdmErrs=%d cckErrs=%d\n",
-		  aniState->spurImmunityLevel,
-		  !aniState->ofdmWeakSigDetectOff ? "on" : "off",
-		  aniState->firstepLevel,
-		  !aniState->mrcCCKOff ? "on" : "off",
-		  aniState->listenTime,
-		  aniState->ofdmPhyErrCount,
-		  aniState->cckPhyErrCount);
+	ath_dbg(common, ATH_DBG_ANI,
+		"ANI parameters: SI=%d, ofdmWS=%s FS=%d MRCcck=%s listenTime=%d ofdmErrs=%d cckErrs=%d\n",
+		aniState->spurImmunityLevel,
+		!aniState->ofdmWeakSigDetectOff ? "on" : "off",
+		aniState->firstepLevel,
+		!aniState->mrcCCKOff ? "on" : "off",
+		aniState->listenTime,
+		aniState->ofdmPhyErrCount,
+		aniState->cckPhyErrCount);
 	return true;
 }
 
@@ -1074,13 +1063,13 @@ static void ar9003_hw_ani_cache_ini_regs(struct ath_hw *ah)
 	aniState = &ah->curchan->ani;
 	iniDef = &aniState->iniDef;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "ver %d.%d opmode %u chan %d Mhz/0x%x\n",
-		  ah->hw_version.macVersion,
-		  ah->hw_version.macRev,
-		  ah->opmode,
-		  chan->channel,
-		  chan->channelFlags);
+	ath_dbg(common, ATH_DBG_ANI,
+		"ver %d.%d opmode %u chan %d Mhz/0x%x\n",
+		ah->hw_version.macVersion,
+		ah->hw_version.macRev,
+		ah->opmode,
+		chan->channel,
+		chan->channelFlags);
 
 	val = REG_READ(ah, AR_PHY_SFCORR);
 	iniDef->m1Thresh = MS(val, AR_PHY_SFCORR_M1_THRESH);
@@ -1216,7 +1205,7 @@ void ar9003_hw_bb_watchdog_config(struct ath_hw *ah)
 			  ~(AR_PHY_WATCHDOG_NON_IDLE_ENABLE |
 			    AR_PHY_WATCHDOG_IDLE_ENABLE));
 
-		ath_print(common, ATH_DBG_RESET, "Disabled BB Watchdog\n");
+		ath_dbg(common, ATH_DBG_RESET, "Disabled BB Watchdog\n");
 		return;
 	}
 
@@ -1252,9 +1241,9 @@ void ar9003_hw_bb_watchdog_config(struct ath_hw *ah)
 		  AR_PHY_WATCHDOG_IDLE_MASK |
 		  (AR_PHY_WATCHDOG_NON_IDLE_MASK & (idle_count << 2)));
 
-	ath_print(common, ATH_DBG_RESET,
-		  "Enabled BB Watchdog timeout (%u ms)\n",
-		  idle_tmo_ms);
+	ath_dbg(common, ATH_DBG_RESET,
+		"Enabled BB Watchdog timeout (%u ms)\n",
+		idle_tmo_ms);
 }
 
 void ar9003_hw_bb_watchdog_read(struct ath_hw *ah)
@@ -1282,37 +1271,35 @@ void ar9003_hw_bb_watchdog_dbg_info(struct ath_hw *ah)
 		return;
 
 	status = ah->bb_watchdog_last_status;
-	ath_print(common, ATH_DBG_RESET,
-		  "\n==== BB update: BB status=0x%08x ====\n", status);
-	ath_print(common, ATH_DBG_RESET,
-		  "** BB state: wd=%u det=%u rdar=%u rOFDM=%d "
-		  "rCCK=%u tOFDM=%u tCCK=%u agc=%u src=%u **\n",
-		  MS(status, AR_PHY_WATCHDOG_INFO),
-		  MS(status, AR_PHY_WATCHDOG_DET_HANG),
-		  MS(status, AR_PHY_WATCHDOG_RADAR_SM),
-		  MS(status, AR_PHY_WATCHDOG_RX_OFDM_SM),
-		  MS(status, AR_PHY_WATCHDOG_RX_CCK_SM),
-		  MS(status, AR_PHY_WATCHDOG_TX_OFDM_SM),
-		  MS(status, AR_PHY_WATCHDOG_TX_CCK_SM),
-		  MS(status, AR_PHY_WATCHDOG_AGC_SM),
-		  MS(status,AR_PHY_WATCHDOG_SRCH_SM));
-
-	ath_print(common, ATH_DBG_RESET,
-		  "** BB WD cntl: cntl1=0x%08x cntl2=0x%08x **\n",
-		  REG_READ(ah, AR_PHY_WATCHDOG_CTL_1),
-		  REG_READ(ah, AR_PHY_WATCHDOG_CTL_2));
-	ath_print(common, ATH_DBG_RESET,
-		  "** BB mode: BB_gen_controls=0x%08x **\n",
-		  REG_READ(ah, AR_PHY_GEN_CTRL));
+	ath_dbg(common, ATH_DBG_RESET,
+		"\n==== BB update: BB status=0x%08x ====\n", status);
+	ath_dbg(common, ATH_DBG_RESET,
+		"** BB state: wd=%u det=%u rdar=%u rOFDM=%d rCCK=%u tOFDM=%u tCCK=%u agc=%u src=%u **\n",
+		MS(status, AR_PHY_WATCHDOG_INFO),
+		MS(status, AR_PHY_WATCHDOG_DET_HANG),
+		MS(status, AR_PHY_WATCHDOG_RADAR_SM),
+		MS(status, AR_PHY_WATCHDOG_RX_OFDM_SM),
+		MS(status, AR_PHY_WATCHDOG_RX_CCK_SM),
+		MS(status, AR_PHY_WATCHDOG_TX_OFDM_SM),
+		MS(status, AR_PHY_WATCHDOG_TX_CCK_SM),
+		MS(status, AR_PHY_WATCHDOG_AGC_SM),
+		MS(status, AR_PHY_WATCHDOG_SRCH_SM));
+
+	ath_dbg(common, ATH_DBG_RESET,
+		"** BB WD cntl: cntl1=0x%08x cntl2=0x%08x **\n",
+		REG_READ(ah, AR_PHY_WATCHDOG_CTL_1),
+		REG_READ(ah, AR_PHY_WATCHDOG_CTL_2));
+	ath_dbg(common, ATH_DBG_RESET,
+		"** BB mode: BB_gen_controls=0x%08x **\n",
+		REG_READ(ah, AR_PHY_GEN_CTRL));
 
 #define PCT(_field) (common->cc_survey._field * 100 / common->cc_survey.cycles)
 	if (common->cc_survey.cycles)
-		ath_print(common, ATH_DBG_RESET,
-			  "** BB busy times: rx_clear=%d%%, "
-			  "rx_frame=%d%%, tx_frame=%d%% **\n",
-			  PCT(rx_busy), PCT(rx_frame), PCT(tx_frame));
+		ath_dbg(common, ATH_DBG_RESET,
+			"** BB busy times: rx_clear=%d%%, rx_frame=%d%%, tx_frame=%d%% **\n",
+			PCT(rx_busy), PCT(rx_frame), PCT(tx_frame));
 
-	ath_print(common, ATH_DBG_RESET,
-		  "==== BB update: done ====\n\n");
+	ath_dbg(common, ATH_DBG_RESET,
+		"==== BB update: done ====\n\n");
 }
 EXPORT_SYMBOL(ar9003_hw_bb_watchdog_dbg_info);
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 70019e9..5e108c0 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -120,11 +120,11 @@ static void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 	memset(&txctl, 0, sizeof(struct ath_tx_control));
 	txctl.txq = sc->beacon.cabq;
 
-	ath_print(common, ATH_DBG_XMIT,
-		  "transmitting CABQ packet, skb: %p\n", skb);
+	ath_dbg(common, ATH_DBG_XMIT,
+		"transmitting CABQ packet, skb: %p\n", skb);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
-		ath_print(common, ATH_DBG_XMIT, "CABQ TX failed\n");
+		ath_dbg(common, ATH_DBG_XMIT, "CABQ TX failed\n");
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -209,8 +209,8 @@ static struct ath_buf *ath_beacon_generate(struct ieee80211_hw *hw,
 
 	if (skb && cabq_depth) {
 		if (sc->nvifs > 1) {
-			ath_print(common, ATH_DBG_BEACON,
-				  "Flushing previous cabq traffic\n");
+			ath_dbg(common, ATH_DBG_BEACON,
+				"Flushing previous cabq traffic\n");
 			ath_draintxq(sc, cabq, false);
 		}
 	}
@@ -282,7 +282,7 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 	/* NB: the beacon data buffer must be 32-bit aligned. */
 	skb = ieee80211_beacon_get(sc->hw, vif);
 	if (skb == NULL) {
-		ath_print(common, ATH_DBG_BEACON, "cannot get skb\n");
+		ath_dbg(common, ATH_DBG_BEACON, "cannot get skb\n");
 		return -ENOMEM;
 	}
 
@@ -306,10 +306,9 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 		tsfadjust = intval * avp->av_bslot / ATH_BCBUF;
 		avp->tsf_adjust = cpu_to_le64(TU_TO_USEC(tsfadjust));
 
-		ath_print(common, ATH_DBG_BEACON,
-			  "stagger beacons, bslot %d intval "
-			  "%u tsfadjust %llu\n",
-			  avp->av_bslot, intval, (unsigned long long)tsfadjust);
+		ath_dbg(common, ATH_DBG_BEACON,
+			"stagger beacons, bslot %d intval %u tsfadjust %llu\n",
+			avp->av_bslot, intval, (unsigned long long)tsfadjust);
 
 		((struct ieee80211_mgmt *)skb->data)->u.beacon.timestamp =
 			avp->tsf_adjust;
@@ -380,13 +379,13 @@ void ath_beacon_tasklet(unsigned long data)
 		sc->beacon.bmisscnt++;
 
 		if (sc->beacon.bmisscnt < BSTUCK_THRESH) {
-			ath_print(common, ATH_DBG_BSTUCK,
-				  "missed %u consecutive beacons\n",
-				  sc->beacon.bmisscnt);
+			ath_dbg(common, ATH_DBG_BSTUCK,
+				"missed %u consecutive beacons\n",
+				sc->beacon.bmisscnt);
 			ath9k_hw_bstuck_nfcal(ah);
 		} else if (sc->beacon.bmisscnt >= BSTUCK_THRESH) {
-			ath_print(common, ATH_DBG_BSTUCK,
-				  "beacon is officially stuck\n");
+			ath_dbg(common, ATH_DBG_BSTUCK,
+				"beacon is officially stuck\n");
 			sc->sc_flags |= SC_OP_TSF_RESET;
 			ath_reset(sc, true);
 		}
@@ -395,9 +394,9 @@ void ath_beacon_tasklet(unsigned long data)
 	}
 
 	if (sc->beacon.bmisscnt != 0) {
-		ath_print(common, ATH_DBG_BSTUCK,
-			  "resume beacon xmit after %u misses\n",
-			  sc->beacon.bmisscnt);
+		ath_dbg(common, ATH_DBG_BSTUCK,
+			"resume beacon xmit after %u misses\n",
+			sc->beacon.bmisscnt);
 		sc->beacon.bmisscnt = 0;
 	}
 
@@ -423,9 +422,9 @@ void ath_beacon_tasklet(unsigned long data)
 	vif = sc->beacon.bslot[slot];
 	aphy = sc->beacon.bslot_aphy[slot];
 
-	ath_print(common, ATH_DBG_BEACON,
-		  "slot %d [tsf %llu tsftu %u intval %u] vif %p\n",
-		  slot, tsf, tsftu, intval, vif);
+	ath_dbg(common, ATH_DBG_BEACON,
+		"slot %d [tsf %llu tsftu %u intval %u] vif %p\n",
+		slot, tsf, tsftu, intval, vif);
 
 	bfaddr = 0;
 	if (vif) {
@@ -554,8 +553,8 @@ static void ath_beacon_config_sta(struct ath_softc *sc,
 
 	/* No need to configure beacon if we are not associated */
 	if (!common->curaid) {
-		ath_print(common, ATH_DBG_BEACON,
-			 "STA is not yet associated..skipping beacon config\n");
+		ath_dbg(common, ATH_DBG_BEACON,
+			"STA is not yet associated..skipping beacon config\n");
 		return;
 	}
 
@@ -648,11 +647,11 @@ static void ath_beacon_config_sta(struct ath_softc *sc,
 	/* TSF out of range threshold fixed at 1 second */
 	bs.bs_tsfoor_threshold = ATH9K_TSFOOR_THRESHOLD;
 
-	ath_print(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
-	ath_print(common, ATH_DBG_BEACON,
-		  "bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
-		  bs.bs_bmissthreshold, bs.bs_sleepduration,
-		  bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
+	ath_dbg(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
+	ath_dbg(common, ATH_DBG_BEACON,
+		"bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
+		bs.bs_bmissthreshold, bs.bs_sleepduration,
+		bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
 
 	/* Set the computed STA beacon timers */
 
@@ -688,9 +687,9 @@ static void ath_beacon_config_adhoc(struct ath_softc *sc,
 		nexttbtt += intval;
 	} while (nexttbtt < tsftu);
 
-	ath_print(common, ATH_DBG_BEACON,
-		  "IBSS nexttbtt %u intval %u (%u)\n",
-		  nexttbtt, intval, conf->beacon_interval);
+	ath_dbg(common, ATH_DBG_BEACON,
+		"IBSS nexttbtt %u intval %u (%u)\n",
+		nexttbtt, intval, conf->beacon_interval);
 
 	/*
 	 * In IBSS mode enable the beacon timers but only enable SWBA interrupts
@@ -753,8 +752,8 @@ void ath_beacon_config(struct ath_softc *sc, struct ieee80211_vif *vif)
 		ath_beacon_config_sta(sc, cur_conf);
 		break;
 	default:
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Unsupported beaconing mode\n");
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Unsupported beaconing mode\n");
 		return;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index 6d50948..b68a1ac 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -97,12 +97,12 @@ static void ath9k_hw_update_nfcal_hist_buffer(struct ath_hw *ah,
 		if (h[i].privNF > limit->max) {
 			high_nf_mid = true;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "NFmid[%d] (%d) > MAX (%d), %s\n",
-				  i, h[i].privNF, limit->max,
-				  (cal->nfcal_interference ?
-				   "not corrected (due to interference)" :
-				   "correcting to MAX"));
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"NFmid[%d] (%d) > MAX (%d), %s\n",
+				i, h[i].privNF, limit->max,
+				(cal->nfcal_interference ?
+				 "not corrected (due to interference)" :
+				 "correcting to MAX"));
 
 			/*
 			 * Normally we limit the average noise floor by the
@@ -180,18 +180,18 @@ bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 		return true;
 
 	if (currCal->calState != CAL_DONE) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "Calibration state incorrect, %d\n",
-			  currCal->calState);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"Calibration state incorrect, %d\n",
+			currCal->calState);
 		return true;
 	}
 
 	if (!(ah->supp_cals & currCal->calData->calType))
 		return true;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
-		  "Resetting Cal %d state for channel %u\n",
-		  currCal->calData->calType, conf->channel->center_freq);
+	ath_dbg(common, ATH_DBG_CALIBRATE,
+		"Resetting Cal %d state for channel %u\n",
+		currCal->calData->calType, conf->channel->center_freq);
 
 	ah->caldata->CalValid &= ~currCal->calData->calType;
 	currCal->calState = CAL_WAITING;
@@ -279,9 +279,9 @@ void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	 * noisefloor until the next calibration timer.
 	 */
 	if (j == 1000) {
-		ath_print(common, ATH_DBG_ANY, "Timeout while waiting for nf "
-			  "to load: AR_PHY_AGC_CONTROL=0x%x\n",
-			  REG_READ(ah, AR_PHY_AGC_CONTROL));
+		ath_dbg(common, ATH_DBG_ANY,
+			"Timeout while waiting for nf to load: AR_PHY_AGC_CONTROL=0x%x\n",
+			REG_READ(ah, AR_PHY_AGC_CONTROL));
 		return;
 	}
 
@@ -318,19 +318,19 @@ static void ath9k_hw_nf_sanitize(struct ath_hw *ah, s16 *nf)
 		if (!nf[i])
 			continue;
 
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "NF calibrated [%s] [chain %d] is %d\n",
-			  (i >= 3 ? "ext" : "ctl"), i % 3, nf[i]);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"NF calibrated [%s] [chain %d] is %d\n",
+			(i >= 3 ? "ext" : "ctl"), i % 3, nf[i]);
 
 		if (nf[i] > ATH9K_NF_TOO_HIGH) {
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "NF[%d] (%d) > MAX (%d), correcting to MAX",
-				  i, nf[i], ATH9K_NF_TOO_HIGH);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"NF[%d] (%d) > MAX (%d), correcting to MAX\n",
+				i, nf[i], ATH9K_NF_TOO_HIGH);
 			nf[i] = limit->max;
 		} else if (nf[i] < limit->min) {
-			ath_print(common, ATH_DBG_CALIBRATE,
-				  "NF[%d] (%d) < MIN (%d), correcting to NOM",
-				  i, nf[i], limit->min);
+			ath_dbg(common, ATH_DBG_CALIBRATE,
+				"NF[%d] (%d) < MIN (%d), correcting to NOM\n",
+				i, nf[i], limit->min);
 			nf[i] = limit->nominal;
 		}
 	}
@@ -347,8 +347,8 @@ bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan)
 
 	chan->channelFlags &= (~CHANNEL_CW_INT);
 	if (REG_READ(ah, AR_PHY_AGC_CONTROL) & AR_PHY_AGC_CONTROL_NF) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "NF did not complete in calibration window\n");
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"NF did not complete in calibration window\n");
 		return false;
 	}
 
@@ -357,10 +357,9 @@ bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	nf = nfarray[0];
 	if (ath9k_hw_get_nf_thresh(ah, c->band, &nfThresh)
 	    && nf > nfThresh) {
-		ath_print(common, ATH_DBG_CALIBRATE,
-			  "noise floor failed detected; "
-			  "detected %d, threshold %d\n",
-			  nf, nfThresh);
+		ath_dbg(common, ATH_DBG_CALIBRATE,
+			"noise floor failed detected; detected %d, threshold %d\n",
+			nf, nfThresh);
 		chan->channelFlags |= CHANNEL_CW_INT;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/common.c b/drivers/net/wireless/ath/ath9k/common.c
index 48b07c3..df1998d 100644
--- a/drivers/net/wireless/ath/ath9k/common.c
+++ b/drivers/net/wireless/ath/ath9k/common.c
@@ -180,8 +180,8 @@ void ath9k_cmn_btcoex_bt_stomp(struct ath_common *common,
 					   AR_STOMP_NONE_WLAN_WGHT);
 		break;
 	default:
-		ath_print(common, ATH_DBG_BTCOEX,
-			  "Invalid Stomptype\n");
+		ath_dbg(common, ATH_DBG_BTCOEX,
+			"Invalid Stomptype\n");
 		break;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/common.h b/drivers/net/wireless/ath/ath9k/common.h
index 4c04ee8..a126bdd 100644
--- a/drivers/net/wireless/ath/ath9k/common.h
+++ b/drivers/net/wireless/ath/ath9k/common.h
@@ -17,7 +17,6 @@
 #include <net/mac80211.h>
 
 #include "../ath.h"
-#include "../debug.h"
 
 #include "hw.h"
 #include "hw-ops.h"
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index 1266333..b1734df 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -273,8 +273,8 @@ void ath9k_hw_update_regulatory_maxpower(struct ath_hw *ah)
 		regulatory->max_power_level += INCREASE_MAXPOW_BY_THREE_CHAIN;
 		break;
 	default:
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Invalid chainmask configuration\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Invalid chainmask configuration\n");
 		break;
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index f74692d..939fc7a 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -37,14 +37,14 @@ static bool ath9k_hw_4k_fill_eeprom(struct ath_hw *ah)
 	eep_start_loc = 64;
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Reading from EEPROM, not flash\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Reading from EEPROM, not flash\n");
 	}
 
 	for (addr = 0; addr < SIZE_EEPROM_4K; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + eep_start_loc, eep_data)) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Unable to read eeprom region\n");
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Unable to read eeprom region\n");
 			return false;
 		}
 		eep_data++;
@@ -73,8 +73,8 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 			return false;
 		}
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Read Magic = 0x%04X\n", magic);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
 			magic2 = swab16(magic);
@@ -90,14 +90,14 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 				}
 			} else {
 				ath_err(common,
-					"Invalid EEPROM Magic. endianness mismatch.\n");
+					"Invalid EEPROM Magic. Endianness mismatch.\n");
 				return -EINVAL;
 			}
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
-		  need_swap ? "True" : "False");
+	ath_dbg(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+		need_swap ? "True" : "False");
 
 	if (need_swap)
 		el = swab16(ah->eeprom.map4k.baseEepHeader.length);
@@ -118,8 +118,8 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 		u32 integer;
 		u16 word;
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "EEPROM Endianness is not native.. Changing\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"EEPROM Endianness is not native.. Changing\n");
 
 		word = swab16(eep->baseEepHeader.length);
 		eep->baseEepHeader.length = word;
@@ -485,21 +485,20 @@ static void ath9k_hw_set_4k_power_cal_table(struct ath_hw *ah,
 					((pdadcValues[4 * j + 3] & 0xFF) << 24);
 				REG_WRITE(ah, regOffset, reg32);
 
-				ath_print(common, ATH_DBG_EEPROM,
-					  "PDADC (%d,%4x): %4.4x %8.8x\n",
-					  i, regChainOffset, regOffset,
-					  reg32);
-				ath_print(common, ATH_DBG_EEPROM,
-					  "PDADC: Chain %d | "
-					  "PDADC %3d Value %3d | "
-					  "PDADC %3d Value %3d | "
-					  "PDADC %3d Value %3d | "
-					  "PDADC %3d Value %3d |\n",
-					  i, 4 * j, pdadcValues[4 * j],
-					  4 * j + 1, pdadcValues[4 * j + 1],
-					  4 * j + 2, pdadcValues[4 * j + 2],
-					  4 * j + 3,
-					  pdadcValues[4 * j + 3]);
+				ath_dbg(common, ATH_DBG_EEPROM,
+					"PDADC (%d,%4x): %4.4x %8.8x\n",
+					i, regChainOffset, regOffset,
+					reg32);
+				ath_dbg(common, ATH_DBG_EEPROM,
+					"PDADC: Chain %d | "
+					"PDADC %3d Value %3d | "
+					"PDADC %3d Value %3d | "
+					"PDADC %3d Value %3d | "
+					"PDADC %3d Value %3d |\n",
+					i, 4 * j, pdadcValues[4 * j],
+					4 * j + 1, pdadcValues[4 * j + 1],
+					4 * j + 2, pdadcValues[4 * j + 2],
+					4 * j + 3, pdadcValues[4 * j + 3]);
 
 				regOffset += 4;
 			}
@@ -1178,17 +1177,17 @@ static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "Getting spur idx %d is2Ghz. %d val %x\n",
-		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
+	ath_dbg(common, ATH_DBG_ANI,
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
+		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
 	case SPUR_DISABLE:
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
-			  "Getting spur val from new loc. %d\n", spur_val);
+		ath_dbg(common, ATH_DBG_ANI,
+			"Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
 		spur_val = EEP_MAP4K_SPURCHAN;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 9308b68..9ec4bc8 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -43,15 +43,15 @@ static bool ath9k_hw_ar9287_fill_eeprom(struct ath_hw *ah)
 		eep_start_loc = AR9287_HTC_EEP_START_LOC;
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Reading from EEPROM, not flash\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Reading from EEPROM, not flash\n");
 	}
 
 	for (addr = 0; addr < NUM_EEP_WORDS; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + eep_start_loc,
 					 eep_data)) {
-			ath_print(common, ATH_DBG_EEPROM,
-				  "Unable to read eeprom region\n");
+			ath_dbg(common, ATH_DBG_EEPROM,
+				"Unable to read eeprom region\n");
 			return false;
 		}
 		eep_data++;
@@ -76,8 +76,8 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 			return false;
 		}
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Read Magic = 0x%04X\n", magic);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
 			magic2 = swab16(magic);
@@ -99,8 +99,8 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
-		  need_swap ? "True" : "False");
+	ath_dbg(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+		need_swap ? "True" : "False");
 
 	if (need_swap)
 		el = swab16(ah->eeprom.map9287.baseEepHeader.length);
@@ -1149,17 +1149,17 @@ static u16 ath9k_hw_ar9287_get_spur_channel(struct ath_hw *ah,
 	struct ath_common *common = ath9k_hw_common(ah);
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "Getting spur idx %d is2Ghz. %d val %x\n",
-		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
+	ath_dbg(common, ATH_DBG_ANI,
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
+		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
 	case SPUR_DISABLE:
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
-			  "Getting spur val from new loc. %d\n", spur_val);
+		ath_dbg(common, ATH_DBG_ANI,
+			"Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
 		spur_val = EEP_MAP9287_SPURCHAN;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index d95f4c2..9aa31aa 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -122,8 +122,8 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 	}
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
-			  "Read Magic = 0x%04X\n", magic);
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
 			magic2 = swab16(magic);
@@ -146,8 +146,8 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
-		  need_swap ? "True" : "False");
+	ath_dbg(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+		need_swap ? "True" : "False");
 
 	if (need_swap)
 		el = swab16(ah->eeprom.def.baseEepHeader.length);
@@ -168,8 +168,8 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 		u32 integer, j;
 		u16 word;
 
-		ath_print(common, ATH_DBG_EEPROM,
-			  "EEPROM Endianness is not native.. Changing.\n");
+		ath_dbg(common, ATH_DBG_EEPROM,
+			"EEPROM Endianness is not native.. Changing.\n");
 
 		word = swab16(eep->baseEepHeader.length);
 		eep->baseEepHeader.length = word;
@@ -963,20 +963,19 @@ static void ath9k_hw_set_def_power_cal_table(struct ath_hw *ah,
 					((pdadcValues[4 * j + 3] & 0xFF) << 24);
 				REG_WRITE(ah, regOffset, reg32);
 
-				ath_print(common, ATH_DBG_EEPROM,
-					  "PDADC (%d,%4x): %4.4x %8.8x\n",
-					  i, regChainOffset, regOffset,
-					  reg32);
-				ath_print(common, ATH_DBG_EEPROM,
-					  "PDADC: Chain %d | PDADC %3d "
-					  "Value %3d | PDADC %3d Value %3d | "
-					  "PDADC %3d Value %3d | PDADC %3d "
-					  "Value %3d |\n",
-					  i, 4 * j, pdadcValues[4 * j],
-					  4 * j + 1, pdadcValues[4 * j + 1],
-					  4 * j + 2, pdadcValues[4 * j + 2],
-					  4 * j + 3,
-					  pdadcValues[4 * j + 3]);
+				ath_dbg(common, ATH_DBG_EEPROM,
+					"PDADC (%d,%4x): %4.4x %8.8x\n",
+					i, regChainOffset, regOffset,
+					reg32);
+				ath_dbg(common, ATH_DBG_EEPROM,
+					"PDADC: Chain %d | PDADC %3d "
+					"Value %3d | PDADC %3d Value %3d | "
+					"PDADC %3d Value %3d | PDADC %3d "
+					"Value %3d |\n",
+					i, 4 * j, pdadcValues[4 * j],
+					4 * j + 1, pdadcValues[4 * j + 1],
+					4 * j + 2, pdadcValues[4 * j + 2],
+					4 * j + 3, pdadcValues[4 * j + 3]);
 
 				regOffset += 4;
 			}
@@ -1316,8 +1315,8 @@ static void ath9k_hw_def_set_txpower(struct ath_hw *ah,
 		regulatory->max_power_level += INCREASE_MAXPOW_BY_THREE_CHAIN;
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_EEPROM,
-			  "Invalid chainmask configuration\n");
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_EEPROM,
+			"Invalid chainmask configuration\n");
 		break;
 	}
 
@@ -1458,17 +1457,17 @@ static u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
-		  "Getting spur idx %d is2Ghz. %d val %x\n",
-		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
+	ath_dbg(common, ATH_DBG_ANI,
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
+		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
 	case SPUR_DISABLE:
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
-			  "Getting spur val from new loc. %d\n", spur_val);
+		ath_dbg(common, ATH_DBG_ANI,
+			"Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
 		spur_val = EEP_DEF_SPURCHAN;
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 2b1b583..1337640 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -236,13 +236,13 @@ static void ath_detect_bt_priority(struct ath_softc *sc)
 		sc->sc_flags &= ~(SC_OP_BT_PRIORITY_DETECTED | SC_OP_BT_SCAN);
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
-				  "BT scan detected");
+			ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
+				"BT scan detected\n");
 			sc->sc_flags |= (SC_OP_BT_SCAN |
 					 SC_OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
-				  "BT priority traffic detected");
+			ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
+				"BT priority traffic detected\n");
 			sc->sc_flags |= SC_OP_BT_PRIORITY_DETECTED;
 		}
 
@@ -331,8 +331,8 @@ static void ath_btcoex_no_stomp_timer(void *arg)
 	struct ath_common *common = ath9k_hw_common(ah);
 	bool is_btscan = sc->sc_flags & SC_OP_BT_SCAN;
 
-	ath_print(common, ATH_DBG_BTCOEX,
-		  "no stomp timer running\n");
+	ath_dbg(common, ATH_DBG_BTCOEX,
+		"no stomp timer running\n");
 
 	spin_lock_bh(&btcoex->btcoex_lock);
 
@@ -378,8 +378,8 @@ void ath9k_btcoex_timer_resume(struct ath_softc *sc)
 	struct ath_btcoex *btcoex = &sc->btcoex;
 	struct ath_hw *ah = sc->sc_ah;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-		  "Starting btcoex timers");
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+		"Starting btcoex timers\n");
 
 	/* make sure duty cycle timer is also stopped when resuming */
 	if (btcoex->hw_timer_enabled)
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
index dd9514e..87cc65a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
@@ -123,11 +123,11 @@ static void ath9k_htc_beacon_config_sta(struct ath9k_htc_priv *priv,
 	/* TSF out of range threshold fixed at 1 second */
 	bs.bs_tsfoor_threshold = ATH9K_TSFOOR_THRESHOLD;
 
-	ath_print(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
-	ath_print(common, ATH_DBG_BEACON,
-		  "bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
-		  bs.bs_bmissthreshold, bs.bs_sleepduration,
-		  bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
+	ath_dbg(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
+	ath_dbg(common, ATH_DBG_BEACON,
+		"bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
+		bs.bs_bmissthreshold, bs.bs_sleepduration,
+		bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
 
 	/* Set the computed STA beacon timers */
 
@@ -154,9 +154,9 @@ static void ath9k_htc_beacon_config_adhoc(struct ath9k_htc_priv *priv,
 	if (priv->op_flags & OP_ENABLE_BEACON)
 		imask |= ATH9K_INT_SWBA;
 
-	ath_print(common, ATH_DBG_BEACON,
-		  "IBSS Beacon config, intval: %d, imask: 0x%x\n",
-		  bss_conf->beacon_interval, imask);
+	ath_dbg(common, ATH_DBG_BEACON,
+		"IBSS Beacon config, intval: %d, imask: 0x%x\n",
+		bss_conf->beacon_interval, imask);
 
 	WMI_CMD(WMI_DISABLE_INTR_CMDID);
 	ath9k_hw_beaconinit(priv->ah, nexttbtt, intval);
@@ -278,8 +278,8 @@ void ath9k_htc_beacon_config(struct ath9k_htc_priv *priv,
 		ath9k_htc_beacon_config_adhoc(priv, cur_conf);
 		break;
 	default:
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Unsupported beaconing mode\n");
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Unsupported beaconing mode\n");
 		return;
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
index 50eec9a..283ff97 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
@@ -20,13 +20,13 @@ static void ath_detect_bt_priority(struct ath9k_htc_priv *priv)
 		priv->op_flags &= ~(OP_BT_PRIORITY_DETECTED | OP_BT_SCAN);
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-				  "BT scan detected");
+			ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+				"BT scan detected\n");
 			priv->op_flags |= (OP_BT_SCAN |
 					 OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-				    "BT priority traffic detected");
+			ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+				"BT priority traffic detected\n");
 			priv->op_flags |= OP_BT_PRIORITY_DETECTED;
 		}
 
@@ -83,8 +83,8 @@ static void ath_btcoex_duty_cycle_work(struct work_struct *work)
 	struct ath_common *common = ath9k_hw_common(ah);
 	bool is_btscan = priv->op_flags & OP_BT_SCAN;
 
-	ath_print(common, ATH_DBG_BTCOEX,
-		  "time slice work for bt and wlan\n");
+	ath_dbg(common, ATH_DBG_BTCOEX,
+		"time slice work for bt and wlan\n");
 
 	if (btcoex->bt_stomp_type == ATH_BTCOEX_STOMP_LOW || is_btscan)
 		ath9k_cmn_btcoex_bt_stomp(common, ATH_BTCOEX_STOMP_NONE);
@@ -114,8 +114,7 @@ void ath_htc_resume_btcoex_work(struct ath9k_htc_priv *priv)
 	struct ath_btcoex *btcoex = &priv->btcoex;
 	struct ath_hw *ah = priv->ah;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-		  "Starting btcoex work");
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_BTCOEX, "Starting btcoex work\n");
 
 	btcoex->bt_priority_cnt = 0;
 	btcoex->bt_priority_time = jiffies;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 20b32f6..f89f663 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -288,9 +288,9 @@ static unsigned int ath9k_regread(void *hw_priv, u32 reg_offset)
 			  (u8 *) &val, sizeof(val),
 			  100);
 	if (unlikely(r)) {
-		ath_print(common, ATH_DBG_WMI,
-			  "REGISTER READ FAILED: (0x%04x, %d)\n",
-			   reg_offset, r);
+		ath_dbg(common, ATH_DBG_WMI,
+			"REGISTER READ FAILED: (0x%04x, %d)\n",
+			reg_offset, r);
 		return -EIO;
 	}
 
@@ -313,9 +313,9 @@ static void ath9k_regwrite_single(void *hw_priv, u32 val, u32 reg_offset)
 			  (u8 *) &val, sizeof(val),
 			  100);
 	if (unlikely(r)) {
-		ath_print(common, ATH_DBG_WMI,
-			  "REGISTER WRITE FAILED:(0x%04x, %d)\n",
-			  reg_offset, r);
+		ath_dbg(common, ATH_DBG_WMI,
+			"REGISTER WRITE FAILED:(0x%04x, %d)\n",
+			reg_offset, r);
 	}
 }
 
@@ -345,9 +345,9 @@ static void ath9k_regwrite_buffer(void *hw_priv, u32 val, u32 reg_offset)
 			  (u8 *) &rsp_status, sizeof(rsp_status),
 			  100);
 		if (unlikely(r)) {
-			ath_print(common, ATH_DBG_WMI,
-				  "REGISTER WRITE FAILED, multi len: %d\n",
-				  priv->wmi->multi_write_idx);
+			ath_dbg(common, ATH_DBG_WMI,
+				"REGISTER WRITE FAILED, multi len: %d\n",
+				priv->wmi->multi_write_idx);
 		}
 		priv->wmi->multi_write_idx = 0;
 	}
@@ -395,9 +395,9 @@ static void ath9k_regwrite_flush(void *hw_priv)
 			  (u8 *) &rsp_status, sizeof(rsp_status),
 			  100);
 		if (unlikely(r)) {
-			ath_print(common, ATH_DBG_WMI,
-				  "REGISTER WRITE FAILED, multi len: %d\n",
-				  priv->wmi->multi_write_idx);
+			ath_dbg(common, ATH_DBG_WMI,
+				"REGISTER WRITE FAILED, multi len: %d\n",
+				priv->wmi->multi_write_idx);
 		}
 		priv->wmi->multi_write_idx = 0;
 	}
@@ -469,9 +469,9 @@ static void setup_ht_cap(struct ath9k_htc_priv *priv,
 	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, 2);
 	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, 2);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "TX streams %d, RX streams: %d\n",
-		  tx_streams, rx_streams);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"TX streams %d, RX streams: %d\n",
+		tx_streams, rx_streams);
 
 	if (tx_streams != rx_streams) {
 		ht_info->mcs.tx_params |= IEEE80211_HT_MCS_TX_RX_DIFF;
@@ -537,9 +537,9 @@ static void ath9k_init_crypto(struct ath9k_htc_priv *priv)
 	/* Get the hardware key cache size. */
 	common->keymax = priv->ah->caps.keycache_size;
 	if (common->keymax > ATH_KEYMAX) {
-		ath_print(common, ATH_DBG_ANY,
-			  "Warning, using only %u entries in %u key cache\n",
-			  ATH_KEYMAX, common->keymax);
+		ath_dbg(common, ATH_DBG_ANY,
+			"Warning, using only %u entries in %u key cache\n",
+			ATH_KEYMAX, common->keymax);
 		common->keymax = ATH_KEYMAX;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index a8007af..87731c2 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -143,11 +143,11 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 	WMI_CMD(WMI_DRAIN_TXQ_ALL_CMDID);
 	WMI_CMD(WMI_STOP_RECV_CMDID);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "(%u MHz) -> (%u MHz), HT: %d, HT40: %d fastcc: %d\n",
-		  priv->ah->curchan->channel,
-		  channel->center_freq, conf_is_ht(conf), conf_is_ht40(conf),
-		  fastcc);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"(%u MHz) -> (%u MHz), HT: %d, HT40: %d fastcc: %d\n",
+		priv->ah->curchan->channel,
+		channel->center_freq, conf_is_ht(conf), conf_is_ht40(conf),
+		fastcc);
 
 	caldata = &priv->caldata[channel->hw_value];
 	ret = ath9k_hw_reset(ah, hchan, caldata, fastcc);
@@ -270,9 +270,9 @@ static int ath9k_htc_add_station(struct ath9k_htc_priv *priv,
 	}
 
 	if (sta)
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Added a station entry for: %pM (idx: %d)\n",
-			  sta->addr, tsta.sta_index);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Added a station entry for: %pM (idx: %d)\n",
+			sta->addr, tsta.sta_index);
 
 	priv->nstations++;
 	return 0;
@@ -304,9 +304,9 @@ static int ath9k_htc_remove_station(struct ath9k_htc_priv *priv,
 	}
 
 	if (sta)
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Removed a station entry for: %pM (idx: %d)\n",
-			  sta->addr, sta_idx);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Removed a station entry for: %pM (idx: %d)\n",
+			sta->addr, sta_idx);
 
 	priv->nstations--;
 	return 0;
@@ -409,9 +409,9 @@ static void ath9k_htc_init_rate(struct ath9k_htc_priv *priv,
 	ath9k_htc_setup_rate(priv, sta, &trate);
 	ret = ath9k_htc_send_rate_cmd(priv, &trate);
 	if (!ret)
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Updated target sta: %pM, rate caps: 0x%X\n",
-			  sta->addr, be32_to_cpu(trate.capflags));
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Updated target sta: %pM, rate caps: 0x%X\n",
+			sta->addr, be32_to_cpu(trate.capflags));
 }
 
 static void ath9k_htc_update_rate(struct ath9k_htc_priv *priv,
@@ -436,9 +436,9 @@ static void ath9k_htc_update_rate(struct ath9k_htc_priv *priv,
 
 	ret = ath9k_htc_send_rate_cmd(priv, &trate);
 	if (!ret)
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Updated target sta: %pM, rate caps: 0x%X\n",
-			  bss_conf->bssid, be32_to_cpu(trate.capflags));
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Updated target sta: %pM, rate caps: 0x%X\n",
+			bss_conf->bssid, be32_to_cpu(trate.capflags));
 }
 
 static int ath9k_htc_tx_aggr_oper(struct ath9k_htc_priv *priv,
@@ -465,14 +465,14 @@ static int ath9k_htc_tx_aggr_oper(struct ath9k_htc_priv *priv,
 
 	WMI_CMD_BUF(WMI_TX_AGGR_ENABLE_CMDID, &aggr);
 	if (ret)
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Unable to %s TX aggregation for (%pM, %d)\n",
-			  (aggr.aggr_enable) ? "start" : "stop", sta->addr, tid);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Unable to %s TX aggregation for (%pM, %d)\n",
+			(aggr.aggr_enable) ? "start" : "stop", sta->addr, tid);
 	else
-		ath_print(common, ATH_DBG_CONFIG,
-			  "%s TX aggregation for (%pM, %d)\n",
-			  (aggr.aggr_enable) ? "Starting" : "Stopping",
-			  sta->addr, tid);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"%s TX aggregation for (%pM, %d)\n",
+			(aggr.aggr_enable) ? "Starting" : "Stopping",
+			sta->addr, tid);
 
 	spin_lock_bh(&priv->tx_lock);
 	ista->tid_state[tid] = (aggr.aggr_enable && !ret) ? AGGR_START : AGGR_STOP;
@@ -725,7 +725,7 @@ void ath9k_ani_work(struct work_struct *work)
 	/* Long calibration runs independently of short calibration. */
 	if ((timestamp - common->ani.longcal_timer) >= ATH_LONG_CALINTERVAL) {
 		longcal = true;
-		ath_print(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
+		ath_dbg(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
 		common->ani.longcal_timer = timestamp;
 	}
 
@@ -734,8 +734,8 @@ void ath9k_ani_work(struct work_struct *work)
 		if ((timestamp - common->ani.shortcal_timer) >=
 		    short_cal_interval) {
 			shortcal = true;
-			ath_print(common, ATH_DBG_ANI,
-				  "shortcal @%lu\n", jiffies);
+			ath_dbg(common, ATH_DBG_ANI,
+				"shortcal @%lu\n", jiffies);
 			common->ani.shortcal_timer = timestamp;
 			common->ani.resetcal_timer = timestamp;
 		}
@@ -1125,15 +1125,15 @@ static int ath9k_htc_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	ret = ath9k_htc_tx_start(priv, skb);
 	if (ret != 0) {
 		if (ret == -ENOMEM) {
-			ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
-				  "Stopping TX queues\n");
+			ath_dbg(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+				"Stopping TX queues\n");
 			ieee80211_stop_queues(hw);
 			spin_lock_bh(&priv->tx_lock);
 			priv->tx_queues_stop = true;
 			spin_unlock_bh(&priv->tx_lock);
 		} else {
-			ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
-				  "Tx failed");
+			ath_dbg(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+				"Tx failed\n");
 		}
 		goto fail_tx;
 	}
@@ -1159,9 +1159,9 @@ static int ath9k_htc_start(struct ieee80211_hw *hw)
 
 	mutex_lock(&priv->mutex);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Starting driver with initial channel: %d MHz\n",
-		  curchan->center_freq);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Starting driver with initial channel: %d MHz\n",
+		curchan->center_freq);
 
 	/* Ensure that HW is awake before flushing RX */
 	ath9k_htc_setpower(priv, ATH9K_PM_AWAKE);
@@ -1224,7 +1224,7 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 	mutex_lock(&priv->mutex);
 
 	if (priv->op_flags & OP_INVALID) {
-		ath_print(common, ATH_DBG_ANY, "Device not present\n");
+		ath_dbg(common, ATH_DBG_ANY, "Device not present\n");
 		mutex_unlock(&priv->mutex);
 		return;
 	}
@@ -1246,8 +1246,8 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 		if (ath9k_htc_remove_monitor_interface(priv))
 			ath_err(common, "Unable to remove monitor interface\n");
 		else
-			ath_print(common, ATH_DBG_CONFIG,
-				  "Monitor interface removed\n");
+			ath_dbg(common, ATH_DBG_CONFIG,
+				"Monitor interface removed\n");
 	}
 
 	if (ah->btcoex_hw.enabled) {
@@ -1264,7 +1264,7 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 
 	priv->op_flags |= OP_INVALID;
 
-	ath_print(common, ATH_DBG_CONFIG, "Driver halt\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Driver halt\n");
 	mutex_unlock(&priv->mutex);
 }
 
@@ -1304,8 +1304,8 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Attach a VIF of type: %d\n", vif->type);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Attach a VIF of type: %d\n", vif->type);
 
 	priv->ah->opmode = vif->type;
 
@@ -1328,8 +1328,8 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 
 	ret = ath9k_htc_update_cap_target(priv);
 	if (ret)
-		ath_print(common, ATH_DBG_CONFIG, "Failed to update"
-			  " capability in target \n");
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Failed to update capability in target\n");
 
 	priv->vif = vif;
 out:
@@ -1349,7 +1349,7 @@ static void ath9k_htc_remove_interface(struct ieee80211_hw *hw,
 	int ret = 0;
 	u8 cmd_rsp;
 
-	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
 	mutex_lock(&priv->mutex);
 	ath9k_htc_ps_wakeup(priv);
@@ -1386,8 +1386,8 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		mutex_unlock(&priv->htc_pm_lock);
 
 		if (enable_radio) {
-			ath_print(common, ATH_DBG_CONFIG,
-				  "not-idle: enabling radio\n");
+			ath_dbg(common, ATH_DBG_CONFIG,
+				"not-idle: enabling radio\n");
 			ath9k_htc_setpower(priv, ATH9K_PM_AWAKE);
 			ath9k_htc_radio_enable(hw);
 		}
@@ -1397,8 +1397,8 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		struct ieee80211_channel *curchan = hw->conf.channel;
 		int pos = curchan->hw_value;
 
-		ath_print(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
-			  curchan->center_freq);
+		ath_dbg(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
+			curchan->center_freq);
 
 		ath9k_cmn_update_ichannel(&priv->ah->channels[pos],
 					  hw->conf.channel,
@@ -1427,8 +1427,8 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 			if (ath9k_htc_add_monitor_interface(priv))
 				ath_err(common, "Failed to set monitor mode\n");
 			else
-				ath_print(common, ATH_DBG_CONFIG,
-					  "HW opmode set to Monitor mode\n");
+				ath_dbg(common, ATH_DBG_CONFIG,
+					"HW opmode set to Monitor mode\n");
 		}
 	}
 
@@ -1440,8 +1440,8 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		}
 		mutex_unlock(&priv->htc_pm_lock);
 
-		ath_print(common, ATH_DBG_CONFIG,
-			  "idle: disabling radio\n");
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"idle: disabling radio\n");
 		ath9k_htc_radio_disable(hw);
 	}
 
@@ -1478,8 +1478,8 @@ static void ath9k_htc_configure_filter(struct ieee80211_hw *hw,
 	rfilt = ath9k_htc_calcrxfilter(priv);
 	ath9k_hw_setrxfilter(priv->ah, rfilt);
 
-	ath_print(ath9k_hw_common(priv->ah), ATH_DBG_CONFIG,
-		  "Set HW RX filter: 0x%x\n", rfilt);
+	ath_dbg(ath9k_hw_common(priv->ah), ATH_DBG_CONFIG,
+		"Set HW RX filter: 0x%x\n", rfilt);
 
 	ath9k_htc_ps_restore(priv);
 	mutex_unlock(&priv->mutex);
@@ -1542,11 +1542,10 @@ static int ath9k_htc_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	qnum = get_hw_qnum(queue, priv->hwq_map);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Configure tx [queue/hwq] [%d/%d],  "
-		  "aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
-		  queue, qnum, params->aifs, params->cw_min,
-		  params->cw_max, params->txop);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Configure tx [queue/hwq] [%d/%d],  aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
+		queue, qnum, params->aifs, params->cw_min,
+		params->cw_max, params->txop);
 
 	ret = ath_htc_txq_update(priv, qnum, &qi);
 	if (ret) {
@@ -1578,7 +1577,7 @@ static int ath9k_htc_set_key(struct ieee80211_hw *hw,
 		return -ENOSPC;
 
 	mutex_lock(&priv->mutex);
-	ath_print(common, ATH_DBG_CONFIG, "Set HW Key\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Set HW Key\n");
 	ath9k_htc_ps_wakeup(priv);
 
 	switch (cmd) {
@@ -1624,7 +1623,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	if (changed & BSS_CHANGED_ASSOC) {
 		common->curaid = bss_conf->assoc ?
 				 bss_conf->aid : 0;
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
 			bss_conf->assoc);
 
 		if (bss_conf->assoc) {
@@ -1641,9 +1640,9 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 		memcpy(common->curbssid, bss_conf->bssid, ETH_ALEN);
 		ath9k_hw_write_associd(ah);
 
-		ath_print(common, ATH_DBG_CONFIG,
-			  "BSSID: %pM aid: 0x%x\n",
-			  common->curbssid, common->curaid);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"BSSID: %pM aid: 0x%x\n",
+			common->curbssid, common->curaid);
 	}
 
 	if ((changed & BSS_CHANGED_BEACON_INT) ||
@@ -1661,8 +1660,8 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
-			  bss_conf->use_short_preamble);
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
+			bss_conf->use_short_preamble);
 		if (bss_conf->use_short_preamble)
 			priv->op_flags |= OP_PREAMBLE_SHORT;
 		else
@@ -1670,8 +1669,8 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
-			  bss_conf->use_cts_prot);
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
+			bss_conf->use_cts_prot);
 		if (bss_conf->use_cts_prot &&
 		    hw->conf.channel->band != IEEE80211_BAND_5GHZ)
 			priv->op_flags |= OP_PROTECT_ENABLE;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 5bef41f..31fad82 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -270,8 +270,8 @@ void ath9k_tx_tasklet(unsigned long data)
 	if (priv->tx_queues_stop) {
 		priv->tx_queues_stop = false;
 		spin_unlock_bh(&priv->tx_lock);
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
-			  "Waking up TX queues\n");
+		ath_dbg(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+			"Waking up TX queues\n");
 		ieee80211_wake_queues(priv->hw);
 		return;
 	}
@@ -681,8 +681,8 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_buff *skb,
 	spin_unlock(&priv->rx.rxbuflock);
 
 	if (rxbuf == NULL) {
-		ath_print(common, ATH_DBG_ANY,
-			  "No free RX buffer\n");
+		ath_dbg(common, ATH_DBG_ANY,
+			"No free RX buffer\n");
 		goto err;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 642de61..cf9b279 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -129,9 +129,9 @@ bool ath9k_hw_wait(struct ath_hw *ah, u32 reg, u32 mask, u32 val, u32 timeout)
 		udelay(AH_TIME_QUANTUM);
 	}
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_ANY,
-		  "timeout (%d us) on reg 0x%x: 0x%08x & 0x%08x != 0x%08x\n",
-		  timeout, reg, REG_READ(ah, reg), mask, val);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_ANY,
+		"timeout (%d us) on reg 0x%x: 0x%08x & 0x%08x != 0x%08x\n",
+		timeout, reg, REG_READ(ah, reg), mask, val);
 
 	return false;
 }
@@ -465,10 +465,10 @@ static int ath9k_hw_post_init(struct ath_hw *ah)
 	if (ecode != 0)
 		return ecode;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_CONFIG,
-		  "Eeprom VER: %d, REV: %d\n",
-		  ah->eep_ops->get_eeprom_ver(ah),
-		  ah->eep_ops->get_eeprom_rev(ah));
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_CONFIG,
+		"Eeprom VER: %d, REV: %d\n",
+		ah->eep_ops->get_eeprom_ver(ah),
+		ah->eep_ops->get_eeprom_rev(ah));
 
 	ecode = ath9k_hw_rf_alloc_ext_banks(ah);
 	if (ecode) {
@@ -530,7 +530,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_RESET, "serialize_regmode is %d\n",
+	ath_dbg(common, ATH_DBG_RESET, "serialize_regmode is %d\n",
 		ah->config.serialize_regmode);
 
 	if (AR_SREV_9285(ah) || AR_SREV_9271(ah))
@@ -758,8 +758,8 @@ static void ath9k_hw_set_cts_timeout(struct ath_hw *ah, u32 us)
 static bool ath9k_hw_set_global_txtimeout(struct ath_hw *ah, u32 tu)
 {
 	if (tu > 0xFFFF) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
-			  "bad global tx timeout %u\n", tu);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_XMIT,
+			"bad global tx timeout %u\n", tu);
 		ah->globaltxtimeout = (u32) -1;
 		return false;
 	} else {
@@ -776,8 +776,8 @@ void ath9k_hw_init_global_settings(struct ath_hw *ah)
 	int slottime;
 	int sifstime;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_RESET, "ah->misc_mode 0x%x\n",
-		  ah->misc_mode);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_RESET, "ah->misc_mode 0x%x\n",
+		ah->misc_mode);
 
 	if (ah->misc_mode != 0)
 		REG_WRITE(ah, AR_PCU_MISC,
@@ -1020,8 +1020,8 @@ static bool ath9k_hw_set_reset(struct ath_hw *ah, int type)
 
 	REG_WRITE(ah, AR_RTC_RC, 0);
 	if (!ath9k_hw_wait(ah, AR_RTC_RC, AR_RTC_RC_M, 0, AH_WAIT_TIMEOUT)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
-			  "RTC stuck in MAC reset\n");
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_RESET,
+			"RTC stuck in MAC reset\n");
 		return false;
 	}
 
@@ -1067,8 +1067,8 @@ static bool ath9k_hw_set_reset_power_on(struct ath_hw *ah)
 			   AR_RTC_STATUS_M,
 			   AR_RTC_STATUS_ON,
 			   AH_WAIT_TIMEOUT)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
-			  "RTC not waking up\n");
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_RESET,
+			"RTC not waking up\n");
 		return false;
 	}
 
@@ -1128,9 +1128,8 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 
 	for (qnum = 0; qnum < AR_NUM_QCU; qnum++) {
 		if (ath9k_hw_numtxpending(ah, qnum)) {
-			ath_print(common, ATH_DBG_QUEUE,
-				  "Transmit frames pending on "
-				  "queue %d\n", qnum);
+			ath_dbg(common, ATH_DBG_QUEUE,
+				"Transmit frames pending on queue %d\n", qnum);
 			return false;
 		}
 	}
@@ -1211,7 +1210,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	if (!ah->chip_fullsleep) {
 		ath9k_hw_abortpcurecv(ah);
 		if (!ath9k_hw_stopdmarecv(ah)) {
-			ath_print(common, ATH_DBG_XMIT,
+			ath_dbg(common, ATH_DBG_XMIT,
 				"Failed to stop receive dma\n");
 			bChannelChange = false;
 		}
@@ -1423,13 +1422,13 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 		u32 mask;
 		mask = REG_READ(ah, AR_CFG);
 		if (mask & (AR_CFG_SWRB | AR_CFG_SWTB | AR_CFG_SWRG)) {
-			ath_print(common, ATH_DBG_RESET,
+			ath_dbg(common, ATH_DBG_RESET,
 				"CFG Byte Swap Set 0x%x\n", mask);
 		} else {
 			mask =
 				INIT_CONFIG_STATUS | AR_CFG_SWRB | AR_CFG_SWTB;
 			REG_WRITE(ah, AR_CFG, mask);
-			ath_print(common, ATH_DBG_RESET,
+			ath_dbg(common, ATH_DBG_RESET,
 				"Setting CFG 0x%x\n", REG_READ(ah, AR_CFG));
 		}
 	} else {
@@ -1583,8 +1582,8 @@ bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode)
 	if (ah->power_mode == mode)
 		return status;
 
-	ath_print(common, ATH_DBG_RESET, "%s -> %s\n",
-		  modes[ah->power_mode], modes[mode]);
+	ath_dbg(common, ATH_DBG_RESET, "%s -> %s\n",
+		modes[ah->power_mode], modes[mode]);
 
 	switch (mode) {
 	case ATH9K_PM_AWAKE:
@@ -1657,9 +1656,9 @@ void ath9k_hw_beaconinit(struct ath_hw *ah, u32 next_beacon, u32 beacon_period)
 			flags |= AR_TBTT_TIMER_EN;
 			break;
 		}
-		ath_print(ath9k_hw_common(ah), ATH_DBG_BEACON,
-			  "%s: unsupported opmode: %d\n",
-			  __func__, ah->opmode);
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_BEACON,
+			"%s: unsupported opmode: %d\n",
+			__func__, ah->opmode);
 		return;
 		break;
 	}
@@ -1715,10 +1714,10 @@ void ath9k_hw_set_sta_beacon_timers(struct ath_hw *ah,
 	else
 		nextTbtt = bs->bs_nexttbtt;
 
-	ath_print(common, ATH_DBG_BEACON, "next DTIM %d\n", bs->bs_nextdtim);
-	ath_print(common, ATH_DBG_BEACON, "next beacon %d\n", nextTbtt);
-	ath_print(common, ATH_DBG_BEACON, "beacon period %d\n", beaconintval);
-	ath_print(common, ATH_DBG_BEACON, "DTIM period %d\n", dtimperiod);
+	ath_dbg(common, ATH_DBG_BEACON, "next DTIM %d\n", bs->bs_nextdtim);
+	ath_dbg(common, ATH_DBG_BEACON, "next beacon %d\n", nextTbtt);
+	ath_dbg(common, ATH_DBG_BEACON, "beacon period %d\n", beaconintval);
+	ath_dbg(common, ATH_DBG_BEACON, "DTIM period %d\n", dtimperiod);
 
 	ENABLE_REGWRITE_BUFFER(ah);
 
@@ -1783,8 +1782,8 @@ int ath9k_hw_fill_cap_info(struct ath_hw *ah)
 			regulatory->current_rd += 5;
 		else if (regulatory->current_rd == 0x41)
 			regulatory->current_rd = 0x43;
-		ath_print(common, ATH_DBG_REGULATORY,
-			  "regdomain mapped to 0x%x\n", regulatory->current_rd);
+		ath_dbg(common, ATH_DBG_REGULATORY,
+			"regdomain mapped to 0x%x\n", regulatory->current_rd);
 	}
 
 	eeval = ah->eep_ops->get_eeprom(ah, EEP_OP_MODE);
@@ -2244,8 +2243,8 @@ void ath9k_hw_reset_tsf(struct ath_hw *ah)
 {
 	if (!ath9k_hw_wait(ah, AR_SLP32_MODE, AR_SLP32_TSF_WRITE_STATUS, 0,
 			   AH_TSF_WRITE_TIMEOUT))
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
-			  "AR_SLP32_TSF_WRITE_STATUS limit exceeded\n");
+		ath_dbg(ath9k_hw_common(ah), ATH_DBG_RESET,
+			"AR_SLP32_TSF_WRITE_STATUS limit exceeded\n");
 
 	REG_WRITE(ah, AR_RESET_TSF, AR_RESET_TSF_ONCE);
 }
@@ -2366,9 +2365,9 @@ void ath9k_hw_gen_timer_start(struct ath_hw *ah,
 
 	tsf = ath9k_hw_gettsf32(ah);
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_HWTIMER,
-		  "curent tsf %x period %x"
-		  "timer_next %x\n", tsf, timer_period, timer_next);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_HWTIMER,
+		"current tsf %x period %x timer_next %x\n",
+		tsf, timer_period, timer_next);
 
 	/*
 	 * Pull timer_next forward if the current TSF already passed it
@@ -2448,8 +2447,8 @@ void ath_gen_timer_isr(struct ath_hw *ah)
 		index = rightmost_index(timer_table, &thresh_mask);
 		timer = timer_table->timers[index];
 		BUG_ON(!timer);
-		ath_print(common, ATH_DBG_HWTIMER,
-			  "TSF overflow for Gen timer %d\n", index);
+		ath_dbg(common, ATH_DBG_HWTIMER,
+			"TSF overflow for Gen timer %d\n", index);
 		timer->overflow(timer->arg);
 	}
 
@@ -2457,8 +2456,8 @@ void ath_gen_timer_isr(struct ath_hw *ah)
 		index = rightmost_index(timer_table, &trigger_mask);
 		timer = timer_table->timers[index];
 		BUG_ON(!timer);
-		ath_print(common, ATH_DBG_HWTIMER,
-			  "Gen timer[%d] trigger\n", index);
+		ath_dbg(common, ATH_DBG_HWTIMER,
+			"Gen timer[%d] trigger\n", index);
 		timer->trigger(timer->arg);
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 5fcfa48..ee0b1cf 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -30,7 +30,6 @@
 #include "btcoex.h"
 
 #include "../regd.h"
-#include "../debug.h"
 
 #define ATHEROS_VENDOR_ID	0x168c
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 3a40d49..19189a1 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -226,9 +226,9 @@ static void setup_ht_cap(struct ath_softc *sc,
 	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, max_streams);
 	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, max_streams);
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "TX streams %d, RX streams: %d\n",
-		  tx_streams, rx_streams);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"TX streams %d, RX streams: %d\n",
+		tx_streams, rx_streams);
 
 	if (tx_streams != rx_streams) {
 		ht_info->mcs.tx_params |= IEEE80211_HT_MCS_TX_RX_DIFF;
@@ -271,8 +271,8 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 	struct ath_buf *bf;
 	int i, bsize, error, desc_len;
 
-	ath_print(common, ATH_DBG_CONFIG, "%s DMA: %u buffers %u desc/buf\n",
-		  name, nbuf, ndesc);
+	ath_dbg(common, ATH_DBG_CONFIG, "%s DMA: %u buffers %u desc/buf\n",
+		name, nbuf, ndesc);
 
 	INIT_LIST_HEAD(head);
 
@@ -317,9 +317,9 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 		goto fail;
 	}
 	ds = (u8 *) dd->dd_desc;
-	ath_print(common, ATH_DBG_CONFIG, "%s DMA map: %p (%u) -> %llx (%u)\n",
-		  name, ds, (u32) dd->dd_desc_len,
-		  ito64(dd->dd_desc_paddr), /*XXX*/(u32) dd->dd_desc_len);
+	ath_dbg(common, ATH_DBG_CONFIG, "%s DMA map: %p (%u) -> %llx (%u)\n",
+		name, ds, (u32) dd->dd_desc_len,
+		ito64(dd->dd_desc_paddr), /*XXX*/(u32) dd->dd_desc_len);
 
 	/* allocate buffers */
 	bsize = sizeof(struct ath_buf) * nbuf;
@@ -373,9 +373,9 @@ static void ath9k_init_crypto(struct ath_softc *sc)
 	/* Get the hardware key cache size. */
 	common->keymax = sc->sc_ah->caps.keycache_size;
 	if (common->keymax > ATH_KEYMAX) {
-		ath_print(common, ATH_DBG_ANY,
-			  "Warning, using only %u entries in %u key cache\n",
-			  ATH_KEYMAX, common->keymax);
+		ath_dbg(common, ATH_DBG_ANY,
+			"Warning, using only %u entries in %u key cache\n",
+			ATH_KEYMAX, common->keymax);
 		common->keymax = ATH_KEYMAX;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 5c2781a..e3d2ebf 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -20,11 +20,11 @@
 static void ath9k_hw_set_txq_interrupts(struct ath_hw *ah,
 					struct ath9k_tx_queue_info *qi)
 {
-	ath_print(ath9k_hw_common(ah), ATH_DBG_INTERRUPT,
-		  "tx ok 0x%x err 0x%x desc 0x%x eol 0x%x urn 0x%x\n",
-		  ah->txok_interrupt_mask, ah->txerr_interrupt_mask,
-		  ah->txdesc_interrupt_mask, ah->txeol_interrupt_mask,
-		  ah->txurn_interrupt_mask);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_INTERRUPT,
+		"tx ok 0x%x err 0x%x desc 0x%x eol 0x%x urn 0x%x\n",
+		ah->txok_interrupt_mask, ah->txerr_interrupt_mask,
+		ah->txdesc_interrupt_mask, ah->txeol_interrupt_mask,
+		ah->txurn_interrupt_mask);
 
 	ENABLE_REGWRITE_BUFFER(ah);
 
@@ -56,8 +56,8 @@ EXPORT_SYMBOL(ath9k_hw_puttxbuf);
 
 void ath9k_hw_txstart(struct ath_hw *ah, u32 q)
 {
-	ath_print(ath9k_hw_common(ah), ATH_DBG_QUEUE,
-		  "Enable TXE on queue: %u\n", q);
+	ath_dbg(ath9k_hw_common(ah), ATH_DBG_QUEUE,
+		"Enable TXE on queue: %u\n", q);
 	REG_WRITE(ah, AR_Q_TXE, 1 << q);
 }
 EXPORT_SYMBOL(ath9k_hw_txstart);
@@ -154,15 +154,15 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 	u32 wait_time = ATH9K_TX_STOP_DMA_TIMEOUT / ATH9K_TIME_QUANTUM;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
-			  "invalid queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Stopping TX DMA, invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
-			  "inactive queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Stopping TX DMA, inactive queue: %u\n", q);
 		return false;
 	}
 
@@ -175,9 +175,9 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 	}
 
 	if (ath9k_hw_numtxpending(ah, q)) {
-		ath_print(common, ATH_DBG_QUEUE,
-			  "%s: Num of pending TX Frames %d on Q %d\n",
-			  __func__, ath9k_hw_numtxpending(ah, q), q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"%s: Num of pending TX Frames %d on Q %d\n",
+			__func__, ath9k_hw_numtxpending(ah, q), q);
 
 		for (j = 0; j < 2; j++) {
 			tsfLow = REG_READ(ah, AR_TSF_L32);
@@ -191,9 +191,9 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 			if ((REG_READ(ah, AR_TSF_L32) >> 10) == (tsfLow >> 10))
 				break;
 
-			ath_print(common, ATH_DBG_QUEUE,
-				  "TSF has moved while trying to set "
-				  "quiet time TSF: 0x%08x\n", tsfLow);
+			ath_dbg(common, ATH_DBG_QUEUE,
+				"TSF has moved while trying to set quiet time TSF: 0x%08x\n",
+				tsfLow);
 		}
 
 		REG_SET_BIT(ah, AR_DIAG_SW, AR_DIAG_FORCE_CH_IDLE_HIGH);
@@ -238,19 +238,19 @@ bool ath9k_hw_set_txq_props(struct ath_hw *ah, int q,
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Set TXQ properties, "
-			  "invalid queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Set TXQ properties, invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Set TXQ properties, "
-			  "inactive queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Set TXQ properties, inactive queue: %u\n", q);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Set queue properties for: %u\n", q);
+	ath_dbg(common, ATH_DBG_QUEUE, "Set queue properties for: %u\n", q);
 
 	qi->tqi_ver = qinfo->tqi_ver;
 	qi->tqi_subtype = qinfo->tqi_subtype;
@@ -309,15 +309,15 @@ bool ath9k_hw_get_txq_props(struct ath_hw *ah, int q,
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Get TXQ properties, "
-			  "invalid queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Get TXQ properties, invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Get TXQ properties, "
-			  "inactive queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Get TXQ properties, inactive queue: %u\n", q);
 		return false;
 	}
 
@@ -376,7 +376,7 @@ int ath9k_hw_setuptxqueue(struct ath_hw *ah, enum ath9k_tx_queue type,
 		return -1;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Setup TX queue: %u\n", q);
+	ath_dbg(common, ATH_DBG_QUEUE, "Setup TX queue: %u\n", q);
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type != ATH9K_TX_QUEUE_INACTIVE) {
@@ -412,18 +412,18 @@ bool ath9k_hw_releasetxqueue(struct ath_hw *ah, u32 q)
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Release TXQ, "
-			  "invalid queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Release TXQ, invalid queue: %u\n", q);
 		return false;
 	}
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Release TXQ, "
-			  "inactive queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Release TXQ, inactive queue: %u\n", q);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Release TX queue: %u\n", q);
+	ath_dbg(common, ATH_DBG_QUEUE, "Release TX queue: %u\n", q);
 
 	qi->tqi_type = ATH9K_TX_QUEUE_INACTIVE;
 	ah->txok_interrupt_mask &= ~(1 << q);
@@ -446,19 +446,19 @@ bool ath9k_hw_resettxqueue(struct ath_hw *ah, u32 q)
 	u32 cwMin, chanCwMin, value;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Reset TXQ, "
-			  "invalid queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Reset TXQ, invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Reset TXQ, "
-			  "inactive queue: %u\n", q);
+		ath_dbg(common, ATH_DBG_QUEUE,
+			"Reset TXQ, inactive queue: %u\n", q);
 		return true;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Reset TX queue: %u\n", q);
+	ath_dbg(common, ATH_DBG_QUEUE, "Reset TX queue: %u\n", q);
 
 	if (qi->tqi_cwmin == ATH9K_TXQ_USEDEFAULT) {
 		if (chan && IS_CHAN_B(chan))
@@ -838,7 +838,7 @@ void ath9k_hw_disable_interrupts(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_INTERRUPT, "disable IER\n");
+	ath_dbg(common, ATH_DBG_INTERRUPT, "disable IER\n");
 	REG_WRITE(ah, AR_IER, AR_IER_DISABLE);
 	(void) REG_READ(ah, AR_IER);
 	if (!AR_SREV_9100(ah)) {
@@ -858,7 +858,7 @@ void ath9k_hw_enable_interrupts(struct ath_hw *ah)
 	if (!(ah->imask & ATH9K_INT_GLOBAL))
 		return;
 
-	ath_print(common, ATH_DBG_INTERRUPT, "enable IER\n");
+	ath_dbg(common, ATH_DBG_INTERRUPT, "enable IER\n");
 	REG_WRITE(ah, AR_IER, AR_IER_ENABLE);
 	if (!AR_SREV_9100(ah)) {
 		REG_WRITE(ah, AR_INTR_ASYNC_ENABLE,
@@ -871,8 +871,8 @@ void ath9k_hw_enable_interrupts(struct ath_hw *ah)
 		REG_WRITE(ah, AR_INTR_SYNC_MASK,
 			  AR_INTR_SYNC_DEFAULT);
 	}
-	ath_print(common, ATH_DBG_INTERRUPT, "AR_IMR 0x%x IER 0x%x\n",
-		  REG_READ(ah, AR_IMR), REG_READ(ah, AR_IER));
+	ath_dbg(common, ATH_DBG_INTERRUPT, "AR_IMR 0x%x IER 0x%x\n",
+		REG_READ(ah, AR_IMR), REG_READ(ah, AR_IER));
 }
 EXPORT_SYMBOL(ath9k_hw_enable_interrupts);
 
@@ -886,7 +886,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 	if (!(ints & ATH9K_INT_GLOBAL))
 		ath9k_hw_enable_interrupts(ah);
 
-	ath_print(common, ATH_DBG_INTERRUPT, "0x%x => 0x%x\n", omask, ints);
+	ath_dbg(common, ATH_DBG_INTERRUPT, "0x%x => 0x%x\n", omask, ints);
 
 	/* TODO: global int Ref count */
 	mask = ints & ATH9K_INT_COMMON;
@@ -947,7 +947,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 			mask2 |= AR_IMR_S2_CST;
 	}
 
-	ath_print(common, ATH_DBG_INTERRUPT, "new IMR 0x%x\n", mask);
+	ath_dbg(common, ATH_DBG_INTERRUPT, "new IMR 0x%x\n", mask);
 	REG_WRITE(ah, AR_IMR, mask);
 	ah->imrs2_reg &= ~(AR_IMR_S2_TIM | AR_IMR_S2_DTIM | AR_IMR_S2_DTIMSYNC |
 			   AR_IMR_S2_CABEND | AR_IMR_S2_CABTO |
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index c7a7abf..a59cfce 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -260,11 +260,11 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	if (!(sc->sc_flags & SC_OP_OFFCHANNEL))
 		caldata = &aphy->caldata;
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "(%u MHz) -> (%u MHz), conf_is_ht40: %d fastcc: %d\n",
-		  sc->sc_ah->curchan->channel,
-		  channel->center_freq, conf_is_ht40(conf),
-		  fastcc);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"(%u MHz) -> (%u MHz), conf_is_ht40: %d fastcc: %d\n",
+		sc->sc_ah->curchan->channel,
+		channel->center_freq, conf_is_ht40(conf),
+		fastcc);
 
 	r = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (r) {
@@ -387,10 +387,9 @@ void ath_paprd_calibrate(struct work_struct *work)
 				msecs_to_jiffies(ATH_PAPRD_TIMEOUT));
 		sc->paprd_pending = false;
 		if (!time_left) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-				  "Timeout waiting for paprd training on "
-				  "TX chain %d\n",
-				  chain);
+			ath_dbg(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+				"Timeout waiting for paprd training on TX chain %d\n",
+				chain);
 			goto fail_paprd;
 		}
 
@@ -449,7 +448,7 @@ void ath_ani_calibrate(unsigned long data)
 	/* Long calibration runs independently of short calibration. */
 	if ((timestamp - common->ani.longcal_timer) >= long_cal_interval) {
 		longcal = true;
-		ath_print(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
+		ath_dbg(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
 		common->ani.longcal_timer = timestamp;
 	}
 
@@ -457,8 +456,8 @@ void ath_ani_calibrate(unsigned long data)
 	if (!common->ani.caldone) {
 		if ((timestamp - common->ani.shortcal_timer) >= short_cal_interval) {
 			shortcal = true;
-			ath_print(common, ATH_DBG_ANI,
-				  "shortcal @%lu\n", jiffies);
+			ath_dbg(common, ATH_DBG_ANI,
+				"shortcal @%lu\n", jiffies);
 			common->ani.shortcal_timer = timestamp;
 			common->ani.resetcal_timer = timestamp;
 		}
@@ -542,10 +541,10 @@ void ath_update_chainmask(struct ath_softc *sc, int is_ht)
 		common->rx_chainmask = 1;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "tx chmask: %d, rx chmask: %d\n",
-		  common->tx_chainmask,
-		  common->rx_chainmask);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"tx chmask: %d, rx chmask: %d\n",
+		common->tx_chainmask,
+		common->rx_chainmask);
 }
 
 static void ath_node_attach(struct ath_softc *sc, struct ieee80211_sta *sta)
@@ -641,8 +640,8 @@ void ath9k_tasklet(unsigned long data)
 		 * TSF sync does not look correct; remain awake to sync with
 		 * the next Beacon.
 		 */
-		ath_print(common, ATH_DBG_PS,
-			  "TSFOOR - Sync with next Beacon\n");
+		ath_dbg(common, ATH_DBG_PS,
+			"TSFOOR - Sync with next Beacon\n");
 		sc->ps_flags |= PS_WAIT_FOR_BEACON | PS_BEACON_SYNC;
 	}
 
@@ -840,9 +839,9 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	if (bss_conf->assoc) {
-		ath_print(common, ATH_DBG_CONFIG,
-			  "Bss Info ASSOC %d, bssid: %pM\n",
-			   bss_conf->aid, common->curbssid);
+		ath_dbg(common, ATH_DBG_CONFIG,
+			"Bss Info ASSOC %d, bssid: %pM\n",
+			bss_conf->aid, common->curbssid);
 
 		/* New association, store aid */
 		common->curaid = bss_conf->aid;
@@ -865,7 +864,7 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 		sc->sc_flags |= SC_OP_ANI_RUN;
 		ath_start_ani(common);
 	} else {
-		ath_print(common, ATH_DBG_CONFIG, "Bss Info DISASSOC\n");
+		ath_dbg(common, ATH_DBG_CONFIG, "Bss Info DISASSOC\n");
 		common->curaid = 0;
 		/* Stop ANI */
 		sc->sc_flags &= ~SC_OP_ANI_RUN;
@@ -1064,9 +1063,9 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	struct ath9k_channel *init_channel;
 	int r;
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Starting driver with initial channel: %d MHz\n",
-		  curchan->center_freq);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Starting driver with initial channel: %d MHz\n",
+		curchan->center_freq);
 
 	mutex_lock(&sc->mutex);
 
@@ -1196,9 +1195,9 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
 	if (aphy->state != ATH_WIPHY_ACTIVE && aphy->state != ATH_WIPHY_SCAN) {
-		ath_print(common, ATH_DBG_XMIT,
-			  "ath9k: %s: TX in unexpected wiphy state "
-			  "%d\n", wiphy_name(hw->wiphy), aphy->state);
+		ath_dbg(common, ATH_DBG_XMIT,
+			"ath9k: %s: TX in unexpected wiphy state %d\n",
+			wiphy_name(hw->wiphy), aphy->state);
 		goto exit;
 	}
 
@@ -1210,8 +1209,8 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 		if (ieee80211_is_data(hdr->frame_control) &&
 		    !ieee80211_is_nullfunc(hdr->frame_control) &&
 		    !ieee80211_has_pm(hdr->frame_control)) {
-			ath_print(common, ATH_DBG_PS, "Add PM=1 for a TX frame "
-				  "while in PS mode\n");
+			ath_dbg(common, ATH_DBG_PS,
+				"Add PM=1 for a TX frame while in PS mode\n");
 			hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PM);
 		}
 	}
@@ -1226,12 +1225,12 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 		if (!(sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_AUTOSLEEP))
 			ath9k_hw_setrxabort(sc->sc_ah, 0);
 		if (ieee80211_is_pspoll(hdr->frame_control)) {
-			ath_print(common, ATH_DBG_PS,
-				  "Sending PS-Poll to pick a buffered frame\n");
+			ath_dbg(common, ATH_DBG_PS,
+				"Sending PS-Poll to pick a buffered frame\n");
 			sc->ps_flags |= PS_WAIT_FOR_PSPOLL_DATA;
 		} else {
-			ath_print(common, ATH_DBG_PS,
-				  "Wake up to complete TX\n");
+			ath_dbg(common, ATH_DBG_PS,
+				"Wake up to complete TX\n");
 			sc->ps_flags |= PS_WAIT_FOR_TX_ACK;
 		}
 		/*
@@ -1245,10 +1244,10 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 	memset(&txctl, 0, sizeof(struct ath_tx_control));
 	txctl.txq = sc->tx.txq_map[skb_get_queue_mapping(skb)];
 
-	ath_print(common, ATH_DBG_XMIT, "transmitting packet, skb: %p\n", skb);
+	ath_dbg(common, ATH_DBG_XMIT, "transmitting packet, skb: %p\n", skb);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
-		ath_print(common, ATH_DBG_XMIT, "TX failed\n");
+		ath_dbg(common, ATH_DBG_XMIT, "TX failed\n");
 		goto exit;
 	}
 
@@ -1288,7 +1287,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 	}
 
 	if (sc->sc_flags & SC_OP_INVALID) {
-		ath_print(common, ATH_DBG_ANY, "Device not present\n");
+		ath_dbg(common, ATH_DBG_ANY, "Device not present\n");
 		mutex_unlock(&sc->mutex);
 		return;
 	}
@@ -1337,7 +1336,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	mutex_unlock(&sc->mutex);
 
-	ath_print(common, ATH_DBG_CONFIG, "Driver halt\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Driver halt\n");
 }
 
 static int ath9k_add_interface(struct ieee80211_hw *hw,
@@ -1376,8 +1375,8 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Attach a VIF of type: %d\n", ic_opmode);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Attach a VIF of type: %d\n", ic_opmode);
 
 	/* Set the VIF opmode */
 	avp->av_opmode = ic_opmode;
@@ -1433,7 +1432,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	bool bs_valid = false;
 	int i;
 
-	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
 	mutex_lock(&sc->mutex);
 
@@ -1548,8 +1547,8 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 		if (enable_radio) {
 			sc->ps_idle = false;
 			ath_radio_enable(sc, hw);
-			ath_print(common, ATH_DBG_CONFIG,
-				  "not-idle: enabling radio\n");
+			ath_dbg(common, ATH_DBG_CONFIG,
+				"not-idle: enabling radio\n");
 		}
 	}
 
@@ -1571,12 +1570,12 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 
 	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
 		if (conf->flags & IEEE80211_CONF_MONITOR) {
-			ath_print(common, ATH_DBG_CONFIG,
-				  "Monitor mode is enabled\n");
+			ath_dbg(common, ATH_DBG_CONFIG,
+				"Monitor mode is enabled\n");
 			sc->sc_ah->is_monitoring = true;
 		} else {
-			ath_print(common, ATH_DBG_CONFIG,
-				  "Monitor mode is disabled\n");
+			ath_dbg(common, ATH_DBG_CONFIG,
+				"Monitor mode is disabled\n");
 			sc->sc_ah->is_monitoring = false;
 		}
 	}
@@ -1608,8 +1607,8 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 			goto skip_chan_change;
 		}
 
-		ath_print(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
-			  curchan->center_freq);
+		ath_dbg(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
+			curchan->center_freq);
 
 		/* XXX: remove me eventualy */
 		ath9k_update_ichannel(sc, hw, &sc->sc_ah->channels[pos]);
@@ -1667,7 +1666,7 @@ skip_chan_change:
 	spin_unlock_bh(&sc->wiphy_lock);
 
 	if (disable_radio) {
-		ath_print(common, ATH_DBG_CONFIG, "idle: disabling radio\n");
+		ath_dbg(common, ATH_DBG_CONFIG, "idle: disabling radio\n");
 		sc->ps_idle = true;
 		ath_radio_disable(sc, hw);
 	}
@@ -1706,8 +1705,8 @@ static void ath9k_configure_filter(struct ieee80211_hw *hw,
 	ath9k_hw_setrxfilter(sc->sc_ah, rfilt);
 	ath9k_ps_restore(sc);
 
-	ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
-		  "Set HW RX filter: 0x%x\n", rfilt);
+	ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+		"Set HW RX filter: 0x%x\n", rfilt);
 }
 
 static int ath9k_sta_add(struct ieee80211_hw *hw,
@@ -1758,11 +1757,10 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 	qi.tqi_cwmax = params->cw_max;
 	qi.tqi_burstTime = params->txop;
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "Configure tx [queue/halq] [%d/%d],  "
-		  "aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
-		  queue, txq->axq_qnum, params->aifs, params->cw_min,
-		  params->cw_max, params->txop);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"Configure tx [queue/halq] [%d/%d], aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
+		queue, txq->axq_qnum, params->aifs, params->cw_min,
+		params->cw_max, params->txop);
 
 	ret = ath_txq_update(sc, txq->axq_qnum, &qi);
 	if (ret)
@@ -1793,7 +1791,7 @@ static int ath9k_set_key(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 	ath9k_ps_wakeup(sc);
-	ath_print(common, ATH_DBG_CONFIG, "Set HW Key\n");
+	ath_dbg(common, ATH_DBG_CONFIG, "Set HW Key\n");
 
 	switch (cmd) {
 	case SET_KEY:
@@ -1852,9 +1850,8 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 		if (vif->type == NL80211_IFTYPE_ADHOC)
 			ath_update_chainmask(sc, 0);
 
-		ath_print(common, ATH_DBG_CONFIG,
-			  "BSSID: %pM aid: 0x%x\n",
-			  common->curbssid, common->curaid);
+		ath_dbg(common, ATH_DBG_CONFIG, "BSSID: %pM aid: 0x%x\n",
+			common->curbssid, common->curaid);
 
 		/* need to reconfigure the beacon */
 		sc->sc_flags &= ~SC_OP_BEACONS ;
@@ -1910,8 +1907,8 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
-			  bss_conf->use_short_preamble);
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
+			bss_conf->use_short_preamble);
 		if (bss_conf->use_short_preamble)
 			sc->sc_flags |= SC_OP_PREAMBLE_SHORT;
 		else
@@ -1919,8 +1916,8 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
-			  bss_conf->use_cts_prot);
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
+			bss_conf->use_cts_prot);
 		if (bss_conf->use_cts_prot &&
 		    hw->conf.channel->band != IEEE80211_BAND_5GHZ)
 			sc->sc_flags |= SC_OP_PROTECT_ENABLE;
@@ -1929,7 +1926,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ASSOC) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
+		ath_dbg(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
 			bss_conf->assoc);
 		ath9k_bss_assoc_info(sc, hw, vif, bss_conf);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index d8dcaab..2061a75 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1184,7 +1184,7 @@ struct ath_rate_table *ath_choose_rate_table(struct ath_softc *sc,
 			return &ar5416_11na_ratetable;
 		return &ar5416_11a_ratetable;
 	default:
-		ath_print(common, ATH_DBG_CONFIG, "Invalid band\n");
+		ath_dbg(common, ATH_DBG_CONFIG, "Invalid band\n");
 		return NULL;
 	}
 }
@@ -1259,9 +1259,9 @@ static void ath_rc_init(struct ath_softc *sc,
 	ath_rc_priv->rate_max_phy = ath_rc_priv->valid_rate_index[k-4];
 	ath_rc_priv->rate_table = rate_table;
 
-	ath_print(common, ATH_DBG_CONFIG,
-		  "RC Initialized with capabilities: 0x%x\n",
-		  ath_rc_priv->ht_cap);
+	ath_dbg(common, ATH_DBG_CONFIG,
+		"RC Initialized with capabilities: 0x%x\n",
+		ath_rc_priv->ht_cap);
 }
 
 static u8 ath_rc_build_ht_caps(struct ath_softc *sc, struct ieee80211_sta *sta,
@@ -1463,9 +1463,9 @@ static void ath_rate_update(void *priv, struct ieee80211_supported_band *sband,
 						   oper_cw40, oper_sgi);
 			ath_rc_init(sc, priv_sta, sband, sta, rate_table);
 
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
-				  "Operating HT Bandwidth changed to: %d\n",
-				  sc->hw->conf.channel_type);
+			ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+				"Operating HT Bandwidth changed to: %d\n",
+				sc->hw->conf.channel_type);
 		}
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 803148a..2e5d570 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -165,7 +165,7 @@ static void ath_rx_addbuffer_edma(struct ath_softc *sc,
 	u32 nbuf = 0;
 
 	if (list_empty(&sc->rx.rxbuf)) {
-		ath_print(common, ATH_DBG_QUEUE, "No free rx buf available\n");
+		ath_dbg(common, ATH_DBG_QUEUE, "No free rx buf available\n");
 		return;
 	}
 
@@ -327,8 +327,8 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 		common->rx_bufsize = roundup(IEEE80211_MAX_MPDU_LEN,
 				min(common->cachelsz, (u16)64));
 
-		ath_print(common, ATH_DBG_CONFIG, "cachelsz %u rxbufsize %u\n",
-				common->cachelsz, common->rx_bufsize);
+		ath_dbg(common, ATH_DBG_CONFIG, "cachelsz %u rxbufsize %u\n",
+			common->cachelsz, common->rx_bufsize);
 
 		/* Initialize rx descriptors */
 
@@ -590,9 +590,8 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 
 	if (sc->ps_flags & PS_BEACON_SYNC) {
 		sc->ps_flags &= ~PS_BEACON_SYNC;
-		ath_print(common, ATH_DBG_PS,
-			  "Reconfigure Beacon timers based on "
-			  "timestamp from the AP\n");
+		ath_dbg(common, ATH_DBG_PS,
+			"Reconfigure Beacon timers based on timestamp from the AP\n");
 		ath_beacon_config(sc, NULL);
 	}
 
@@ -604,8 +603,8 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 		 * a backup trigger for returning into NETWORK SLEEP state,
 		 * so we are waiting for it as well.
 		 */
-		ath_print(common, ATH_DBG_PS, "Received DTIM beacon indicating "
-			  "buffered broadcast/multicast frame(s)\n");
+		ath_dbg(common, ATH_DBG_PS,
+			"Received DTIM beacon indicating buffered broadcast/multicast frame(s)\n");
 		sc->ps_flags |= PS_WAIT_FOR_CAB | PS_WAIT_FOR_BEACON;
 		return;
 	}
@@ -617,8 +616,8 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 		 * been delivered.
 		 */
 		sc->ps_flags &= ~PS_WAIT_FOR_CAB;
-		ath_print(common, ATH_DBG_PS,
-			  "PS wait for CAB frames timed out\n");
+		ath_dbg(common, ATH_DBG_PS,
+			"PS wait for CAB frames timed out\n");
 	}
 }
 
@@ -643,15 +642,14 @@ static void ath_rx_ps(struct ath_softc *sc, struct sk_buff *skb)
 		 * point.
 		 */
 		sc->ps_flags &= ~(PS_WAIT_FOR_CAB | PS_WAIT_FOR_BEACON);
-		ath_print(common, ATH_DBG_PS,
-			  "All PS CAB frames received, back to sleep\n");
+		ath_dbg(common, ATH_DBG_PS,
+			"All PS CAB frames received, back to sleep\n");
 	} else if ((sc->ps_flags & PS_WAIT_FOR_PSPOLL_DATA) &&
 		   !is_multicast_ether_addr(hdr->addr1) &&
 		   !ieee80211_has_morefrags(hdr->frame_control)) {
 		sc->ps_flags &= ~PS_WAIT_FOR_PSPOLL_DATA;
-		ath_print(common, ATH_DBG_PS,
-			  "Going back to sleep after having received "
-			  "PS-Poll data (0x%lx)\n",
+		ath_dbg(common, ATH_DBG_PS,
+			"Going back to sleep after having received PS-Poll data (0x%lx)\n",
 			sc->ps_flags & (PS_WAIT_FOR_BEACON |
 					PS_WAIT_FOR_CAB |
 					PS_WAIT_FOR_PSPOLL_DATA |
@@ -953,8 +951,9 @@ static int ath9k_process_rate(struct ath_common *common,
 	 * No valid hardware bitrate found -- we should not get here
 	 * because hardware has already validated this frame as OK.
 	 */
-	ath_print(common, ATH_DBG_XMIT, "unsupported hw bitrate detected "
-		  "0x%02x using 1 Mbit\n", rx_stats->rs_rate);
+	ath_dbg(common, ATH_DBG_XMIT,
+		"unsupported hw bitrate detected 0x%02x using 1 Mbit\n",
+		rx_stats->rs_rate);
 
 	return -EINVAL;
 }
diff --git a/drivers/net/wireless/ath/ath9k/virtual.c b/drivers/net/wireless/ath/ath9k/virtual.c
index d5442c3..fbfbc82 100644
--- a/drivers/net/wireless/ath/ath9k/virtual.c
+++ b/drivers/net/wireless/ath/ath9k/virtual.c
@@ -656,10 +656,9 @@ void ath9k_set_wiphy_idle(struct ath_wiphy *aphy, bool idle)
 	struct ath_softc *sc = aphy->sc;
 
 	aphy->idle = idle;
-	ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
-		  "Marking %s as %s\n",
-		  wiphy_name(aphy->hw->wiphy),
-		  idle ? "idle" : "not-idle");
+	ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+		"Marking %s as %sidle\n",
+		wiphy_name(aphy->hw->wiphy), idle ? "" : "not-");
 }
 /* Only bother starting a queue on an active virtual wiphy */
 bool ath_mac80211_start_queue(struct ath_softc *sc, u16 skb_queue)
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 93a8bda..8f42ea7 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -125,7 +125,7 @@ void ath9k_wmi_tasklet(unsigned long data)
 	struct ath9k_htc_priv *priv = (struct ath9k_htc_priv *)data;
 	struct ath_common *common = ath9k_hw_common(priv->ah);
 
-	ath_print(common, ATH_DBG_WMI, "SWBA Event received\n");
+	ath_dbg(common, ATH_DBG_WMI, "SWBA Event received\n");
 
 	ath9k_htc_swba(priv, priv->wmi->beacon_pending);
 
@@ -286,9 +286,9 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 
 	time_left = wait_for_completion_timeout(&wmi->cmd_wait, timeout);
 	if (!time_left) {
-		ath_print(common, ATH_DBG_WMI,
-			  "Timeout waiting for WMI command: %s\n",
-			  wmi_cmd_to_name(cmd_id));
+		ath_dbg(common, ATH_DBG_WMI,
+			"Timeout waiting for WMI command: %s\n",
+			wmi_cmd_to_name(cmd_id));
 		mutex_unlock(&wmi->op_mutex);
 		return -ETIMEDOUT;
 	}
@@ -298,8 +298,8 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 	return 0;
 
 out:
-	ath_print(common, ATH_DBG_WMI,
-		  "WMI failure for: %s\n", wmi_cmd_to_name(cmd_id));
+	ath_dbg(common, ATH_DBG_WMI,
+		"WMI failure for: %s\n", wmi_cmd_to_name(cmd_id));
 	mutex_unlock(&wmi->op_mutex);
 	kfree_skb(skb);
 
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index d26449c..16d83d0 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1285,8 +1285,8 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 
 	bf = list_first_entry(head, struct ath_buf, list);
 
-	ath_print(common, ATH_DBG_QUEUE,
-		  "qnum: %d, txq depth: %d\n", txq->axq_qnum, txq->axq_depth);
+	ath_dbg(common, ATH_DBG_QUEUE,
+		"qnum: %d, txq depth: %d\n", txq->axq_qnum, txq->axq_depth);
 
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
 		if (txq->axq_depth >= ATH_TXFIFO_DEPTH) {
@@ -1294,32 +1294,29 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 			return;
 		}
 		if (!list_empty(&txq->txq_fifo[txq->txq_headidx]))
-			ath_print(common, ATH_DBG_XMIT,
-				  "Initializing tx fifo %d which "
-				  "is non-empty\n",
-				  txq->txq_headidx);
+			ath_dbg(common, ATH_DBG_XMIT,
+				"Initializing tx fifo %d which is non-empty\n",
+				txq->txq_headidx);
 		INIT_LIST_HEAD(&txq->txq_fifo[txq->txq_headidx]);
 		list_splice_init(head, &txq->txq_fifo[txq->txq_headidx]);
 		INCR(txq->txq_headidx, ATH_TXFIFO_DEPTH);
 		ath9k_hw_puttxbuf(ah, txq->axq_qnum, bf->bf_daddr);
-		ath_print(common, ATH_DBG_XMIT,
-			  "TXDP[%u] = %llx (%p)\n",
-			  txq->axq_qnum, ito64(bf->bf_daddr), bf->bf_desc);
+		ath_dbg(common, ATH_DBG_XMIT, "TXDP[%u] = %llx (%p)\n",
+			txq->axq_qnum, ito64(bf->bf_daddr), bf->bf_desc);
 	} else {
 		list_splice_tail_init(head, &txq->axq_q);
 
 		if (txq->axq_link == NULL) {
 			ath9k_hw_puttxbuf(ah, txq->axq_qnum, bf->bf_daddr);
-			ath_print(common, ATH_DBG_XMIT,
-					"TXDP[%u] = %llx (%p)\n",
-					txq->axq_qnum, ito64(bf->bf_daddr),
-					bf->bf_desc);
+			ath_dbg(common, ATH_DBG_XMIT, "TXDP[%u] = %llx (%p)\n",
+				txq->axq_qnum, ito64(bf->bf_daddr),
+				bf->bf_desc);
 		} else {
 			*txq->axq_link = bf->bf_daddr;
-			ath_print(common, ATH_DBG_XMIT,
-					"link[%u] (%p)=%llx (%p)\n",
-					txq->axq_qnum, txq->axq_link,
-					ito64(bf->bf_daddr), bf->bf_desc);
+			ath_dbg(common, ATH_DBG_XMIT,
+				"link[%u] (%p)=%llx (%p)\n",
+				txq->axq_qnum, txq->axq_link,
+				ito64(bf->bf_daddr), bf->bf_desc);
 		}
 		ath9k_hw_get_desc_link(ah, bf->bf_lastbf->bf_desc,
 				       &txq->axq_link);
@@ -1646,7 +1643,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ieee80211_hw *hw,
 
 	bf = ath_tx_get_buffer(sc);
 	if (!bf) {
-		ath_print(common, ATH_DBG_XMIT, "TX buffers are full\n");
+		ath_dbg(common, ATH_DBG_XMIT, "TX buffers are full\n");
 		return NULL;
 	}
 
@@ -1809,7 +1806,7 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 	struct ieee80211_hdr * hdr = (struct ieee80211_hdr *)skb->data;
 	int q, padpos, padsize;
 
-	ath_print(common, ATH_DBG_XMIT, "TX complete: skb: %p\n", skb);
+	ath_dbg(common, ATH_DBG_XMIT, "TX complete: skb: %p\n", skb);
 
 	if (aphy)
 		hw = aphy->hw;
@@ -1835,9 +1832,8 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 
 	if (sc->ps_flags & PS_WAIT_FOR_TX_ACK) {
 		sc->ps_flags &= ~PS_WAIT_FOR_TX_ACK;
-		ath_print(common, ATH_DBG_PS,
-			  "Going back to sleep after having "
-			  "received TX status (0x%lx)\n",
+		ath_dbg(common, ATH_DBG_PS,
+			"Going back to sleep after having received TX status (0x%lx)\n",
 			sc->ps_flags & (PS_WAIT_FOR_BEACON |
 					PS_WAIT_FOR_CAB |
 					PS_WAIT_FOR_PSPOLL_DATA |
@@ -1986,9 +1982,9 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 	int status;
 	int qnum;
 
-	ath_print(common, ATH_DBG_QUEUE, "tx queue %d (%x), link %p\n",
-		  txq->axq_qnum, ath9k_hw_gettxbuf(sc->sc_ah, txq->axq_qnum),
-		  txq->axq_link);
+	ath_dbg(common, ATH_DBG_QUEUE, "tx queue %d (%x), link %p\n",
+		txq->axq_qnum, ath9k_hw_gettxbuf(sc->sc_ah, txq->axq_qnum),
+		txq->axq_link);
 
 	for (;;) {
 		spin_lock_bh(&txq->axq_lock);
@@ -2103,8 +2099,8 @@ static void ath_tx_complete_poll_work(struct work_struct *work)
 		}
 
 	if (needreset) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_RESET,
-			  "tx hung, resetting the chip\n");
+		ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_RESET,
+			"tx hung, resetting the chip\n");
 		ath9k_ps_wakeup(sc);
 		ath_reset(sc, true);
 		ath9k_ps_restore(sc);
@@ -2146,8 +2142,8 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 		if (status == -EINPROGRESS)
 			break;
 		if (status == -EIO) {
-			ath_print(common, ATH_DBG_XMIT,
-				  "Error processing tx status\n");
+			ath_dbg(common, ATH_DBG_XMIT,
+				"Error processing tx status\n");
 			break;
 		}
 
diff --git a/drivers/net/wireless/ath/debug.h b/drivers/net/wireless/ath/debug.h
deleted file mode 100644
index cec951c..0000000
--- a/drivers/net/wireless/ath/debug.h
+++ /dev/null
@@ -1,22 +0,0 @@
-/*
- * Copyright (c) 2008-2009 Atheros Communications Inc.
- *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
- *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
- */
-
-#ifndef ATH_DEBUG_H
-#define ATH_DEBUG_H
-
-#define ath_print ath_dbg
-
-#endif /* ATH_DEBUG_H */
diff --git a/drivers/net/wireless/ath/key.c b/drivers/net/wireless/ath/key.c
index 3a47695..29a2961 100644
--- a/drivers/net/wireless/ath/key.c
+++ b/drivers/net/wireless/ath/key.c
@@ -20,7 +20,6 @@
 
 #include "ath.h"
 #include "reg.h"
-#include "debug.h"
 
 #define REG_READ			(common->ops->read)
 #define REG_WRITE(_ah, _reg, _val)	(common->ops->write)(_ah, _val, _reg)
@@ -125,8 +124,8 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 		break;
 	case ATH_CIPHER_AES_CCM:
 		if (!(common->crypt_caps & ATH_CRYPT_CAP_CIPHER_AESCCM)) {
-			ath_print(common, ATH_DBG_ANY,
-				  "AES-CCM not supported by this mac rev\n");
+			ath_dbg(common, ATH_DBG_ANY,
+				"AES-CCM not supported by this mac rev\n");
 			return false;
 		}
 		keyType = AR_KEYTABLE_TYPE_CCM;
@@ -134,15 +133,15 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 	case ATH_CIPHER_TKIP:
 		keyType = AR_KEYTABLE_TYPE_TKIP;
 		if (entry + 64 >= common->keymax) {
-			ath_print(common, ATH_DBG_ANY,
-				  "entry %u inappropriate for TKIP\n", entry);
+			ath_dbg(common, ATH_DBG_ANY,
+				"entry %u inappropriate for TKIP\n", entry);
 			return false;
 		}
 		break;
 	case ATH_CIPHER_WEP:
 		if (k->kv_len < WLAN_KEY_LEN_WEP40) {
-			ath_print(common, ATH_DBG_ANY,
-				  "WEP key length %u too small\n", k->kv_len);
+			ath_dbg(common, ATH_DBG_ANY,
+				"WEP key length %u too small\n", k->kv_len);
 			return false;
 		}
 		if (k->kv_len <= WLAN_KEY_LEN_WEP40)
-- 
1.7.3.2.245.g03276.dirty
