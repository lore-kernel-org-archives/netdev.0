From: Joe Perches <joe@perches.com>
Subject: [PATCH 52/62] ath9k: Use static const
Date: Sat, 20 Nov 2010 18:38:53 -0800
Message-ID: <b81ca280ba06c62e869cbed7b72e91463883e42a.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  11161	     56	   2136	  13353	   3429	drivers/net/wireless/ath/ath9k/ar9003_paprd.o.new
  11167	     56	   2136	  13359	   342f	drivers/net/wireless/ath/ath9k/ar9003_paprd.o.old
  15428	     56	   3056	  18540	   486c	drivers/net/wireless/ath/ath9k/eeprom_4k.o.old
  15451	     56	   3056	  18563	   4883	drivers/net/wireless/ath/ath9k/eeprom_4k.o.new
  14087	     56	   2560	  16703	   413f	drivers/net/wireless/ath/ath9k/eeprom_9287.o.old
  14036	     56	   2560	  16652	   410c	drivers/net/wireless/ath/ath9k/eeprom_9287.o.new
  10041	     56	   2384	  12481	   30c1	drivers/net/wireless/ath/ath9k/ani.o.new
  10088	     56	   2384	  12528	   30f0	drivers/net/wireless/ath/ath9k/ani.o.old
   9316	   1580	   2304	  13200	   3390	drivers/net/wireless/ath/ath9k/htc_drv_init.o.new
   9316	   1580	   2304	  13200	   3390	drivers/net/wireless/ath/ath9k/htc_drv_init.o.old
  16483	     56	   3432	  19971	   4e03	drivers/net/wireless/ath/ath9k/ar9003_phy.o.new
  16517	     56	   3432	  20005	   4e25	drivers/net/wireless/ath/ath9k/ar9003_phy.o.old
  18221	    104	   2960	  21285	   5325	drivers/net/wireless/ath/ath9k/rc.o.old
  18203	    104	   2960	  21267	   5313	drivers/net/wireless/ath/ath9k/rc.o.new
  19985	     56	   4288	  24329	   5f09	drivers/net/wireless/ath/ath9k/eeprom_def.o.new
  20040	     56	   4288	  24384	   5f40	drivers/net/wireless/ath/ath9k/eeprom_def.o.old
  23997	     56	   4984	  29037	   716d	drivers/net/wireless/ath/ath9k/ar5008_phy.o.old
  23846	     56	   4984	  28886	   70d6	drivers/net/wireless/ath/ath9k/ar5008_phy.o.new
  24285	     56	   3184	  27525	   6b85	drivers/net/wireless/ath/ath9k/ar9003_eeprom.o.old
  24101	     56	   3184	  27341	   6acd	drivers/net/wireless/ath/ath9k/ar9003_eeprom.o.new
   6834	     56	   1032	   7922	   1ef2	drivers/net/wireless/ath/ath9k/ar9002_phy.o.old
   6780	     56	   1032	   7868	   1ebc	drivers/net/wireless/ath/ath9k/ar9002_phy.o.new
  36211	     64	   8624	  44899	   af63	drivers/net/wireless/ath/ath9k/hw.o.new
  36401	     64	   8624	  45089	   b021	drivers/net/wireless/ath/ath9k/hw.o.old
   9281	     56	   1496	  10833	   2a51	drivers/net/wireless/ath/ath9k/ar9003_calib.o.old
   9150	     56	   1496	  10702	   29ce	drivers/net/wireless/ath/ath9k/ar9003_calib.o.new

Use ARRAY_SIZE instead of a magic number.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/ani.c           |    8 +++---
 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |   32 ++++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9002_phy.c    |   12 +++++---
 drivers/net/wireless/ath/ath9k/ar9003_calib.c  |   10 +++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    8 +++--
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c  |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c     |   12 +++++---
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   14 +++++-----
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   17 +++++++-----
 drivers/net/wireless/ath/ath9k/htc_drv_init.c  |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c            |    9 +++---
 drivers/net/wireless/ath/ath9k/rc.c            |    6 ++--
 13 files changed, 74 insertions(+), 64 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index 63ccb39..29a045d 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -834,10 +834,10 @@ void ath9k_hw_ani_setup(struct ath_hw *ah)
 {
 	int i;
 
-	const int totalSizeDesired[] = { -55, -55, -55, -55, -62 };
-	const int coarseHigh[] = { -14, -14, -14, -14, -12 };
-	const int coarseLow[] = { -64, -64, -64, -64, -70 };
-	const int firpwr[] = { -78, -78, -78, -78, -80 };
+	static const int totalSizeDesired[] = { -55, -55, -55, -55, -62 };
+	static const int coarseHigh[] = { -14, -14, -14, -14, -12 };
+	static const int coarseLow[] = { -64, -64, -64, -64, -70 };
+	static const int firpwr[] = { -78, -78, -78, -78, -80 };
 
 	for (i = 0; i < 5; i++) {
 		ah->totalSizeDesired[i] = totalSizeDesired[i];
diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
index 7303d98..06e34d2 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -244,13 +244,15 @@ static void ar5008_hw_spur_mitigate(struct ath_hw *ah,
 	int upper, lower, cur_vit_mask;
 	int tmp, new;
 	int i;
-	int pilot_mask_reg[4] = { AR_PHY_TIMING7, AR_PHY_TIMING8,
-			  AR_PHY_PILOT_MASK_01_30, AR_PHY_PILOT_MASK_31_60
+	static int pilot_mask_reg[4] = {
+		AR_PHY_TIMING7, AR_PHY_TIMING8,
+		AR_PHY_PILOT_MASK_01_30, AR_PHY_PILOT_MASK_31_60
 	};
-	int chan_mask_reg[4] = { AR_PHY_TIMING9, AR_PHY_TIMING10,
-			 AR_PHY_CHANNEL_MASK_01_30, AR_PHY_CHANNEL_MASK_31_60
+	static int chan_mask_reg[4] = {
+		AR_PHY_TIMING9, AR_PHY_TIMING10,
+		AR_PHY_CHANNEL_MASK_01_30, AR_PHY_CHANNEL_MASK_31_60
 	};
-	int inc[4] = { 0, 100, 0, 0 };
+	static int inc[4] = { 0, 100, 0, 0 };
 
 	int8_t mask_m[123];
 	int8_t mask_p[123];
@@ -1084,12 +1086,12 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		break;
 	}
 	case ATH9K_ANI_OFDM_WEAK_SIGNAL_DETECTION:{
-		const int m1ThreshLow[] = { 127, 50 };
-		const int m2ThreshLow[] = { 127, 40 };
-		const int m1Thresh[] = { 127, 0x4d };
-		const int m2Thresh[] = { 127, 0x40 };
-		const int m2CountThr[] = { 31, 16 };
-		const int m2CountThrLow[] = { 63, 48 };
+		static const int m1ThreshLow[] = { 127, 50 };
+		static const int m2ThreshLow[] = { 127, 40 };
+		static const int m1Thresh[] = { 127, 0x4d };
+		static const int m2Thresh[] = { 127, 0x40 };
+		static const int m2CountThr[] = { 31, 16 };
+		static const int m2CountThrLow[] = { 63, 48 };
 		u32 on = param ? 1 : 0;
 
 		REG_RMW_FIELD(ah, AR_PHY_SFCORR_LOW,
@@ -1141,7 +1143,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		break;
 	}
 	case ATH9K_ANI_CCK_WEAK_SIGNAL_THR:{
-		const int weakSigThrCck[] = { 8, 6 };
+		static const int weakSigThrCck[] = { 8, 6 };
 		u32 high = param ? 1 : 0;
 
 		REG_RMW_FIELD(ah, AR_PHY_CCK_DETECT,
@@ -1157,7 +1159,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		break;
 	}
 	case ATH9K_ANI_FIRSTEP_LEVEL:{
-		const int firstep[] = { 0, 4, 8 };
+		static const int firstep[] = { 0, 4, 8 };
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep)) {
@@ -1178,7 +1180,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		break;
 	}
 	case ATH9K_ANI_SPUR_IMMUNITY_LEVEL:{
-		const int cycpwrThr1[] = { 2, 4, 6, 8, 10, 12, 14, 16 };
+		static const int cycpwrThr1[] = { 2, 4, 6, 8, 10, 12, 14, 16 };
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1)) {
@@ -1627,7 +1629,7 @@ static void ar5008_hw_set_radar_conf(struct ath_hw *ah)
 void ar5008_hw_attach_phy_ops(struct ath_hw *ah)
 {
 	struct ath_hw_private_ops *priv_ops = ath9k_hw_private_ops(ah);
-	const u32 ar5416_cca_regs[6] = {
+	static const u32 ar5416_cca_regs[6] = {
 		AR_PHY_CCA,
 		AR_PHY_CH1_CCA,
 		AR_PHY_CH2_CCA,
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_phy.c b/drivers/net/wireless/ath/ath9k/ar9002_phy.c
index 3fb97fd..7ae66a8 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_phy.c
@@ -175,13 +175,15 @@ static void ar9002_hw_spur_mitigate(struct ath_hw *ah,
 	int upper, lower, cur_vit_mask;
 	int tmp, newVal;
 	int i;
-	int pilot_mask_reg[4] = { AR_PHY_TIMING7, AR_PHY_TIMING8,
-			  AR_PHY_PILOT_MASK_01_30, AR_PHY_PILOT_MASK_31_60
+	static const int pilot_mask_reg[4] = {
+		AR_PHY_TIMING7, AR_PHY_TIMING8,
+		AR_PHY_PILOT_MASK_01_30, AR_PHY_PILOT_MASK_31_60
 	};
-	int chan_mask_reg[4] = { AR_PHY_TIMING9, AR_PHY_TIMING10,
-			 AR_PHY_CHANNEL_MASK_01_30, AR_PHY_CHANNEL_MASK_31_60
+	static const int chan_mask_reg[4] = {
+		AR_PHY_TIMING9, AR_PHY_TIMING10,
+		AR_PHY_CHANNEL_MASK_01_30, AR_PHY_CHANNEL_MASK_31_60
 	};
-	int inc[4] = { 0, 100, 0, 0 };
+	static const int inc[4] = { 0, 100, 0, 0 };
 	struct chan_centers centers;
 
 	int8_t mask_m[123];
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 32eed19..4c94c9e 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -196,7 +196,7 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 	u32 qCoffDenom, iCoffDenom;
 	int32_t qCoff, iCoff;
 	int iqCorrNeg, i;
-	const u_int32_t offset_array[3] = {
+	static const u_int32_t offset_array[3] = {
 		AR_PHY_RX_IQCAL_CORR_B0,
 		AR_PHY_RX_IQCAL_CORR_B1,
 		AR_PHY_RX_IQCAL_CORR_B2,
@@ -603,22 +603,22 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
-	const u32 txiqcal_status[AR9300_MAX_CHAINS] = {
+	static const u32 txiqcal_status[AR9300_MAX_CHAINS] = {
 		AR_PHY_TX_IQCAL_STATUS_B0,
 		AR_PHY_TX_IQCAL_STATUS_B1,
 		AR_PHY_TX_IQCAL_STATUS_B2,
 	};
-	const u32 tx_corr_coeff[AR9300_MAX_CHAINS] = {
+	static const u32 tx_corr_coeff[AR9300_MAX_CHAINS] = {
 		AR_PHY_TX_IQCAL_CORR_COEFF_01_B0,
 		AR_PHY_TX_IQCAL_CORR_COEFF_01_B1,
 		AR_PHY_TX_IQCAL_CORR_COEFF_01_B2,
 	};
-	const u32 rx_corr[AR9300_MAX_CHAINS] = {
+	static const u32 rx_corr[AR9300_MAX_CHAINS] = {
 		AR_PHY_RX_IQCAL_CORR_B0,
 		AR_PHY_RX_IQCAL_CORR_B1,
 		AR_PHY_RX_IQCAL_CORR_B2,
 	};
-	const u_int32_t chan_info_tab[] = {
+	static const u_int32_t chan_info_tab[] = {
 		AR_PHY_CHAN_INFO_TAB_0,
 		AR_PHY_CHAN_INFO_TAB_1,
 		AR_PHY_CHAN_INFO_TAB_2,
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 9a7e151..3161a59 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -4455,14 +4455,16 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 	int i;
 	int16_t  twiceLargestAntenna;
 	u16 scaledPower = 0, minCtlPower, maxRegAllowedPower;
-	u16 ctlModesFor11a[] = {
+	static const u16 ctlModesFor11a[] = {
 		CTL_11A, CTL_5GHT20, CTL_11A_EXT, CTL_5GHT40
 	};
-	u16 ctlModesFor11g[] = {
+	static const u16 ctlModesFor11g[] = {
 		CTL_11B, CTL_11G, CTL_2GHT20, CTL_11B_EXT,
 		CTL_11G_EXT, CTL_2GHT40
 	};
-	u16 numCtlModes, *pCtlMode, ctlMode, freq;
+	u16 numCtlModes;
+	const u16 *pCtlMode;
+	u16 ctlMode, freq;
 	struct chan_centers centers;
 	u8 *ctlIndex;
 	u8 ctlNum;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
index 716db41..850bc98 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -32,12 +32,12 @@ static void ar9003_paprd_setup_single_table(struct ath_hw *ah)
 {
 	struct ar9300_eeprom *eep = &ah->eeprom.ar9300_eep;
 	struct ar9300_modal_eep_header *hdr;
-	const u32 ctrl0[3] = {
+	static const u32 ctrl0[3] = {
 		AR_PHY_PAPRD_CTRL0_B0,
 		AR_PHY_PAPRD_CTRL0_B1,
 		AR_PHY_PAPRD_CTRL0_B2
 	};
-	const u32 ctrl1[3] = {
+	static const u32 ctrl1[3] = {
 		AR_PHY_PAPRD_CTRL1_B0,
 		AR_PHY_PAPRD_CTRL1_B1,
 		AR_PHY_PAPRD_CTRL1_B2
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index e8d6455..656d8ce 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -128,7 +128,7 @@ static int ar9003_hw_set_channel(struct ath_hw *ah, struct ath9k_channel *chan)
 static void ar9003_hw_spur_mitigate_mrc_cck(struct ath_hw *ah,
 					    struct ath9k_channel *chan)
 {
-	u32 spur_freq[4] = { 2420, 2440, 2464, 2480 };
+	static const u32 spur_freq[4] = { 2420, 2440, 2464, 2480 };
 	int cur_bb_spur, negative = 0, cck_spur_freq;
 	int i;
 
@@ -1161,7 +1161,7 @@ static void ar9003_hw_set_radar_conf(struct ath_hw *ah)
 void ar9003_hw_attach_phy_ops(struct ath_hw *ah)
 {
 	struct ath_hw_private_ops *priv_ops = ath9k_hw_private_ops(ah);
-	const u32 ar9300_cca_regs[6] = {
+	static const u32 ar9300_cca_regs[6] = {
 		AR_PHY_CCA_0,
 		AR_PHY_CCA_1,
 		AR_PHY_CCA_2,
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index c40c534..c2481b3 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -534,7 +534,9 @@ static void ath9k_hw_set_4k_power_per_rate_table(struct ath_hw *ah,
 	u16 twiceMinEdgePower;
 	u16 twiceMaxEdgePower = AR5416_MAX_RATE_POWER;
 	u16 scaledPower = 0, minCtlPower, maxRegAllowedPower;
-	u16 numCtlModes, *pCtlMode, ctlMode, freq;
+	u16 numCtlModes;
+	const u16 *pCtlMode;
+	u16 ctlMode, freq;
 	struct chan_centers centers;
 	struct cal_ctl_data_4k *rep;
 	struct ar5416_eeprom_4k *pEepData = &ah->eeprom.map4k;
@@ -550,10 +552,10 @@ static void ath9k_hw_set_4k_power_per_rate_table(struct ath_hw *ah,
 	struct cal_target_power_ht targetPowerHt20, targetPowerHt40 = {
 		0, {0, 0, 0, 0}
 	};
-	u16 ctlModesFor11g[] =
-		{ CTL_11B, CTL_11G, CTL_2GHT20, CTL_11B_EXT, CTL_11G_EXT,
-		  CTL_2GHT40
-		};
+	static const u16 ctlModesFor11g[] = {
+		CTL_11B, CTL_11G, CTL_2GHT20,
+		CTL_11B_EXT, CTL_11G_EXT, CTL_2GHT40
+	};
 
 	ath9k_hw_get_channel_centers(ah, chan, &centers);
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 3ad1de2..e756978 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -626,13 +626,13 @@ static void ath9k_hw_set_ar9287_power_per_rate_table(struct ath_hw *ah,
 	struct cal_target_power_ht targetPowerHt20,
 				    targetPowerHt40 = {0, {0, 0, 0, 0} };
 	u16 scaledPower = 0, minCtlPower, maxRegAllowedPower;
-	u16 ctlModesFor11g[] = {CTL_11B,
-				CTL_11G,
-				CTL_2GHT20,
-				CTL_11B_EXT,
-				CTL_11G_EXT,
-				CTL_2GHT40};
-	u16 numCtlModes = 0, *pCtlMode = NULL, ctlMode, freq;
+	static const u16 ctlModesFor11g[] = {
+		CTL_11B, CTL_11G, CTL_2GHT20,
+		CTL_11B_EXT, CTL_11G_EXT, CTL_2GHT40
+	};
+	u16 numCtlModes = 0;
+	const u16 *pCtlMode = NULL;
+	u16 ctlMode, freq;
 	struct chan_centers centers;
 	int tx_chainmask;
 	u16 twiceMinEdgePower;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index a819ddc..e94216e 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -1021,13 +1021,16 @@ static void ath9k_hw_set_def_power_per_rate_table(struct ath_hw *ah,
 		0, {0, 0, 0, 0}
 	};
 	u16 scaledPower = 0, minCtlPower, maxRegAllowedPower;
-	u16 ctlModesFor11a[] =
-		{ CTL_11A, CTL_5GHT20, CTL_11A_EXT, CTL_5GHT40 };
-	u16 ctlModesFor11g[] =
-		{ CTL_11B, CTL_11G, CTL_2GHT20, CTL_11B_EXT, CTL_11G_EXT,
-		  CTL_2GHT40
-		};
-	u16 numCtlModes, *pCtlMode, ctlMode, freq;
+	static const u16 ctlModesFor11a[] = {
+		CTL_11A, CTL_5GHT20, CTL_11A_EXT, CTL_5GHT40
+	};
+	static const u16 ctlModesFor11g[] = {
+		CTL_11B, CTL_11G, CTL_2GHT20,
+		CTL_11B_EXT, CTL_11G_EXT, CTL_2GHT40
+	};
+	u16 numCtlModes;
+	const u16 *pCtlMode;
+	u16 ctlMode, freq;
 	struct chan_centers centers;
 	int tx_chainmask;
 	u16 twiceMinEdgePower;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 7c8a38d..7f2704d 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -308,7 +308,7 @@ static void ath9k_regwrite_single(void *hw_priv, u32 val, u32 reg_offset)
 	struct ath_hw *ah = (struct ath_hw *) hw_priv;
 	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath9k_htc_priv *priv = (struct ath9k_htc_priv *) common->priv;
-	__be32 buf[2] = {
+	const __be32 buf[2] = {
 		cpu_to_be32(reg_offset),
 		cpu_to_be32(val),
 	};
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 1dbe53b..c6e971a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -310,10 +310,9 @@ static bool ath9k_hw_chip_test(struct ath_hw *ah)
 	struct ath_common *common = ath9k_hw_common(ah);
 	u32 regAddr[2] = { AR_STA_ID0 };
 	u32 regHold[2];
-	u32 patternData[4] = { 0x55555555,
-			       0xaaaaaaaa,
-			       0x66666666,
-			       0x99999999 };
+	static const u32 patternData[4] = {
+		0x55555555, 0xaaaaaaaa, 0x66666666, 0x99999999
+	};
 	int i, j, loop_max;
 
 	if (!AR_SREV_9300_20_OR_LATER(ah)) {
@@ -436,7 +435,7 @@ static int ath9k_hw_init_macaddr(struct ath_hw *ah)
 	u32 sum;
 	int i;
 	u16 eeval;
-	u32 EEP_MAC[] = { EEP_MAC_LSW, EEP_MAC_MID, EEP_MAC_MSW };
+	static const u32 EEP_MAC[] = { EEP_MAC_LSW, EEP_MAC_MID, EEP_MAC_MSW };
 
 	sum = 0;
 	for (i = 0; i < 3; i++) {
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 33bb33b..ee4566d 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -864,7 +864,7 @@ static bool ath_rc_update_per(struct ath_softc *sc,
 	bool state_change = false;
 	int count, n_bad_frames;
 	u8 last_per;
-	static u32 nretry_to_per_lookup[10] = {
+	static const u32 nretry_to_per_lookup[10] = {
 		100 * 0 / 1,
 		100 * 1 / 4,
 		100 * 1 / 2,
@@ -1087,13 +1087,13 @@ static int ath_rc_get_rateindex(const struct ath_rate_table *rate_table,
 				struct ieee80211_tx_rate *rate)
 {
 	int rix = 0, i = 0;
-	int mcs_rix_off[] = { 7, 15, 20, 21, 22, 23 };
+	static const int mcs_rix_off[] = { 7, 15, 20, 21, 22, 23 };
 
 	if (!(rate->flags & IEEE80211_TX_RC_MCS))
 		return rate->idx;
 
 	while (rate->idx > mcs_rix_off[i] &&
-	      i < sizeof(mcs_rix_off)/sizeof(int)) {
+	       i < ARRAY_SIZE(mcs_rix_off)) {
 		rix++; i++;
 	}
 
-- 
1.7.3.2.245.g03276.dirty
