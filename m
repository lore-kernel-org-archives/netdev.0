From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-08-06
Date: Fri, 6 Aug 2010 15:14:43 -0400
Message-ID: <20100806191443.GB2753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the first round of fixes intended for 2.6.36.  It is bigger than
I would prefer, but I hope you will still find it acceptable, especially
as we are still so early in the cycle.

The largest batch of fixes are from the ath9k team.  These are primarily
calibration fixes that they assure me fix some real connectivity
problems.  The patch from Luis fixes a potential regulatory compliance
issue as well.

The next largest batch is from the libertas guys.  This is necessary to
correct some association problems introduced by some of the patches
already sent for 2.6.36.

Also included are a couple of fixes for recently introduced build
warnings, a MAINTAINERS update, a PCI ID, and some minor adjustments to
some user-visible log SPAM.

The remainder are a variety of small fixes of varying significance.
This also includes a few Bluetooth fixes by way of Marcel Holtmann.
I think all of these are worthwhile to have merged at or before -rc1.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4b030d4288a569d6bdeca884d7f102d951f097f2:

  isdn: fix information leak (2010-08-05 13:21:25 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andy Lutomirski (1):
      iwlagn: Improve aggregation failure error messages

Christoph Fritz (1):
      wireless: ipw2100: check result of kzalloc()

Dan Williams (3):
      libertas: get the right # of scanned BSSes
      libertas: fix association with some APs by using extended rates
      libertas: scan before assocation if no BSSID was given

David Miller (1):
      Bluetooth: Use list_head for HCI blacklist head

Felix Fietkau (7):
      ath9k_hw: clean up and fix initial noise floor calibration
      ath9k_hw: fix periodic noise floor calibration on AR9003
      ath9k: fix a crash in the PA predistortion apply function
      ath9k_hw: fix analog shift register writes on AR9003
      ath9k: prevent calibration during off-channel activity
      ath9k_hw: clean up per-channel calibration data
      ath9k_hw: fix a noise floor calibration related race condition

Gustavo F. Padovan (2):
      Bluetooth: Remove __exit from rfcomm_cleanup_ttys()
      Bluetooth: Don't send RFC for Basic Mode if only it is supported

Jan Friedrich (1):
      ath9k: fix erased ieee80211_rx_status.mactime

Johannes Berg (5):
      iwlwifi: fix possible recursive locking deadlock
      mac80211: fix scan locking wrt. hw scan
      iwlwifi: fix compile warning
      iwlwifi: fix TX tracer
      iwlwifi: fix locking assertions

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-next-2.6
      rtl8180: avoid potential NULL deref in rtl8180_beacon_work

Juuso Oikarinen (1):
      mac80211: Fix compilation warning when CONFIG_INET is not set

Kulikov Vasiliy (2):
      net: wl12xx: do not use kfree'd memory
      rt2x00: do not use PCI resources before pci_enable_device()

Larry Finger (1):
      p54pci: Add PCI ID for SMC2802W

Lorenzo Bianconi (1):
      ath9k: fix an issue in ath_atx_tid paused flag management

Luis R. Rodriguez (1):
      ath9k_hw: Fix regulatory CTL index usage for AR9003

Sujith (1):
      ath9k: Remove myself from the MAINTAINERS list

Ville Tervo (1):
      Bluetooth: Check result code of L2CAP information response

Wey-Yi Guy (2):
      iwlwifi: BA scd_flow not match condition detected
      iwlagn: fix typo in ucode_bt_stats_read debugfs

 MAINTAINERS                                    |    1 -
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |   43 ++-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c  |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |  388 +++++++++++++++++++++++-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c  |   17 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h         |    3 +-
 drivers/net/wireless/ath/ath9k/calib.c         |  118 ++++----
 drivers/net/wireless/ath/ath9k/calib.h         |    8 +-
 drivers/net/wireless/ath/ath9k/htc.h           |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   10 +-
 drivers/net/wireless/ath/ath9k/hw.c            |   25 +-
 drivers/net/wireless/ath/ath9k/hw.h            |   25 +-
 drivers/net/wireless/ath/ath9k/main.c          |  104 ++++---
 drivers/net/wireless/ath/ath9k/recv.c          |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   36 +--
 drivers/net/wireless/ipw2x00/ipw2100.c         |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c         |    6 +-
 drivers/net/wireless/libertas/cfg.c            |  214 ++++++++++---
 drivers/net/wireless/libertas/dev.h            |    5 +
 drivers/net/wireless/libertas/main.c           |    1 +
 drivers/net/wireless/p54/p54pci.c              |    2 +
 drivers/net/wireless/rt2x00/rt2x00pci.c        |   21 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    2 +
 drivers/net/wireless/wl12xx/wl1271_spi.c       |    3 +-
 include/net/bluetooth/hci_core.h               |    2 +-
 net/bluetooth/hci_core.c                       |    2 +-
 net/bluetooth/hci_sock.c                       |    8 +-
 net/bluetooth/hci_sysfs.c                      |    3 +-
 net/bluetooth/l2cap.c                          |   24 ++-
 net/bluetooth/rfcomm/tty.c                     |    2 +-
 net/mac80211/main.c                            |    2 +
 net/mac80211/scan.c                            |   14 -
 41 files changed, 866 insertions(+), 301 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index b04b97f..1dcedaa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1085,7 +1085,6 @@ F:	drivers/net/wireless/ath/ath5k/
 ATHEROS ATH9K WIRELESS DRIVER
 M:	"Luis R. Rodriguez" <lrodriguez@atheros.com>
 M:	Jouni Malinen <jmalinen@atheros.com>
-M:	Sujith Manoharan <Sujith.Manoharan@atheros.com>
 M:	Vasanthakumar Thiagarajan <vasanth@atheros.com>
 M:	Senthil Balasubramanian <senthilkumar@atheros.com>
 L:	linux-wireless@vger.kernel.org
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index dabafb8..fe7418a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -63,6 +63,7 @@ static bool ar9002_hw_per_calibration(struct ath_hw *ah,
 				      u8 rxchainmask,
 				      struct ath9k_cal_list *currCal)
 {
+	struct ath9k_hw_cal_data *caldata = ah->caldata;
 	bool iscaldone = false;
 
 	if (currCal->calState == CAL_RUNNING) {
@@ -81,14 +82,14 @@ static bool ar9002_hw_per_calibration(struct ath_hw *ah,
 				}
 
 				currCal->calData->calPostProc(ah, numChains);
-				ichan->CalValid |= currCal->calData->calType;
+				caldata->CalValid |= currCal->calData->calType;
 				currCal->calState = CAL_DONE;
 				iscaldone = true;
 			} else {
 				ar9002_hw_setup_calibration(ah, currCal);
 			}
 		}
-	} else if (!(ichan->CalValid & currCal->calData->calType)) {
+	} else if (!(caldata->CalValid & currCal->calData->calType)) {
 		ath9k_hw_reset_calibration(ah, currCal);
 	}
 
@@ -686,8 +687,13 @@ static bool ar9002_hw_calibrate(struct ath_hw *ah,
 {
 	bool iscaldone = true;
 	struct ath9k_cal_list *currCal = ah->cal_list_curr;
+	bool nfcal, nfcal_pending = false;
 
-	if (currCal &&
+	nfcal = !!(REG_READ(ah, AR_PHY_AGC_CONTROL) & AR_PHY_AGC_CONTROL_NF);
+	if (ah->caldata)
+		nfcal_pending = ah->caldata->nfcal_pending;
+
+	if (currCal && !nfcal &&
 	    (currCal->calState == CAL_RUNNING ||
 	     currCal->calState == CAL_WAITING)) {
 		iscaldone = ar9002_hw_per_calibration(ah, chan,
@@ -703,7 +709,7 @@ static bool ar9002_hw_calibrate(struct ath_hw *ah,
 	}
 
 	/* Do NF cal only at longer intervals */
-	if (longcal) {
+	if (longcal || nfcal_pending) {
 		/* Do periodic PAOffset Cal */
 		ar9002_hw_pa_cal(ah, false);
 		ar9002_hw_olc_temp_compensation(ah);
@@ -712,16 +718,18 @@ static bool ar9002_hw_calibrate(struct ath_hw *ah,
 		 * Get the value from the previous NF cal and update
 		 * history buffer.
 		 */
-		ath9k_hw_getnf(ah, chan);
-
-		/*
-		 * Load the NF from history buffer of the current channel.
-		 * NF is slow time-variant, so it is OK to use a historical
-		 * value.
-		 */
-		ath9k_hw_loadnf(ah, ah->curchan);
+		if (ath9k_hw_getnf(ah, chan)) {
+			/*
+			 * Load the NF from history buffer of the current
+			 * channel.
+			 * NF is slow time-variant, so it is OK to use a
+			 * historical value.
+			 */
+			ath9k_hw_loadnf(ah, ah->curchan);
+		}
 
-		ath9k_hw_start_nfcal(ah);
+		if (longcal)
+			ath9k_hw_start_nfcal(ah, false);
 	}
 
 	return iscaldone;
@@ -869,8 +877,10 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 	ar9002_hw_pa_cal(ah, true);
 
 	/* Do NF Calibration after DC offset and other calibrations */
-	REG_WRITE(ah, AR_PHY_AGC_CONTROL,
-		  REG_READ(ah, AR_PHY_AGC_CONTROL) | AR_PHY_AGC_CONTROL_NF);
+	ath9k_hw_start_nfcal(ah, true);
+
+	if (ah->caldata)
+		ah->caldata->nfcal_pending = true;
 
 	ah->cal_list = ah->cal_list_last = ah->cal_list_curr = NULL;
 
@@ -901,7 +911,8 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 			ath9k_hw_reset_calibration(ah, ah->cal_list_curr);
 	}
 
-	chan->CalValid = 0;
+	if (ah->caldata)
+		ah->caldata->CalValid = 0;
 
 	return true;
 }
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 5a06503..4674ea8 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -68,6 +68,7 @@ static bool ar9003_hw_per_calibration(struct ath_hw *ah,
 				      u8 rxchainmask,
 				      struct ath9k_cal_list *currCal)
 {
+	struct ath9k_hw_cal_data *caldata = ah->caldata;
 	/* Cal is assumed not done until explicitly set below */
 	bool iscaldone = false;
 
@@ -95,7 +96,7 @@ static bool ar9003_hw_per_calibration(struct ath_hw *ah,
 				currCal->calData->calPostProc(ah, numChains);
 
 				/* Calibration has finished. */
-				ichan->CalValid |= currCal->calData->calType;
+				caldata->CalValid |= currCal->calData->calType;
 				currCal->calState = CAL_DONE;
 				iscaldone = true;
 			} else {
@@ -106,7 +107,7 @@ static bool ar9003_hw_per_calibration(struct ath_hw *ah,
 			ar9003_hw_setup_calibration(ah, currCal);
 			}
 		}
-	} else if (!(ichan->CalValid & currCal->calData->calType)) {
+	} else if (!(caldata->CalValid & currCal->calData->calType)) {
 		/* If current cal is marked invalid in channel, kick it off */
 		ath9k_hw_reset_calibration(ah, currCal);
 	}
@@ -149,6 +150,12 @@ static bool ar9003_hw_calibrate(struct ath_hw *ah,
 	/* Do NF cal only at longer intervals */
 	if (longcal) {
 		/*
+		 * Get the value from the previous NF cal and update
+		 * history buffer.
+		 */
+		ath9k_hw_getnf(ah, chan);
+
+		/*
 		 * Load the NF from history buffer of the current channel.
 		 * NF is slow time-variant, so it is OK to use a historical
 		 * value.
@@ -156,7 +163,7 @@ static bool ar9003_hw_calibrate(struct ath_hw *ah,
 		ath9k_hw_loadnf(ah, ah->curchan);
 
 		/* start NF calibration, without updating BB NF register */
-		ath9k_hw_start_nfcal(ah);
+		ath9k_hw_start_nfcal(ah, false);
 	}
 
 	return iscaldone;
@@ -762,6 +769,8 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	/* Revert chainmasks to their original values before NF cal */
 	ar9003_hw_set_chain_masks(ah, ah->rxchainmask, ah->txchainmask);
 
+	ath9k_hw_start_nfcal(ah, true);
+
 	/* Initialize list pointers */
 	ah->cal_list = ah->cal_list_last = ah->cal_list_curr = NULL;
 
@@ -785,7 +794,8 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	if (ah->cal_list_curr)
 		ath9k_hw_reset_calibration(ah, ah->cal_list_curr);
 
-	chan->CalValid = 0;
+	if (ah->caldata)
+		ah->caldata->CalValid = 0;
 
 	return true;
 }
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index ace8d26..b883b17 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -41,6 +41,20 @@
 #define LE16(x) __constant_cpu_to_le16(x)
 #define LE32(x) __constant_cpu_to_le32(x)
 
+/* Local defines to distinguish between extension and control CTL's */
+#define EXT_ADDITIVE (0x8000)
+#define CTL_11A_EXT (CTL_11A | EXT_ADDITIVE)
+#define CTL_11G_EXT (CTL_11G | EXT_ADDITIVE)
+#define CTL_11B_EXT (CTL_11B | EXT_ADDITIVE)
+#define REDUCE_SCALED_POWER_BY_TWO_CHAIN     6  /* 10*log10(2)*2 */
+#define REDUCE_SCALED_POWER_BY_THREE_CHAIN   9  /* 10*log10(3)*2 */
+#define PWRINCR_3_TO_1_CHAIN      9             /* 10*log(3)*2 */
+#define PWRINCR_3_TO_2_CHAIN      3             /* floor(10*log(3/2)*2) */
+#define PWRINCR_2_TO_1_CHAIN      6             /* 10*log(2)*2 */
+
+#define SUB_NUM_CTL_MODES_AT_5G_40 2    /* excluding HT40, EXT-OFDM */
+#define SUB_NUM_CTL_MODES_AT_2G_40 3    /* excluding HT40, EXT-OFDM, EXT-CCK */
+
 static const struct ar9300_eeprom ar9300_default = {
 	.eepromVersion = 2,
 	.templateVersion = 2,
@@ -609,6 +623,14 @@ static const struct ar9300_eeprom ar9300_default = {
 	 }
 };
 
+static u16 ath9k_hw_fbin2freq(u8 fbin, bool is2GHz)
+{
+	if (fbin == AR9300_BCHAN_UNUSED)
+		return fbin;
+
+	return (u16) ((is2GHz) ? (2300 + fbin) : (4800 + 5 * fbin));
+}
+
 static int ath9k_hw_ar9300_check_eeprom(struct ath_hw *ah)
 {
 	return 0;
@@ -1417,9 +1439,9 @@ static int ar9003_hw_tx_power_regwrite(struct ath_hw *ah, u8 * pPwrArray)
 #undef POW_SM
 }
 
-static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq)
+static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
+					      u8 *targetPowerValT2)
 {
-	u8 targetPowerValT2[ar9300RateSize];
 	/* XXX: hard code for now, need to get from eeprom struct */
 	u8 ht40PowerIncForPdadc = 0;
 	bool is2GHz = false;
@@ -1553,9 +1575,6 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq)
 			  "TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
 		i++;
 	}
-
-	/* Write target power array to registers */
-	ar9003_hw_tx_power_regwrite(ah, targetPowerValT2);
 }
 
 static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
@@ -1799,14 +1818,369 @@ static int ar9003_hw_calibration_apply(struct ath_hw *ah, int frequency)
 	return 0;
 }
 
+static u16 ar9003_hw_get_direct_edge_power(struct ar9300_eeprom *eep,
+					   int idx,
+					   int edge,
+					   bool is2GHz)
+{
+	struct cal_ctl_data_2g *ctl_2g = eep->ctlPowerData_2G;
+	struct cal_ctl_data_5g *ctl_5g = eep->ctlPowerData_5G;
+
+	if (is2GHz)
+		return ctl_2g[idx].ctlEdges[edge].tPower;
+	else
+		return ctl_5g[idx].ctlEdges[edge].tPower;
+}
+
+static u16 ar9003_hw_get_indirect_edge_power(struct ar9300_eeprom *eep,
+					     int idx,
+					     unsigned int edge,
+					     u16 freq,
+					     bool is2GHz)
+{
+	struct cal_ctl_data_2g *ctl_2g = eep->ctlPowerData_2G;
+	struct cal_ctl_data_5g *ctl_5g = eep->ctlPowerData_5G;
+
+	u8 *ctl_freqbin = is2GHz ?
+		&eep->ctl_freqbin_2G[idx][0] :
+		&eep->ctl_freqbin_5G[idx][0];
+
+	if (is2GHz) {
+		if (ath9k_hw_fbin2freq(ctl_freqbin[edge - 1], 1) < freq &&
+		    ctl_2g[idx].ctlEdges[edge - 1].flag)
+			return ctl_2g[idx].ctlEdges[edge - 1].tPower;
+	} else {
+		if (ath9k_hw_fbin2freq(ctl_freqbin[edge - 1], 0) < freq &&
+		    ctl_5g[idx].ctlEdges[edge - 1].flag)
+			return ctl_5g[idx].ctlEdges[edge - 1].tPower;
+	}
+
+	return AR9300_MAX_RATE_POWER;
+}
+
+/*
+ * Find the maximum conformance test limit for the given channel and CTL info
+ */
+static u16 ar9003_hw_get_max_edge_power(struct ar9300_eeprom *eep,
+					u16 freq, int idx, bool is2GHz)
+{
+	u16 twiceMaxEdgePower = AR9300_MAX_RATE_POWER;
+	u8 *ctl_freqbin = is2GHz ?
+		&eep->ctl_freqbin_2G[idx][0] :
+		&eep->ctl_freqbin_5G[idx][0];
+	u16 num_edges = is2GHz ?
+		AR9300_NUM_BAND_EDGES_2G : AR9300_NUM_BAND_EDGES_5G;
+	unsigned int edge;
+
+	/* Get the edge power */
+	for (edge = 0;
+	     (edge < num_edges) && (ctl_freqbin[edge] != AR9300_BCHAN_UNUSED);
+	     edge++) {
+		/*
+		 * If there's an exact channel match or an inband flag set
+		 * on the lower channel use the given rdEdgePower
+		 */
+		if (freq == ath9k_hw_fbin2freq(ctl_freqbin[edge], is2GHz)) {
+			twiceMaxEdgePower =
+				ar9003_hw_get_direct_edge_power(eep, idx,
+								edge, is2GHz);
+			break;
+		} else if ((edge > 0) &&
+			   (freq < ath9k_hw_fbin2freq(ctl_freqbin[edge],
+						      is2GHz))) {
+			twiceMaxEdgePower =
+				ar9003_hw_get_indirect_edge_power(eep, idx,
+								  edge, freq,
+								  is2GHz);
+			/*
+			 * Leave loop - no more affecting edges possible in
+			 * this monotonic increasing list
+			 */
+			break;
+		}
+	}
+	return twiceMaxEdgePower;
+}
+
+static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
+					       struct ath9k_channel *chan,
+					       u8 *pPwrArray, u16 cfgCtl,
+					       u8 twiceAntennaReduction,
+					       u8 twiceMaxRegulatoryPower,
+					       u16 powerLimit)
+{
+	struct ath_regulatory *regulatory = ath9k_hw_regulatory(ah);
+	struct ath_common *common = ath9k_hw_common(ah);
+	struct ar9300_eeprom *pEepData = &ah->eeprom.ar9300_eep;
+	u16 twiceMaxEdgePower = AR9300_MAX_RATE_POWER;
+	static const u16 tpScaleReductionTable[5] = {
+		0, 3, 6, 9, AR9300_MAX_RATE_POWER
+	};
+	int i;
+	int16_t  twiceLargestAntenna;
+	u16 scaledPower = 0, minCtlPower, maxRegAllowedPower;
+	u16 ctlModesFor11a[] = {
+		CTL_11A, CTL_5GHT20, CTL_11A_EXT, CTL_5GHT40
+	};
+	u16 ctlModesFor11g[] = {
+		CTL_11B, CTL_11G, CTL_2GHT20, CTL_11B_EXT,
+		CTL_11G_EXT, CTL_2GHT40
+	};
+	u16 numCtlModes, *pCtlMode, ctlMode, freq;
+	struct chan_centers centers;
+	u8 *ctlIndex;
+	u8 ctlNum;
+	u16 twiceMinEdgePower;
+	bool is2ghz = IS_CHAN_2GHZ(chan);
+
+	ath9k_hw_get_channel_centers(ah, chan, &centers);
+
+	/* Compute TxPower reduction due to Antenna Gain */
+	if (is2ghz)
+		twiceLargestAntenna = pEepData->modalHeader2G.antennaGain;
+	else
+		twiceLargestAntenna = pEepData->modalHeader5G.antennaGain;
+
+	twiceLargestAntenna = (int16_t)min((twiceAntennaReduction) -
+				twiceLargestAntenna, 0);
+
+	/*
+	 * scaledPower is the minimum of the user input power level
+	 * and the regulatory allowed power level
+	 */
+	maxRegAllowedPower = twiceMaxRegulatoryPower + twiceLargestAntenna;
+
+	if (regulatory->tp_scale != ATH9K_TP_SCALE_MAX) {
+		maxRegAllowedPower -=
+			(tpScaleReductionTable[(regulatory->tp_scale)] * 2);
+	}
+
+	scaledPower = min(powerLimit, maxRegAllowedPower);
+
+	/*
+	 * Reduce scaled Power by number of chains active to get
+	 * to per chain tx power level
+	 */
+	switch (ar5416_get_ntxchains(ah->txchainmask)) {
+	case 1:
+		break;
+	case 2:
+		scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		break;
+	case 3:
+		scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		break;
+	}
+
+	scaledPower = max((u16)0, scaledPower);
+
+	/*
+	 * Get target powers from EEPROM - our baseline for TX Power
+	 */
+	if (is2ghz) {
+		/* Setup for CTL modes */
+		/* CTL_11B, CTL_11G, CTL_2GHT20 */
+		numCtlModes =
+			ARRAY_SIZE(ctlModesFor11g) -
+				   SUB_NUM_CTL_MODES_AT_2G_40;
+		pCtlMode = ctlModesFor11g;
+		if (IS_CHAN_HT40(chan))
+			/* All 2G CTL's */
+			numCtlModes = ARRAY_SIZE(ctlModesFor11g);
+	} else {
+		/* Setup for CTL modes */
+		/* CTL_11A, CTL_5GHT20 */
+		numCtlModes = ARRAY_SIZE(ctlModesFor11a) -
+					 SUB_NUM_CTL_MODES_AT_5G_40;
+		pCtlMode = ctlModesFor11a;
+		if (IS_CHAN_HT40(chan))
+			/* All 5G CTL's */
+			numCtlModes = ARRAY_SIZE(ctlModesFor11a);
+	}
+
+	/*
+	 * For MIMO, need to apply regulatory caps individually across
+	 * dynamically running modes: CCK, OFDM, HT20, HT40
+	 *
+	 * The outer loop walks through each possible applicable runtime mode.
+	 * The inner loop walks through each ctlIndex entry in EEPROM.
+	 * The ctl value is encoded as [7:4] == test group, [3:0] == test mode.
+	 */
+	for (ctlMode = 0; ctlMode < numCtlModes; ctlMode++) {
+		bool isHt40CtlMode = (pCtlMode[ctlMode] == CTL_5GHT40) ||
+			(pCtlMode[ctlMode] == CTL_2GHT40);
+		if (isHt40CtlMode)
+			freq = centers.synth_center;
+		else if (pCtlMode[ctlMode] & EXT_ADDITIVE)
+			freq = centers.ext_center;
+		else
+			freq = centers.ctl_center;
+
+		ath_print(common, ATH_DBG_REGULATORY,
+			  "LOOP-Mode ctlMode %d < %d, isHt40CtlMode %d, "
+			  "EXT_ADDITIVE %d\n",
+			  ctlMode, numCtlModes, isHt40CtlMode,
+			  (pCtlMode[ctlMode] & EXT_ADDITIVE));
+
+		/* walk through each CTL index stored in EEPROM */
+		if (is2ghz) {
+			ctlIndex = pEepData->ctlIndex_2G;
+			ctlNum = AR9300_NUM_CTLS_2G;
+		} else {
+			ctlIndex = pEepData->ctlIndex_5G;
+			ctlNum = AR9300_NUM_CTLS_5G;
+		}
+
+		for (i = 0; (i < ctlNum) && ctlIndex[i]; i++) {
+			ath_print(common, ATH_DBG_REGULATORY,
+				  "LOOP-Ctlidx %d: cfgCtl 0x%2.2x "
+				  "pCtlMode 0x%2.2x ctlIndex 0x%2.2x "
+				  "chan %dn",
+				  i, cfgCtl, pCtlMode[ctlMode], ctlIndex[i],
+				  chan->channel);
+
+				/*
+				 * compare test group from regulatory
+				 * channel list with test mode from pCtlMode
+				 * list
+				 */
+				if ((((cfgCtl & ~CTL_MODE_M) |
+				       (pCtlMode[ctlMode] & CTL_MODE_M)) ==
+					ctlIndex[i]) ||
+				    (((cfgCtl & ~CTL_MODE_M) |
+				       (pCtlMode[ctlMode] & CTL_MODE_M)) ==
+				     ((ctlIndex[i] & CTL_MODE_M) |
+				       SD_NO_CTL))) {
+					twiceMinEdgePower =
+					  ar9003_hw_get_max_edge_power(pEepData,
+								       freq, i,
+								       is2ghz);
+
+					if ((cfgCtl & ~CTL_MODE_M) == SD_NO_CTL)
+						/*
+						 * Find the minimum of all CTL
+						 * edge powers that apply to
+						 * this channel
+						 */
+						twiceMaxEdgePower =
+							min(twiceMaxEdgePower,
+							    twiceMinEdgePower);
+						else {
+							/* specific */
+							twiceMaxEdgePower =
+							  twiceMinEdgePower;
+							break;
+						}
+				}
+			}
+
+			minCtlPower = (u8)min(twiceMaxEdgePower, scaledPower);
+
+			ath_print(common, ATH_DBG_REGULATORY,
+				  "SEL-Min ctlMode %d pCtlMode %d 2xMaxEdge %d "
+				  "sP %d minCtlPwr %d\n",
+				  ctlMode, pCtlMode[ctlMode], twiceMaxEdgePower,
+				  scaledPower, minCtlPower);
+
+			/* Apply ctl mode to correct target power set */
+			switch (pCtlMode[ctlMode]) {
+			case CTL_11B:
+				for (i = ALL_TARGET_LEGACY_1L_5L;
+				     i <= ALL_TARGET_LEGACY_11S; i++)
+					pPwrArray[i] =
+					  (u8)min((u16)pPwrArray[i],
+						  minCtlPower);
+				break;
+			case CTL_11A:
+			case CTL_11G:
+				for (i = ALL_TARGET_LEGACY_6_24;
+				     i <= ALL_TARGET_LEGACY_54; i++)
+					pPwrArray[i] =
+					  (u8)min((u16)pPwrArray[i],
+						  minCtlPower);
+				break;
+			case CTL_5GHT20:
+			case CTL_2GHT20:
+				for (i = ALL_TARGET_HT20_0_8_16;
+				     i <= ALL_TARGET_HT20_21; i++)
+					pPwrArray[i] =
+					  (u8)min((u16)pPwrArray[i],
+						  minCtlPower);
+				pPwrArray[ALL_TARGET_HT20_22] =
+				  (u8)min((u16)pPwrArray[ALL_TARGET_HT20_22],
+					  minCtlPower);
+				pPwrArray[ALL_TARGET_HT20_23] =
+				  (u8)min((u16)pPwrArray[ALL_TARGET_HT20_23],
+					   minCtlPower);
+				break;
+			case CTL_5GHT40:
+			case CTL_2GHT40:
+				for (i = ALL_TARGET_HT40_0_8_16;
+				     i <= ALL_TARGET_HT40_23; i++)
+					pPwrArray[i] =
+					  (u8)min((u16)pPwrArray[i],
+						  minCtlPower);
+				break;
+			default:
+			    break;
+			}
+	} /* end ctl mode checking */
+}
+
 static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 					struct ath9k_channel *chan, u16 cfgCtl,
 					u8 twiceAntennaReduction,
 					u8 twiceMaxRegulatoryPower,
 					u8 powerLimit)
 {
-	ah->txpower_limit = powerLimit;
-	ar9003_hw_set_target_power_eeprom(ah, chan->channel);
+	struct ath_common *common = ath9k_hw_common(ah);
+	u8 targetPowerValT2[ar9300RateSize];
+	unsigned int i = 0;
+
+	ar9003_hw_set_target_power_eeprom(ah, chan->channel, targetPowerValT2);
+	ar9003_hw_set_power_per_rate_table(ah, chan,
+					   targetPowerValT2, cfgCtl,
+					   twiceAntennaReduction,
+					   twiceMaxRegulatoryPower,
+					   powerLimit);
+
+	while (i < ar9300RateSize) {
+		ath_print(common, ATH_DBG_EEPROM,
+			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		i++;
+		ath_print(common, ATH_DBG_EEPROM,
+			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		i++;
+		ath_print(common, ATH_DBG_EEPROM,
+			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
+		i++;
+		ath_print(common, ATH_DBG_EEPROM,
+			  "TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
+		i++;
+	}
+
+	/* Write target power array to registers */
+	ar9003_hw_tx_power_regwrite(ah, targetPowerValT2);
+
+	/*
+	 * This is the TX power we send back to driver core,
+	 * and it can use to pass to userspace to display our
+	 * currently configured TX power setting.
+	 *
+	 * Since power is rate dependent, use one of the indices
+	 * from the AR9300_Rates enum to select an entry from
+	 * targetPowerValT2[] to report. Currently returns the
+	 * power for HT40 MCS 0, HT20 MCS 0, or OFDM 6 Mbps
+	 * as CCK power is less interesting (?).
+	 */
+	i = ALL_TARGET_LEGACY_6_24; /* legacy */
+	if (IS_CHAN_HT40(chan))
+		i = ALL_TARGET_HT40_0_8_16; /* ht40 */
+	else if (IS_CHAN_HT20(chan))
+		i = ALL_TARGET_HT20_0_8_16; /* ht20 */
+
+	ah->txpower_limit = targetPowerValT2[i];
+
 	ar9003_hw_calibration_apply(ah, chan->channel);
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
index 49e0c86..7c38229 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -577,10 +577,11 @@ static bool create_pa_curve(u32 *data_L, u32 *data_U, u32 *pa_table, u16 *gain)
 }
 
 void ar9003_paprd_populate_single_table(struct ath_hw *ah,
-					struct ath9k_channel *chan, int chain)
+					struct ath9k_hw_cal_data *caldata,
+					int chain)
 {
-	u32 *paprd_table_val = chan->pa_table[chain];
-	u32 small_signal_gain = chan->small_signal_gain[chain];
+	u32 *paprd_table_val = caldata->pa_table[chain];
+	u32 small_signal_gain = caldata->small_signal_gain[chain];
 	u32 training_power;
 	u32 reg = 0;
 	int i;
@@ -654,17 +655,17 @@ int ar9003_paprd_setup_gain_table(struct ath_hw *ah, int chain)
 }
 EXPORT_SYMBOL(ar9003_paprd_setup_gain_table);
 
-int ar9003_paprd_create_curve(struct ath_hw *ah, struct ath9k_channel *chan,
-			      int chain)
+int ar9003_paprd_create_curve(struct ath_hw *ah,
+			      struct ath9k_hw_cal_data *caldata, int chain)
 {
-	u16 *small_signal_gain = &chan->small_signal_gain[chain];
-	u32 *pa_table = chan->pa_table[chain];
+	u16 *small_signal_gain = &caldata->small_signal_gain[chain];
+	u32 *pa_table = caldata->pa_table[chain];
 	u32 *data_L, *data_U;
 	int i, status = 0;
 	u32 *buf;
 	u32 reg;
 
-	memset(chan->pa_table[chain], 0, sizeof(chan->pa_table[chain]));
+	memset(caldata->pa_table[chain], 0, sizeof(caldata->pa_table[chain]));
 
 	buf = kmalloc(2 * 48 * sizeof(u32), GFP_ATOMIC);
 	if (!buf)
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index a753a43..a491854 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -542,7 +542,11 @@ static void ar9003_hw_prog_ini(struct ath_hw *ah,
 		u32 reg = INI_RA(iniArr, i, 0);
 		u32 val = INI_RA(iniArr, i, column);
 
-		REG_WRITE(ah, reg, val);
+		if (reg >= 0x16000 && reg < 0x17000)
+			ath9k_hw_analog_shift_regwrite(ah, reg, val);
+		else
+			REG_WRITE(ah, reg, val);
+
 		DO_DELAY(regWrites);
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 998ae2c..07f26ee 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -510,7 +510,7 @@ void ath_deinit_leds(struct ath_softc *sc);
 #define SC_OP_BEACONS                BIT(1)
 #define SC_OP_RXAGGR                 BIT(2)
 #define SC_OP_TXAGGR                 BIT(3)
-#define SC_OP_FULL_RESET             BIT(4)
+#define SC_OP_OFFCHANNEL             BIT(4)
 #define SC_OP_PREAMBLE_SHORT         BIT(5)
 #define SC_OP_PROTECT_ENABLE         BIT(6)
 #define SC_OP_RXFLUSH                BIT(7)
@@ -609,6 +609,7 @@ struct ath_softc {
 struct ath_wiphy {
 	struct ath_softc *sc; /* shared for all virtual wiphys */
 	struct ieee80211_hw *hw;
+	struct ath9k_hw_cal_data caldata;
 	enum ath_wiphy_state {
 		ATH_WIPHY_INACTIVE,
 		ATH_WIPHY_ACTIVE,
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index 139289e..4520869 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -22,23 +22,6 @@
 /* We can tune this as we go by monitoring really low values */
 #define ATH9K_NF_TOO_LOW	-60
 
-/* AR5416 may return very high value (like -31 dBm), in those cases the nf
- * is incorrect and we should use the static NF value. Later we can try to
- * find out why they are reporting these values */
-
-static bool ath9k_hw_nf_in_range(struct ath_hw *ah, s16 nf)
-{
-	if (nf > ATH9K_NF_TOO_LOW) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
-			  "noise floor value detected (%d) is "
-			  "lower than what we think is a "
-			  "reasonable value (%d)\n",
-			  nf, ATH9K_NF_TOO_LOW);
-		return false;
-	}
-	return true;
-}
-
 static int16_t ath9k_hw_get_nf_hist_mid(int16_t *nfCalBuffer)
 {
 	int16_t nfval;
@@ -121,6 +104,19 @@ void ath9k_hw_reset_calibration(struct ath_hw *ah,
 	ah->cal_samples = 0;
 }
 
+static s16 ath9k_hw_get_default_nf(struct ath_hw *ah,
+				   struct ath9k_channel *chan)
+{
+	struct ath_nf_limits *limit;
+
+	if (!chan || IS_CHAN_2GHZ(chan))
+		limit = &ah->nf_2g;
+	else
+		limit = &ah->nf_5g;
+
+	return limit->nominal;
+}
+
 /* This is done for the currently configured channel */
 bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 {
@@ -128,7 +124,7 @@ bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 	struct ieee80211_conf *conf = &common->hw->conf;
 	struct ath9k_cal_list *currCal = ah->cal_list_curr;
 
-	if (!ah->curchan)
+	if (!ah->caldata)
 		return true;
 
 	if (!AR_SREV_9100(ah) && !AR_SREV_9160_10_OR_LATER(ah))
@@ -151,37 +147,55 @@ bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 		  "Resetting Cal %d state for channel %u\n",
 		  currCal->calData->calType, conf->channel->center_freq);
 
-	ah->curchan->CalValid &= ~currCal->calData->calType;
+	ah->caldata->CalValid &= ~currCal->calData->calType;
 	currCal->calState = CAL_WAITING;
 
 	return false;
 }
 EXPORT_SYMBOL(ath9k_hw_reset_calvalid);
 
-void ath9k_hw_start_nfcal(struct ath_hw *ah)
+void ath9k_hw_start_nfcal(struct ath_hw *ah, bool update)
 {
+	if (ah->caldata)
+		ah->caldata->nfcal_pending = true;
+
 	REG_SET_BIT(ah, AR_PHY_AGC_CONTROL,
 		    AR_PHY_AGC_CONTROL_ENABLE_NF);
-	REG_SET_BIT(ah, AR_PHY_AGC_CONTROL,
+
+	if (update)
+		REG_CLR_BIT(ah, AR_PHY_AGC_CONTROL,
+		    AR_PHY_AGC_CONTROL_NO_UPDATE_NF);
+	else
+		REG_SET_BIT(ah, AR_PHY_AGC_CONTROL,
 		    AR_PHY_AGC_CONTROL_NO_UPDATE_NF);
+
 	REG_SET_BIT(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_NF);
 }
 
 void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan)
 {
-	struct ath9k_nfcal_hist *h;
+	struct ath9k_nfcal_hist *h = NULL;
 	unsigned i, j;
 	int32_t val;
 	u8 chainmask = (ah->rxchainmask << 3) | ah->rxchainmask;
 	struct ath_common *common = ath9k_hw_common(ah);
+	s16 default_nf = ath9k_hw_get_default_nf(ah, chan);
 
-	h = ah->nfCalHist;
+	if (ah->caldata)
+		h = ah->caldata->nfCalHist;
 
 	for (i = 0; i < NUM_NF_READINGS; i++) {
 		if (chainmask & (1 << i)) {
+			s16 nfval;
+
+			if (h)
+				nfval = h[i].privNF;
+			else
+				nfval = default_nf;
+
 			val = REG_READ(ah, ah->nf_regs[i]);
 			val &= 0xFFFFFE00;
-			val |= (((u32) (h[i].privNF) << 1) & 0x1ff);
+			val |= (((u32) nfval << 1) & 0x1ff);
 			REG_WRITE(ah, ah->nf_regs[i], val);
 		}
 	}
@@ -277,22 +291,25 @@ static void ath9k_hw_nf_sanitize(struct ath_hw *ah, s16 *nf)
 	}
 }
 
-int16_t ath9k_hw_getnf(struct ath_hw *ah,
-		       struct ath9k_channel *chan)
+bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 	int16_t nf, nfThresh;
 	int16_t nfarray[NUM_NF_READINGS] = { 0 };
 	struct ath9k_nfcal_hist *h;
 	struct ieee80211_channel *c = chan->chan;
+	struct ath9k_hw_cal_data *caldata = ah->caldata;
+
+	if (!caldata)
+		return false;
 
 	chan->channelFlags &= (~CHANNEL_CW_INT);
 	if (REG_READ(ah, AR_PHY_AGC_CONTROL) & AR_PHY_AGC_CONTROL_NF) {
 		ath_print(common, ATH_DBG_CALIBRATE,
 			  "NF did not complete in calibration window\n");
 		nf = 0;
-		chan->rawNoiseFloor = nf;
-		return chan->rawNoiseFloor;
+		caldata->rawNoiseFloor = nf;
+		return false;
 	} else {
 		ath9k_hw_do_getnf(ah, nfarray);
 		ath9k_hw_nf_sanitize(ah, nfarray);
@@ -307,47 +324,40 @@ int16_t ath9k_hw_getnf(struct ath_hw *ah,
 		}
 	}
 
-	h = ah->nfCalHist;
-
+	h = caldata->nfCalHist;
+	caldata->nfcal_pending = false;
 	ath9k_hw_update_nfcal_hist_buffer(h, nfarray);
-	chan->rawNoiseFloor = h[0].privNF;
-
-	return chan->rawNoiseFloor;
+	caldata->rawNoiseFloor = h[0].privNF;
+	return true;
 }
 
-void ath9k_init_nfcal_hist_buffer(struct ath_hw *ah)
+void ath9k_init_nfcal_hist_buffer(struct ath_hw *ah,
+				  struct ath9k_channel *chan)
 {
-	struct ath_nf_limits *limit;
+	struct ath9k_nfcal_hist *h;
+	s16 default_nf;
 	int i, j;
 
-	if (!ah->curchan || IS_CHAN_2GHZ(ah->curchan))
-		limit = &ah->nf_2g;
-	else
-		limit = &ah->nf_5g;
+	if (!ah->caldata)
+		return;
 
+	h = ah->caldata->nfCalHist;
+	default_nf = ath9k_hw_get_default_nf(ah, chan);
 	for (i = 0; i < NUM_NF_READINGS; i++) {
-		ah->nfCalHist[i].currIndex = 0;
-		ah->nfCalHist[i].privNF = limit->nominal;
-		ah->nfCalHist[i].invalidNFcount =
-			AR_PHY_CCA_FILTERWINDOW_LENGTH;
+		h[i].currIndex = 0;
+		h[i].privNF = default_nf;
+		h[i].invalidNFcount = AR_PHY_CCA_FILTERWINDOW_LENGTH;
 		for (j = 0; j < ATH9K_NF_CAL_HIST_MAX; j++) {
-			ah->nfCalHist[i].nfCalBuffer[j] = limit->nominal;
+			h[i].nfCalBuffer[j] = default_nf;
 		}
 	}
 }
 
 s16 ath9k_hw_getchan_noise(struct ath_hw *ah, struct ath9k_channel *chan)
 {
-	s16 nf;
-
-	if (chan->rawNoiseFloor == 0)
-		nf = -96;
-	else
-		nf = chan->rawNoiseFloor;
-
-	if (!ath9k_hw_nf_in_range(ah, nf))
-		nf = ATH_DEFAULT_NOISE_FLOOR;
+	if (!ah->caldata || !ah->caldata->rawNoiseFloor)
+		return ath9k_hw_get_default_nf(ah, chan);
 
-	return nf;
+	return ah->caldata->rawNoiseFloor;
 }
 EXPORT_SYMBOL(ath9k_hw_getchan_noise);
diff --git a/drivers/net/wireless/ath/ath9k/calib.h b/drivers/net/wireless/ath/ath9k/calib.h
index cd60d09..0a304b3 100644
--- a/drivers/net/wireless/ath/ath9k/calib.h
+++ b/drivers/net/wireless/ath/ath9k/calib.h
@@ -108,11 +108,11 @@ struct ath9k_pacal_info{
 };
 
 bool ath9k_hw_reset_calvalid(struct ath_hw *ah);
-void ath9k_hw_start_nfcal(struct ath_hw *ah);
+void ath9k_hw_start_nfcal(struct ath_hw *ah, bool update);
 void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan);
-int16_t ath9k_hw_getnf(struct ath_hw *ah,
-		       struct ath9k_channel *chan);
-void ath9k_init_nfcal_hist_buffer(struct ath_hw *ah);
+bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan);
+void ath9k_init_nfcal_hist_buffer(struct ath_hw *ah,
+				  struct ath9k_channel *chan);
 s16 ath9k_hw_getchan_noise(struct ath_hw *ah, struct ath9k_channel *chan);
 void ath9k_hw_reset_calibration(struct ath_hw *ah,
 				struct ath9k_cal_list *currCal);
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 3756400..43b9e21 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -353,6 +353,8 @@ struct ath9k_htc_priv {
 	u16 seq_no;
 	u32 bmiss_cnt;
 
+	struct ath9k_hw_cal_data caldata[38];
+
 	spinlock_t beacon_lock;
 
 	bool tx_queues_stop;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index cf9bcc6..ebed9d1 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -125,6 +125,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 	struct ieee80211_conf *conf = &common->hw->conf;
 	bool fastcc = true;
 	struct ieee80211_channel *channel = hw->conf.channel;
+	struct ath9k_hw_cal_data *caldata;
 	enum htc_phymode mode;
 	__be16 htc_mode;
 	u8 cmd_rsp;
@@ -149,7 +150,8 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 		  priv->ah->curchan->channel,
 		  channel->center_freq, conf_is_ht(conf), conf_is_ht40(conf));
 
-	ret = ath9k_hw_reset(ah, hchan, fastcc);
+	caldata = &priv->caldata[channel->hw_value];
+	ret = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (ret) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u Mhz) "
@@ -1028,7 +1030,7 @@ static void ath9k_htc_radio_enable(struct ieee80211_hw *hw)
 		ah->curchan = ath9k_cmn_get_curchannel(hw, ah);
 
 	/* Reset the HW */
-	ret = ath9k_hw_reset(ah, ah->curchan, false);
+	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
@@ -1091,7 +1093,7 @@ static void ath9k_htc_radio_disable(struct ieee80211_hw *hw)
 		ah->curchan = ath9k_cmn_get_curchannel(hw, ah);
 
 	/* Reset the HW */
-	ret = ath9k_hw_reset(ah, ah->curchan, false);
+	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
@@ -1179,7 +1181,7 @@ static int ath9k_htc_start(struct ieee80211_hw *hw)
 	ath9k_hw_configpcipowersave(ah, 0, 0);
 
 	ath9k_hw_htc_resetinit(ah);
-	ret = ath9k_hw_reset(ah, init_channel, false);
+	ret = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (ret) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 8d291cc..3384ca1 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -610,7 +610,6 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 	else
 		ah->tx_trig_level = (AR_FTRIG_512B >> AR_FTRIG_S);
 
-	ath9k_init_nfcal_hist_buffer(ah);
 	ah->bb_watchdog_timeout_ms = 25;
 
 	common->state = ATH_HW_INITIALIZED;
@@ -1183,9 +1182,6 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 
 	ath9k_hw_spur_mitigate_freq(ah, chan);
 
-	if (!chan->oneTimeCalsDone)
-		chan->oneTimeCalsDone = true;
-
 	return true;
 }
 
@@ -1218,7 +1214,7 @@ bool ath9k_hw_check_alive(struct ath_hw *ah)
 EXPORT_SYMBOL(ath9k_hw_check_alive);
 
 int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
-		    bool bChannelChange)
+		   struct ath9k_hw_cal_data *caldata, bool bChannelChange)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 	u32 saveLedState;
@@ -1243,9 +1239,19 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	if (!ath9k_hw_setpower(ah, ATH9K_PM_AWAKE))
 		return -EIO;
 
-	if (curchan && !ah->chip_fullsleep)
+	if (curchan && !ah->chip_fullsleep && ah->caldata)
 		ath9k_hw_getnf(ah, curchan);
 
+	ah->caldata = caldata;
+	if (caldata &&
+	    (chan->channel != caldata->channel ||
+	     (chan->channelFlags & ~CHANNEL_CW_INT) !=
+	     (caldata->channelFlags & ~CHANNEL_CW_INT))) {
+		/* Operating channel changed, reset channel calibration data */
+		memset(caldata, 0, sizeof(*caldata));
+		ath9k_init_nfcal_hist_buffer(ah, chan);
+	}
+
 	if (bChannelChange &&
 	    (ah->chip_fullsleep != true) &&
 	    (ah->curchan != NULL) &&
@@ -1256,7 +1262,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 
 		if (ath9k_hw_channel_change(ah, chan)) {
 			ath9k_hw_loadnf(ah, ah->curchan);
-			ath9k_hw_start_nfcal(ah);
+			ath9k_hw_start_nfcal(ah, true);
 			return 0;
 		}
 	}
@@ -1461,11 +1467,8 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	if (ah->btcoex_hw.enabled)
 		ath9k_hw_btcoex_enable(ah);
 
-	if (AR_SREV_9300_20_OR_LATER(ah)) {
-		ath9k_hw_loadnf(ah, curchan);
-		ath9k_hw_start_nfcal(ah);
+	if (AR_SREV_9300_20_OR_LATER(ah))
 		ar9003_hw_bb_watchdog_config(ah);
-	}
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 2d30efc..399f7c1 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -346,19 +346,25 @@ enum ath9k_int {
 	 CHANNEL_HT40PLUS |			\
 	 CHANNEL_HT40MINUS)
 
-struct ath9k_channel {
-	struct ieee80211_channel *chan;
+struct ath9k_hw_cal_data {
 	u16 channel;
 	u32 channelFlags;
-	u32 chanmode;
 	int32_t CalValid;
-	bool oneTimeCalsDone;
 	int8_t iCoff;
 	int8_t qCoff;
 	int16_t rawNoiseFloor;
 	bool paprd_done;
+	bool nfcal_pending;
 	u16 small_signal_gain[AR9300_MAX_CHAINS];
 	u32 pa_table[AR9300_MAX_CHAINS][PAPRD_TABLE_SZ];
+	struct ath9k_nfcal_hist nfCalHist[NUM_NF_READINGS];
+};
+
+struct ath9k_channel {
+	struct ieee80211_channel *chan;
+	u16 channel;
+	u32 channelFlags;
+	u32 chanmode;
 };
 
 #define IS_CHAN_G(_c) ((((_c)->channelFlags & (CHANNEL_G)) == CHANNEL_G) || \
@@ -669,7 +675,7 @@ struct ath_hw {
 	enum nl80211_iftype opmode;
 	enum ath9k_power_mode power_mode;
 
-	struct ath9k_nfcal_hist nfCalHist[NUM_NF_READINGS];
+	struct ath9k_hw_cal_data *caldata;
 	struct ath9k_pacal_info pacal_info;
 	struct ar5416Stats stats;
 	struct ath9k_tx_queue_info txq[ATH9K_NUM_TX_QUEUES];
@@ -863,7 +869,7 @@ const char *ath9k_hw_probe(u16 vendorid, u16 devid);
 void ath9k_hw_deinit(struct ath_hw *ah);
 int ath9k_hw_init(struct ath_hw *ah);
 int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
-		   bool bChannelChange);
+		   struct ath9k_hw_cal_data *caldata, bool bChannelChange);
 int ath9k_hw_fill_cap_info(struct ath_hw *ah);
 u32 ath9k_regd_get_ctl(struct ath_regulatory *reg, struct ath9k_channel *chan);
 
@@ -958,9 +964,10 @@ void ar9003_hw_bb_watchdog_read(struct ath_hw *ah);
 void ar9003_hw_bb_watchdog_dbg_info(struct ath_hw *ah);
 void ar9003_paprd_enable(struct ath_hw *ah, bool val);
 void ar9003_paprd_populate_single_table(struct ath_hw *ah,
-					struct ath9k_channel *chan, int chain);
-int ar9003_paprd_create_curve(struct ath_hw *ah, struct ath9k_channel *chan,
-			      int chain);
+					struct ath9k_hw_cal_data *caldata,
+					int chain);
+int ar9003_paprd_create_curve(struct ath_hw *ah,
+			      struct ath9k_hw_cal_data *caldata, int chain);
 int ar9003_paprd_setup_gain_table(struct ath_hw *ah, int chain);
 int ar9003_paprd_init_table(struct ath_hw *ah);
 bool ar9003_paprd_is_done(struct ath_hw *ah);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 0429dda..3caa323 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -154,6 +154,27 @@ void ath9k_ps_restore(struct ath_softc *sc)
 	spin_unlock_irqrestore(&sc->sc_pm_lock, flags);
 }
 
+static void ath_start_ani(struct ath_common *common)
+{
+	struct ath_hw *ah = common->ah;
+	unsigned long timestamp = jiffies_to_msecs(jiffies);
+	struct ath_softc *sc = (struct ath_softc *) common->priv;
+
+	if (!(sc->sc_flags & SC_OP_ANI_RUN))
+		return;
+
+	if (sc->sc_flags & SC_OP_OFFCHANNEL)
+		return;
+
+	common->ani.longcal_timer = timestamp;
+	common->ani.shortcal_timer = timestamp;
+	common->ani.checkani_timer = timestamp;
+
+	mod_timer(&common->ani.timer,
+		  jiffies +
+			msecs_to_jiffies((u32)ah->config.ani_poll_interval));
+}
+
 /*
  * Set/change channels.  If the channel is really being changed, it's done
  * by reseting the chip.  To accomplish this we must first cleanup any pending
@@ -162,16 +183,23 @@ void ath9k_ps_restore(struct ath_softc *sc)
 int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 		    struct ath9k_channel *hchan)
 {
+	struct ath_wiphy *aphy = hw->priv;
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	struct ieee80211_conf *conf = &common->hw->conf;
 	bool fastcc = true, stopped;
 	struct ieee80211_channel *channel = hw->conf.channel;
+	struct ath9k_hw_cal_data *caldata = NULL;
 	int r;
 
 	if (sc->sc_flags & SC_OP_INVALID)
 		return -EIO;
 
+	del_timer_sync(&common->ani.timer);
+	cancel_work_sync(&sc->paprd_work);
+	cancel_work_sync(&sc->hw_check_work);
+	cancel_delayed_work_sync(&sc->tx_complete_work);
+
 	ath9k_ps_wakeup(sc);
 
 	/*
@@ -191,9 +219,12 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	 * to flush data frames already in queue because of
 	 * changing channel. */
 
-	if (!stopped || (sc->sc_flags & SC_OP_FULL_RESET))
+	if (!stopped || !(sc->sc_flags & SC_OP_OFFCHANNEL))
 		fastcc = false;
 
+	if (!(sc->sc_flags & SC_OP_OFFCHANNEL))
+		caldata = &aphy->caldata;
+
 	ath_print(common, ATH_DBG_CONFIG,
 		  "(%u MHz) -> (%u MHz), conf_is_ht40: %d\n",
 		  sc->sc_ah->curchan->channel,
@@ -201,7 +232,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 
 	spin_lock_bh(&sc->sc_resetlock);
 
-	r = ath9k_hw_reset(ah, hchan, fastcc);
+	r = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (r) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
@@ -212,8 +243,6 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	}
 	spin_unlock_bh(&sc->sc_resetlock);
 
-	sc->sc_flags &= ~SC_OP_FULL_RESET;
-
 	if (ath_startrecv(sc) != 0) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to restart recv logic\n");
@@ -225,6 +254,12 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	ath_update_txpow(sc);
 	ath9k_hw_set_interrupts(ah, ah->imask);
 
+	if (!(sc->sc_flags & (SC_OP_OFFCHANNEL | SC_OP_SCANNING))) {
+		ath_start_ani(common);
+		ieee80211_queue_delayed_work(sc->hw, &sc->tx_complete_work, 0);
+		ath_beacon_config(sc, NULL);
+	}
+
  ps_restore:
 	ath9k_ps_restore(sc);
 	return r;
@@ -233,17 +268,19 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 static void ath_paprd_activate(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
+	struct ath9k_hw_cal_data *caldata = ah->caldata;
 	int chain;
 
-	if (!ah->curchan->paprd_done)
+	if (!caldata || !caldata->paprd_done)
 		return;
 
 	ath9k_ps_wakeup(sc);
+	ar9003_paprd_enable(ah, false);
 	for (chain = 0; chain < AR9300_MAX_CHAINS; chain++) {
 		if (!(ah->caps.tx_chainmask & BIT(chain)))
 			continue;
 
-		ar9003_paprd_populate_single_table(ah, ah->curchan, chain);
+		ar9003_paprd_populate_single_table(ah, caldata, chain);
 	}
 
 	ar9003_paprd_enable(ah, true);
@@ -261,6 +298,7 @@ void ath_paprd_calibrate(struct work_struct *work)
 	int band = hw->conf.channel->band;
 	struct ieee80211_supported_band *sband = &sc->sbands[band];
 	struct ath_tx_control txctl;
+	struct ath9k_hw_cal_data *caldata = ah->caldata;
 	int qnum, ftype;
 	int chain_ok = 0;
 	int chain;
@@ -268,6 +306,9 @@ void ath_paprd_calibrate(struct work_struct *work)
 	int time_left;
 	int i;
 
+	if (!caldata)
+		return;
+
 	skb = alloc_skb(len, GFP_KERNEL);
 	if (!skb)
 		return;
@@ -322,7 +363,7 @@ void ath_paprd_calibrate(struct work_struct *work)
 		if (!ar9003_paprd_is_done(ah))
 			break;
 
-		if (ar9003_paprd_create_curve(ah, ah->curchan, chain) != 0)
+		if (ar9003_paprd_create_curve(ah, caldata, chain) != 0)
 			break;
 
 		chain_ok = 1;
@@ -330,7 +371,7 @@ void ath_paprd_calibrate(struct work_struct *work)
 	kfree_skb(skb);
 
 	if (chain_ok) {
-		ah->curchan->paprd_done = true;
+		caldata->paprd_done = true;
 		ath_paprd_activate(sc);
 	}
 
@@ -439,33 +480,14 @@ set_timer:
 		cal_interval = min(cal_interval, (u32)short_cal_interval);
 
 	mod_timer(&common->ani.timer, jiffies + msecs_to_jiffies(cal_interval));
-	if ((sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_PAPRD) &&
-	    !(sc->sc_flags & SC_OP_SCANNING)) {
-		if (!sc->sc_ah->curchan->paprd_done)
+	if ((sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_PAPRD) && ah->caldata) {
+		if (!ah->caldata->paprd_done)
 			ieee80211_queue_work(sc->hw, &sc->paprd_work);
 		else
 			ath_paprd_activate(sc);
 	}
 }
 
-static void ath_start_ani(struct ath_common *common)
-{
-	struct ath_hw *ah = common->ah;
-	unsigned long timestamp = jiffies_to_msecs(jiffies);
-	struct ath_softc *sc = (struct ath_softc *) common->priv;
-
-	if (!(sc->sc_flags & SC_OP_ANI_RUN))
-		return;
-
-	common->ani.longcal_timer = timestamp;
-	common->ani.shortcal_timer = timestamp;
-	common->ani.checkani_timer = timestamp;
-
-	mod_timer(&common->ani.timer,
-		  jiffies +
-			msecs_to_jiffies((u32)ah->config.ani_poll_interval));
-}
-
 /*
  * Update tx/rx chainmask. For legacy association,
  * hard code chainmask to 1x1, for 11n association, use
@@ -477,7 +499,7 @@ void ath_update_chainmask(struct ath_softc *sc, int is_ht)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	if ((sc->sc_flags & SC_OP_SCANNING) || is_ht ||
+	if ((sc->sc_flags & SC_OP_OFFCHANNEL) || is_ht ||
 	    (ah->btcoex_hw.scheme != ATH_BTCOEX_CFG_NONE)) {
 		common->tx_chainmask = ah->caps.tx_chainmask;
 		common->rx_chainmask = ah->caps.rx_chainmask;
@@ -817,7 +839,7 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 		ah->curchan = ath_get_curchannel(sc, sc->hw);
 
 	spin_lock_bh(&sc->sc_resetlock);
-	r = ath9k_hw_reset(ah, ah->curchan, false);
+	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
@@ -877,7 +899,7 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 		ah->curchan = ath_get_curchannel(sc, hw);
 
 	spin_lock_bh(&sc->sc_resetlock);
-	r = ath9k_hw_reset(ah, ah->curchan, false);
+	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
 		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
@@ -910,7 +932,7 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 	ath_flushrecv(sc);
 
 	spin_lock_bh(&sc->sc_resetlock);
-	r = ath9k_hw_reset(ah, sc->sc_ah->curchan, false);
+	r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 	if (r)
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d\n", r);
@@ -1085,7 +1107,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	 * and then setup of the interrupt mask.
 	 */
 	spin_lock_bh(&sc->sc_resetlock);
-	r = ath9k_hw_reset(ah, init_channel, false);
+	r = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (r) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
@@ -1579,6 +1601,10 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 
 		aphy->chan_idx = pos;
 		aphy->chan_is_ht = conf_is_ht(conf);
+		if (hw->conf.flags & IEEE80211_CONF_OFFCHANNEL)
+			sc->sc_flags |= SC_OP_OFFCHANNEL;
+		else
+			sc->sc_flags &= ~SC_OP_OFFCHANNEL;
 
 		if (aphy->state == ATH_WIPHY_SCAN ||
 		    aphy->state == ATH_WIPHY_ACTIVE)
@@ -1990,7 +2016,6 @@ static void ath9k_sw_scan_start(struct ieee80211_hw *hw)
 {
 	struct ath_wiphy *aphy = hw->priv;
 	struct ath_softc *sc = aphy->sc;
-	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 
 	mutex_lock(&sc->mutex);
 	if (ath9k_wiphy_scanning(sc)) {
@@ -2008,10 +2033,6 @@ static void ath9k_sw_scan_start(struct ieee80211_hw *hw)
 	aphy->state = ATH_WIPHY_SCAN;
 	ath9k_wiphy_pause_all_forced(sc, aphy);
 	sc->sc_flags |= SC_OP_SCANNING;
-	del_timer_sync(&common->ani.timer);
-	cancel_work_sync(&sc->paprd_work);
-	cancel_work_sync(&sc->hw_check_work);
-	cancel_delayed_work_sync(&sc->tx_complete_work);
 	mutex_unlock(&sc->mutex);
 }
 
@@ -2023,15 +2044,10 @@ static void ath9k_sw_scan_complete(struct ieee80211_hw *hw)
 {
 	struct ath_wiphy *aphy = hw->priv;
 	struct ath_softc *sc = aphy->sc;
-	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 
 	mutex_lock(&sc->mutex);
 	aphy->state = ATH_WIPHY_ACTIVE;
 	sc->sc_flags &= ~SC_OP_SCANNING;
-	sc->sc_flags |= SC_OP_FULL_RESET;
-	ath_start_ani(common);
-	ieee80211_queue_delayed_work(sc->hw, &sc->tx_complete_work, 0);
-	ath_beacon_config(sc, NULL);
 	mutex_unlock(&sc->mutex);
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index da0cfe9..a3fc987 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1140,6 +1140,11 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		if (flush)
 			goto requeue;
 
+		retval = ath9k_rx_skb_preprocess(common, hw, hdr, &rs,
+						 rxs, &decrypt_error);
+		if (retval)
+			goto requeue;
+
 		rxs->mactime = (tsf & ~0xffffffffULL) | rs.rs_tstamp;
 		if (rs.rs_tstamp > tsf_lower &&
 		    unlikely(rs.rs_tstamp - tsf_lower > 0x10000000))
@@ -1149,11 +1154,6 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		    unlikely(tsf_lower - rs.rs_tstamp > 0x10000000))
 			rxs->mactime += 0x100000000ULL;
 
-		retval = ath9k_rx_skb_preprocess(common, hw, hdr, &rs,
-						 rxs, &decrypt_error);
-		if (retval)
-			goto requeue;
-
 		/* Ensure we always have an skb to requeue once we are done
 		 * processing the current buffer's skb */
 		requeue_skb = ath_rxbuf_alloc(common, common->rx_bufsize, GFP_ATOMIC);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 501b728..4dda14e 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -120,26 +120,14 @@ static void ath_tx_queue_tid(struct ath_txq *txq, struct ath_atx_tid *tid)
 	list_add_tail(&ac->list, &txq->axq_acq);
 }
 
-static void ath_tx_pause_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
-{
-	struct ath_txq *txq = &sc->tx.txq[tid->ac->qnum];
-
-	spin_lock_bh(&txq->axq_lock);
-	tid->paused++;
-	spin_unlock_bh(&txq->axq_lock);
-}
-
 static void ath_tx_resume_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 {
 	struct ath_txq *txq = &sc->tx.txq[tid->ac->qnum];
 
-	BUG_ON(tid->paused <= 0);
-	spin_lock_bh(&txq->axq_lock);
-
-	tid->paused--;
+	WARN_ON(!tid->paused);
 
-	if (tid->paused > 0)
-		goto unlock;
+	spin_lock_bh(&txq->axq_lock);
+	tid->paused = false;
 
 	if (list_empty(&tid->buf_q))
 		goto unlock;
@@ -157,15 +145,10 @@ static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 	struct list_head bf_head;
 	INIT_LIST_HEAD(&bf_head);
 
-	BUG_ON(tid->paused <= 0);
-	spin_lock_bh(&txq->axq_lock);
+	WARN_ON(!tid->paused);
 
-	tid->paused--;
-
-	if (tid->paused > 0) {
-		spin_unlock_bh(&txq->axq_lock);
-		return;
-	}
+	spin_lock_bh(&txq->axq_lock);
+	tid->paused = false;
 
 	while (!list_empty(&tid->buf_q)) {
 		bf = list_first_entry(&tid->buf_q, struct ath_buf, list);
@@ -811,7 +794,7 @@ void ath_tx_aggr_start(struct ath_softc *sc, struct ieee80211_sta *sta,
 	an = (struct ath_node *)sta->drv_priv;
 	txtid = ATH_AN_2_TID(an, tid);
 	txtid->state |= AGGR_ADDBA_PROGRESS;
-	ath_tx_pause_tid(sc, txtid);
+	txtid->paused = true;
 	*ssn = txtid->seq_start;
 }
 
@@ -835,10 +818,9 @@ void ath_tx_aggr_stop(struct ath_softc *sc, struct ieee80211_sta *sta, u16 tid)
 		return;
 	}
 
-	ath_tx_pause_tid(sc, txtid);
-
 	/* drop all software retried frames and mark this TID */
 	spin_lock_bh(&txq->axq_lock);
+	txtid->paused = true;
 	while (!list_empty(&txtid->buf_q)) {
 		bf = list_first_entry(&txtid->buf_q, struct ath_buf, list);
 		if (!bf_isretried(bf)) {
@@ -1181,7 +1163,7 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 			  "Failed to stop TX DMA. Resetting hardware!\n");
 
 		spin_lock_bh(&sc->sc_resetlock);
-		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, false);
+		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 		if (r)
 			ath_print(common, ATH_DBG_FATAL,
 				  "Unable to reset hardware; reset status %d\n",
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 5bbff4c..a146240 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1924,6 +1924,10 @@ static int ipw2100_net_init(struct net_device *dev)
 		bg_band->channels =
 			kzalloc(geo->bg_channels *
 				sizeof(struct ieee80211_channel), GFP_KERNEL);
+		if (!bg_band->channels) {
+			ipw2100_down(priv);
+			return -ENOMEM;
+		}
 		/* translate geo->bg to bg_band.channels */
 		for (i = 0; i < geo->bg_channels; i++) {
 			bg_band->channels[i].band = IEEE80211_BAND_2GHZ;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
index f052c6d..d706b8a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
@@ -980,7 +980,7 @@ ssize_t iwl_ucode_bt_stats_read(struct file *file,
 			 le32_to_cpu(bt->lo_priority_tx_req_cnt),
 			 accum_bt->lo_priority_tx_req_cnt);
 	pos += scnprintf(buf + pos, bufsz - pos,
-			 "lo_priority_rx_denied_cnt:\t%u\t\t\t%u\n",
+			 "lo_priority_tx_denied_cnt:\t%u\t\t\t%u\n",
 			 le32_to_cpu(bt->lo_priority_tx_denied_cnt),
 			 accum_bt->lo_priority_tx_denied_cnt);
 	pos += scnprintf(buf + pos, bufsz - pos,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index a1b6d20..9dd9e64 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1429,7 +1429,7 @@ int iwlagn_manage_ibss_station(struct iwl_priv *priv,
 void iwl_free_tfds_in_queue(struct iwl_priv *priv,
 			    int sta_id, int tid, int freed)
 {
-	WARN_ON(!spin_is_locked(&priv->sta_lock));
+	lockdep_assert_held(&priv->sta_lock);
 
 	if (priv->stations[sta_id].tid[tid].tfds_in_queue >= freed)
 		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 35c86d2..23e5c42 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -300,8 +300,9 @@ static int rs_tl_turn_on_agg_for_tid(struct iwl_priv *priv,
 				      struct ieee80211_sta *sta)
 {
 	int ret = -EAGAIN;
+	u32 load = rs_tl_get_load(lq_data, tid);
 
-	if (rs_tl_get_load(lq_data, tid) > IWL_AGG_LOAD_THRESHOLD) {
+	if (load > IWL_AGG_LOAD_THRESHOLD) {
 		IWL_DEBUG_HT(priv, "Starting Tx agg: STA: %pM tid: %d\n",
 				sta->addr, tid);
 		ret = ieee80211_start_tx_ba_session(sta, tid);
@@ -311,12 +312,14 @@ static int rs_tl_turn_on_agg_for_tid(struct iwl_priv *priv,
 			 * this might be cause by reloading firmware
 			 * stop the tx ba session here
 			 */
-			IWL_DEBUG_HT(priv, "Fail start Tx agg on tid: %d\n",
+			IWL_ERR(priv, "Fail start Tx agg on tid: %d\n",
 				tid);
 			ieee80211_stop_tx_ba_session(sta, tid);
 		}
-	} else
-		IWL_ERR(priv, "Fail finding valid aggregation tid: %d\n", tid);
+	} else {
+		IWL_ERR(priv, "Aggregation not enabled for tid %d "
+			"because load = %u\n", tid, load);
+	}
 	return ret;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
index 55a1b31..d04502d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -1117,7 +1117,7 @@ int iwlagn_txq_check_empty(struct iwl_priv *priv,
 	u8 *addr = priv->stations[sta_id].sta.sta.addr;
 	struct iwl_tid_data *tid_data = &priv->stations[sta_id].tid[tid];
 
-	WARN_ON(!spin_is_locked(&priv->sta_lock));
+	lockdep_assert_held(&priv->sta_lock);
 
 	switch (priv->stations[sta_id].tid[tid].agg.state) {
 	case IWL_EMPTYING_HW_QUEUE_DELBA:
@@ -1331,7 +1331,14 @@ void iwlagn_rx_reply_compressed_ba(struct iwl_priv *priv,
 	tid = ba_resp->tid;
 	agg = &priv->stations[sta_id].tid[tid].agg;
 	if (unlikely(agg->txq_id != scd_flow)) {
-		IWL_ERR(priv, "BA scd_flow %d does not match txq_id %d\n",
+		/*
+		 * FIXME: this is a uCode bug which need to be addressed,
+		 * log the information and return for now!
+		 * since it is possible happen very often and in order
+		 * not to fill the syslog, don't enable the logging by default
+		 */
+		IWL_DEBUG_TX_REPLY(priv,
+			"BA scd_flow %d does not match txq_id %d\n",
 			scd_flow, agg->txq_id);
 		return;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 8024d44..8ccb6d2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2000,6 +2000,7 @@ void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 			      struct ieee80211_vif *vif)
 {
 	struct iwl_priv *priv = hw->priv;
+	bool scan_completed = false;
 
 	IWL_DEBUG_MAC80211(priv, "enter\n");
 
@@ -2013,7 +2014,7 @@ void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	if (priv->vif == vif) {
 		priv->vif = NULL;
 		if (priv->scan_vif == vif) {
-			ieee80211_scan_completed(priv->hw, true);
+			scan_completed = true;
 			priv->scan_vif = NULL;
 			priv->scan_request = NULL;
 		}
@@ -2021,6 +2022,9 @@ void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	}
 	mutex_unlock(&priv->mutex);
 
+	if (scan_completed)
+		ieee80211_scan_completed(priv->hw, true);
+
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index 5c2bcef..0b961a3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -71,7 +71,7 @@ do {                                            			\
 #define IWL_DEBUG(__priv, level, fmt, args...)
 #define IWL_DEBUG_LIMIT(__priv, level, fmt, args...)
 static inline void iwl_print_hex_dump(struct iwl_priv *priv, int level,
-				      void *p, u32 len)
+				      const void *p, u32 len)
 {}
 #endif				/* CONFIG_IWLWIFI_DEBUG */
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.h b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
index ae7319b..4cf864c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
@@ -193,7 +193,7 @@ TRACE_EVENT(iwlwifi_dev_tx,
 		__entry->framelen = buf0_len + buf1_len;
 		memcpy(__get_dynamic_array(tfd), tfd, tfdlen);
 		memcpy(__get_dynamic_array(buf0), buf0, buf0_len);
-		memcpy(__get_dynamic_array(buf1), buf1, buf0_len);
+		memcpy(__get_dynamic_array(buf1), buf1, buf1_len);
 	),
 	TP_printk("[%p] TX %.2x (%zu bytes)",
 		  __entry->priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index b0c6b04..a4b3663 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -298,7 +298,7 @@ EXPORT_SYMBOL(iwl_init_scan_params);
 
 static int iwl_scan_initiate(struct iwl_priv *priv, struct ieee80211_vif *vif)
 {
-	WARN_ON(!mutex_is_locked(&priv->mutex));
+	lockdep_assert_held(&priv->mutex);
 
 	IWL_DEBUG_INFO(priv, "Starting scan...\n");
 	set_bit(STATUS_SCANNING, &priv->status);
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index 9511f03..7e0829b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -773,7 +773,7 @@ static int iwl_send_static_wepkey_cmd(struct iwl_priv *priv, u8 send_if_empty)
 
 int iwl_restore_default_wep_keys(struct iwl_priv *priv)
 {
-	WARN_ON(!mutex_is_locked(&priv->mutex));
+	lockdep_assert_held(&priv->mutex);
 
 	return iwl_send_static_wepkey_cmd(priv, 0);
 }
@@ -784,7 +784,7 @@ int iwl_remove_default_wep_key(struct iwl_priv *priv,
 {
 	int ret;
 
-	WARN_ON(!mutex_is_locked(&priv->mutex));
+	lockdep_assert_held(&priv->mutex);
 
 	IWL_DEBUG_WEP(priv, "Removing default WEP key: idx=%d\n",
 		      keyconf->keyidx);
@@ -808,7 +808,7 @@ int iwl_set_default_wep_key(struct iwl_priv *priv,
 {
 	int ret;
 
-	WARN_ON(!mutex_is_locked(&priv->mutex));
+	lockdep_assert_held(&priv->mutex);
 
 	if (keyconf->keylen != WEP_KEY_LEN_128 &&
 	    keyconf->keylen != WEP_KEY_LEN_64) {
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 25f9027..8e9fbfd 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -257,6 +257,29 @@ static int lbs_add_supported_rates_tlv(u8 *tlv)
 	return sizeof(rate_tlv->header) + i;
 }
 
+/* Add common rates from a TLV and return the new end of the TLV */
+static u8 *
+add_ie_rates(u8 *tlv, const u8 *ie, int *nrates)
+{
+	int hw, ap, ap_max = ie[1];
+	u8 hw_rate;
+
+	/* Advance past IE header */
+	ie += 2;
+
+	lbs_deb_hex(LBS_DEB_ASSOC, "AP IE Rates", (u8 *) ie, ap_max);
+
+	for (hw = 0; hw < ARRAY_SIZE(lbs_rates); hw++) {
+		hw_rate = lbs_rates[hw].bitrate / 5;
+		for (ap = 0; ap < ap_max; ap++) {
+			if (hw_rate == (ie[ap] & 0x7f)) {
+				*tlv++ = ie[ap];
+				*nrates = *nrates + 1;
+			}
+		}
+	}
+	return tlv;
+}
 
 /*
  * Adds a TLV with all rates the hardware *and* BSS supports.
@@ -264,8 +287,11 @@ static int lbs_add_supported_rates_tlv(u8 *tlv)
 static int lbs_add_common_rates_tlv(u8 *tlv, struct cfg80211_bss *bss)
 {
 	struct mrvl_ie_rates_param_set *rate_tlv = (void *)tlv;
-	const u8 *rates_eid = ieee80211_bss_get_ie(bss, WLAN_EID_SUPP_RATES);
-	int n;
+	const u8 *rates_eid, *ext_rates_eid;
+	int n = 0;
+
+	rates_eid = ieee80211_bss_get_ie(bss, WLAN_EID_SUPP_RATES);
+	ext_rates_eid = ieee80211_bss_get_ie(bss, WLAN_EID_EXT_SUPP_RATES);
 
 	/*
 	 * 01 00                   TLV_TYPE_RATES
@@ -275,26 +301,21 @@ static int lbs_add_common_rates_tlv(u8 *tlv, struct cfg80211_bss *bss)
 	rate_tlv->header.type = cpu_to_le16(TLV_TYPE_RATES);
 	tlv += sizeof(rate_tlv->header);
 
-	if (!rates_eid) {
+	/* Add basic rates */
+	if (rates_eid) {
+		tlv = add_ie_rates(tlv, rates_eid, &n);
+
+		/* Add extended rates, if any */
+		if (ext_rates_eid)
+			tlv = add_ie_rates(tlv, ext_rates_eid, &n);
+	} else {
+		lbs_deb_assoc("assoc: bss had no basic rate IE\n");
 		/* Fallback: add basic 802.11b rates */
 		*tlv++ = 0x82;
 		*tlv++ = 0x84;
 		*tlv++ = 0x8b;
 		*tlv++ = 0x96;
 		n = 4;
-	} else {
-		int hw, ap;
-		u8 ap_max = rates_eid[1];
-		n = 0;
-		for (hw = 0; hw < ARRAY_SIZE(lbs_rates); hw++) {
-			u8 hw_rate = lbs_rates[hw].bitrate / 5;
-			for (ap = 0; ap < ap_max; ap++) {
-				if (hw_rate == (rates_eid[ap+2] & 0x7f)) {
-					*tlv++ = rates_eid[ap+2];
-					n++;
-				}
-			}
-		}
 	}
 
 	rate_tlv->header.len = cpu_to_le16(n);
@@ -465,7 +486,15 @@ static int lbs_ret_scan(struct lbs_private *priv, unsigned long dummy,
 	lbs_deb_enter(LBS_DEB_CFG80211);
 
 	bsssize = get_unaligned_le16(&scanresp->bssdescriptsize);
-	nr_sets = le16_to_cpu(resp->size);
+	nr_sets = le16_to_cpu(scanresp->nr_sets);
+
+	lbs_deb_scan("scan response: %d BSSs (%d bytes); resp size %d bytes\n",
+			nr_sets, bsssize, le16_to_cpu(resp->size));
+
+	if (nr_sets == 0) {
+		ret = 0;
+		goto done;
+	}
 
 	/*
 	 * The general layout of the scan response is described in chapter
@@ -670,8 +699,13 @@ static void lbs_scan_worker(struct work_struct *work)
 
 	if (priv->scan_channel >= priv->scan_req->n_channels) {
 		/* Mark scan done */
-		cfg80211_scan_done(priv->scan_req, false);
+		if (priv->internal_scan)
+			kfree(priv->scan_req);
+		else
+			cfg80211_scan_done(priv->scan_req, false);
+
 		priv->scan_req = NULL;
+		priv->last_scan = jiffies;
 	}
 
 	/* Restart network */
@@ -682,10 +716,33 @@ static void lbs_scan_worker(struct work_struct *work)
 
 	kfree(scan_cmd);
 
+	/* Wake up anything waiting on scan completion */
+	if (priv->scan_req == NULL) {
+		lbs_deb_scan("scan: waking up waiters\n");
+		wake_up_all(&priv->scan_q);
+	}
+
  out_no_scan_cmd:
 	lbs_deb_leave(LBS_DEB_SCAN);
 }
 
+static void _internal_start_scan(struct lbs_private *priv, bool internal,
+	struct cfg80211_scan_request *request)
+{
+	lbs_deb_enter(LBS_DEB_CFG80211);
+
+	lbs_deb_scan("scan: ssids %d, channels %d, ie_len %zd\n",
+		request->n_ssids, request->n_channels, request->ie_len);
+
+	priv->scan_channel = 0;
+	queue_delayed_work(priv->work_thread, &priv->scan_work,
+		msecs_to_jiffies(50));
+
+	priv->scan_req = request;
+	priv->internal_scan = internal;
+
+	lbs_deb_leave(LBS_DEB_CFG80211);
+}
 
 static int lbs_cfg_scan(struct wiphy *wiphy,
 	struct net_device *dev,
@@ -702,18 +759,11 @@ static int lbs_cfg_scan(struct wiphy *wiphy,
 		goto out;
 	}
 
-	lbs_deb_scan("scan: ssids %d, channels %d, ie_len %zd\n",
-		request->n_ssids, request->n_channels, request->ie_len);
-
-	priv->scan_channel = 0;
-	queue_delayed_work(priv->work_thread, &priv->scan_work,
-		msecs_to_jiffies(50));
+	_internal_start_scan(priv, false, request);
 
 	if (priv->surpriseremoved)
 		ret = -EIO;
 
-	priv->scan_req = request;
-
  out:
 	lbs_deb_leave_args(LBS_DEB_CFG80211, "ret %d", ret);
 	return ret;
@@ -1000,6 +1050,7 @@ static int lbs_associate(struct lbs_private *priv,
 	int status;
 	int ret;
 	u8 *pos = &(cmd->iebuf[0]);
+	u8 *tmp;
 
 	lbs_deb_enter(LBS_DEB_CFG80211);
 
@@ -1044,7 +1095,9 @@ static int lbs_associate(struct lbs_private *priv,
 	pos += lbs_add_cf_param_tlv(pos);
 
 	/* add rates TLV */
+	tmp = pos + 4; /* skip Marvell IE header */
 	pos += lbs_add_common_rates_tlv(pos, bss);
+	lbs_deb_hex(LBS_DEB_ASSOC, "Common Rates", tmp, pos - tmp);
 
 	/* add auth type TLV */
 	if (priv->fwrelease >= 0x09000000)
@@ -1124,7 +1177,62 @@ done:
 	return ret;
 }
 
+static struct cfg80211_scan_request *
+_new_connect_scan_req(struct wiphy *wiphy, struct cfg80211_connect_params *sme)
+{
+	struct cfg80211_scan_request *creq = NULL;
+	int i, n_channels = 0;
+	enum ieee80211_band band;
+
+	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
+		if (wiphy->bands[band])
+			n_channels += wiphy->bands[band]->n_channels;
+	}
+
+	creq = kzalloc(sizeof(*creq) + sizeof(struct cfg80211_ssid) +
+		       n_channels * sizeof(void *),
+		       GFP_ATOMIC);
+	if (!creq)
+		return NULL;
+
+	/* SSIDs come after channels */
+	creq->ssids = (void *)&creq->channels[n_channels];
+	creq->n_channels = n_channels;
+	creq->n_ssids = 1;
+
+	/* Scan all available channels */
+	i = 0;
+	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
+		int j;
+
+		if (!wiphy->bands[band])
+			continue;
+
+		for (j = 0; j < wiphy->bands[band]->n_channels; j++) {
+			/* ignore disabled channels */
+			if (wiphy->bands[band]->channels[j].flags &
+						IEEE80211_CHAN_DISABLED)
+				continue;
+
+			creq->channels[i] = &wiphy->bands[band]->channels[j];
+			i++;
+		}
+	}
+	if (i) {
+		/* Set real number of channels specified in creq->channels[] */
+		creq->n_channels = i;
+
+		/* Scan for the SSID we're going to connect to */
+		memcpy(creq->ssids[0].ssid, sme->ssid, sme->ssid_len);
+		creq->ssids[0].ssid_len = sme->ssid_len;
+	} else {
+		/* No channels found... */
+		kfree(creq);
+		creq = NULL;
+	}
 
+	return creq;
+}
 
 static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
 			   struct cfg80211_connect_params *sme)
@@ -1136,37 +1244,43 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	lbs_deb_enter(LBS_DEB_CFG80211);
 
-	if (sme->bssid) {
-		bss = cfg80211_get_bss(wiphy, sme->channel, sme->bssid,
-			sme->ssid, sme->ssid_len,
-			WLAN_CAPABILITY_ESS, WLAN_CAPABILITY_ESS);
-	} else {
-		/*
-		 * Here we have an impedance mismatch. The firmware command
-		 * CMD_802_11_ASSOCIATE always needs a BSSID, it cannot
-		 * connect otherwise. However, for the connect-API of
-		 * cfg80211 the bssid is purely optional. We don't get one,
-		 * except the user specifies one on the "iw" command line.
-		 *
-		 * If we don't got one, we could initiate a scan and look
-		 * for the best matching cfg80211_bss entry.
-		 *
-		 * Or, better yet, net/wireless/sme.c get's rewritten into
-		 * something more generally useful.
+	if (!sme->bssid) {
+		/* Run a scan if one isn't in-progress already and if the last
+		 * scan was done more than 2 seconds ago.
 		 */
-		lbs_pr_err("TODO: no BSS specified\n");
-		ret = -ENOTSUPP;
-		goto done;
-	}
+		if (priv->scan_req == NULL &&
+		    time_after(jiffies, priv->last_scan + (2 * HZ))) {
+			struct cfg80211_scan_request *creq;
 
+			creq = _new_connect_scan_req(wiphy, sme);
+			if (!creq) {
+				ret = -EINVAL;
+				goto done;
+			}
+
+			lbs_deb_assoc("assoc: scanning for compatible AP\n");
+			_internal_start_scan(priv, true, creq);
+		}
+
+		/* Wait for any in-progress scan to complete */
+		lbs_deb_assoc("assoc: waiting for scan to complete\n");
+		wait_event_interruptible_timeout(priv->scan_q,
+						 (priv->scan_req == NULL),
+						 (15 * HZ));
+		lbs_deb_assoc("assoc: scanning competed\n");
+	}
 
+	/* Find the BSS we want using available scan results */
+	bss = cfg80211_get_bss(wiphy, sme->channel, sme->bssid,
+		sme->ssid, sme->ssid_len,
+		WLAN_CAPABILITY_ESS, WLAN_CAPABILITY_ESS);
 	if (!bss) {
-		lbs_pr_err("assicate: bss %pM not in scan results\n",
+		lbs_pr_err("assoc: bss %pM not in scan results\n",
 			   sme->bssid);
 		ret = -ENOENT;
 		goto done;
 	}
-	lbs_deb_assoc("trying %pM", sme->bssid);
+	lbs_deb_assoc("trying %pM\n", bss->bssid);
 	lbs_deb_assoc("cipher 0x%x, key index %d, key len %d\n",
 		      sme->crypto.cipher_group,
 		      sme->key_idx, sme->key_len);
@@ -1229,7 +1343,7 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
 	lbs_set_radio(priv, preamble, 1);
 
 	/* Do the actual association */
-	lbs_associate(priv, bss, sme);
+	ret = lbs_associate(priv, bss, sme);
 
  done:
 	if (bss)
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index 3c7e255..f062ed5 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -161,6 +161,11 @@ struct lbs_private {
 	/** Scanning */
 	struct delayed_work scan_work;
 	int scan_channel;
+	/* Queue of things waiting for scan completion */
+	wait_queue_head_t scan_q;
+	/* Whether the scan was initiated internally and not by cfg80211 */
+	bool internal_scan;
+	unsigned long last_scan;
 };
 
 extern struct cmd_confirm_sleep confirm_sleep;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 2589671..24958a8 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -719,6 +719,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
 	priv->deep_sleep_required = 0;
 	priv->wakeup_dev_required = 0;
 	init_waitqueue_head(&priv->ds_awake_q);
+	init_waitqueue_head(&priv->scan_q);
 	priv->authtype_auto = 1;
 	priv->is_host_sleep_configured = 0;
 	priv->is_host_sleep_activated = 0;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 822f8dc..71a101f 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -43,6 +43,8 @@ static DEFINE_PCI_DEVICE_TABLE(p54p_table) = {
 	{ PCI_DEVICE(0x1260, 0x3886) },
 	/* Intersil PRISM Xbow Wireless LAN adapter (Symbol AP-300) */
 	{ PCI_DEVICE(0x1260, 0xffff) },
+	/* Standard Microsystems Corp SMC2802W Wireless PCI */
+	{ PCI_DEVICE(0x10b8, 0x2802) },
 	{ },
 };
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 19b262e..63c2cc4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -240,16 +240,16 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	struct rt2x00_dev *rt2x00dev;
 	int retval;
 
-	retval = pci_request_regions(pci_dev, pci_name(pci_dev));
+	retval = pci_enable_device(pci_dev);
 	if (retval) {
-		ERROR_PROBE("PCI request regions failed.\n");
+		ERROR_PROBE("Enable device failed.\n");
 		return retval;
 	}
 
-	retval = pci_enable_device(pci_dev);
+	retval = pci_request_regions(pci_dev, pci_name(pci_dev));
 	if (retval) {
-		ERROR_PROBE("Enable device failed.\n");
-		goto exit_release_regions;
+		ERROR_PROBE("PCI request regions failed.\n");
+		goto exit_disable_device;
 	}
 
 	pci_set_master(pci_dev);
@@ -260,14 +260,14 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32))) {
 		ERROR_PROBE("PCI DMA not supported.\n");
 		retval = -EIO;
-		goto exit_disable_device;
+		goto exit_release_regions;
 	}
 
 	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
 		ERROR_PROBE("Failed to allocate hardware.\n");
 		retval = -ENOMEM;
-		goto exit_disable_device;
+		goto exit_release_regions;
 	}
 
 	pci_set_drvdata(pci_dev, hw);
@@ -300,13 +300,12 @@ exit_free_reg:
 exit_free_device:
 	ieee80211_free_hw(hw);
 
-exit_disable_device:
-	if (retval != -EBUSY)
-		pci_disable_device(pci_dev);
-
 exit_release_regions:
 	pci_release_regions(pci_dev);
 
+exit_disable_device:
+	pci_disable_device(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return retval;
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index 1d81785..b50c39a 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -695,6 +695,8 @@ static void rtl8180_beacon_work(struct work_struct *work)
 
 	/* grab a fresh beacon */
 	skb = ieee80211_beacon_get(dev, vif);
+	if (!skb)
+		goto resched;
 
 	/*
 	 * update beacon timestamp w/ TSF value
diff --git a/drivers/net/wireless/wl12xx/wl1271_spi.c b/drivers/net/wireless/wl12xx/wl1271_spi.c
index 96d25fb..4cb99c5 100644
--- a/drivers/net/wireless/wl12xx/wl1271_spi.c
+++ b/drivers/net/wireless/wl12xx/wl1271_spi.c
@@ -160,9 +160,8 @@ static void wl1271_spi_init(struct wl1271 *wl)
 	spi_message_add_tail(&t, &m);
 
 	spi_sync(wl_to_spi(wl), &m);
-	kfree(cmd);
-
 	wl1271_dump(DEBUG_SPI, "spi init -> ", cmd, WSPI_INIT_CMD_LEN);
+	kfree(cmd);
 }
 
 #define WL1271_BUSY_WORD_TIMEOUT 1000
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 8b28962..4568b93 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -132,7 +132,7 @@ struct hci_dev {
 
 	struct inquiry_cache	inq_cache;
 	struct hci_conn_hash	conn_hash;
-	struct bdaddr_list	blacklist;
+	struct list_head	blacklist;
 
 	struct hci_dev_stats	stat;
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 8303f1c..c52f091 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -924,7 +924,7 @@ int hci_register_dev(struct hci_dev *hdev)
 
 	hci_conn_hash_init(hdev);
 
-	INIT_LIST_HEAD(&hdev->blacklist.list);
+	INIT_LIST_HEAD(&hdev->blacklist);
 
 	memset(&hdev->stat, 0, sizeof(struct hci_dev_stats));
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 4f170a5..83acd16 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -168,9 +168,8 @@ static int hci_sock_release(struct socket *sock)
 struct bdaddr_list *hci_blacklist_lookup(struct hci_dev *hdev, bdaddr_t *bdaddr)
 {
 	struct list_head *p;
-	struct bdaddr_list *blacklist = &hdev->blacklist;
 
-	list_for_each(p, &blacklist->list) {
+	list_for_each(p, &hdev->blacklist) {
 		struct bdaddr_list *b;
 
 		b = list_entry(p, struct bdaddr_list, list);
@@ -202,7 +201,7 @@ static int hci_blacklist_add(struct hci_dev *hdev, void __user *arg)
 
 	bacpy(&entry->bdaddr, &bdaddr);
 
-	list_add(&entry->list, &hdev->blacklist.list);
+	list_add(&entry->list, &hdev->blacklist);
 
 	return 0;
 }
@@ -210,9 +209,8 @@ static int hci_blacklist_add(struct hci_dev *hdev, void __user *arg)
 int hci_blacklist_clear(struct hci_dev *hdev)
 {
 	struct list_head *p, *n;
-	struct bdaddr_list *blacklist = &hdev->blacklist;
 
-	list_for_each_safe(p, n, &blacklist->list) {
+	list_for_each_safe(p, n, &hdev->blacklist) {
 		struct bdaddr_list *b;
 
 		b = list_entry(p, struct bdaddr_list, list);
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index ce44c47..8fb967b 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -439,12 +439,11 @@ static const struct file_operations inquiry_cache_fops = {
 static int blacklist_show(struct seq_file *f, void *p)
 {
 	struct hci_dev *hdev = f->private;
-	struct bdaddr_list *blacklist = &hdev->blacklist;
 	struct list_head *l;
 
 	hci_dev_lock_bh(hdev);
 
-	list_for_each(l, &blacklist->list) {
+	list_for_each(l, &hdev->blacklist) {
 		struct bdaddr_list *b;
 		bdaddr_t bdaddr;
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 9ba1e8e..3e3cd9d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2527,6 +2527,10 @@ done:
 		if (pi->imtu != L2CAP_DEFAULT_MTU)
 			l2cap_add_conf_opt(&ptr, L2CAP_CONF_MTU, 2, pi->imtu);
 
+		if (!(pi->conn->feat_mask & L2CAP_FEAT_ERTM) &&
+				!(pi->conn->feat_mask & L2CAP_FEAT_STREAMING))
+			break;
+
 		rfc.mode            = L2CAP_MODE_BASIC;
 		rfc.txwin_size      = 0;
 		rfc.max_transmit    = 0;
@@ -2534,6 +2538,8 @@ done:
 		rfc.monitor_timeout = 0;
 		rfc.max_pdu_size    = 0;
 
+		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC, sizeof(rfc),
+							(unsigned long) &rfc);
 		break;
 
 	case L2CAP_MODE_ERTM:
@@ -2546,6 +2552,9 @@ done:
 		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
 			rfc.max_pdu_size = cpu_to_le16(pi->conn->mtu - 10);
 
+		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC, sizeof(rfc),
+							(unsigned long) &rfc);
+
 		if (!(pi->conn->feat_mask & L2CAP_FEAT_FCS))
 			break;
 
@@ -2566,6 +2575,9 @@ done:
 		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
 			rfc.max_pdu_size = cpu_to_le16(pi->conn->mtu - 10);
 
+		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC, sizeof(rfc),
+							(unsigned long) &rfc);
+
 		if (!(pi->conn->feat_mask & L2CAP_FEAT_FCS))
 			break;
 
@@ -2577,9 +2589,6 @@ done:
 		break;
 	}
 
-	l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC, sizeof(rfc),
-						(unsigned long) &rfc);
-
 	/* FIXME: Need actual value of the flush timeout */
 	//if (flush_to != L2CAP_DEFAULT_FLUSH_TO)
 	//   l2cap_add_conf_opt(&ptr, L2CAP_CONF_FLUSH_TO, 2, pi->flush_to);
@@ -3339,6 +3348,15 @@ static inline int l2cap_information_rsp(struct l2cap_conn *conn, struct l2cap_cm
 
 	del_timer(&conn->info_timer);
 
+	if (result != L2CAP_IR_SUCCESS) {
+		conn->info_state |= L2CAP_INFO_FEAT_MASK_REQ_DONE;
+		conn->info_ident = 0;
+
+		l2cap_conn_start(conn);
+
+		return 0;
+	}
+
 	if (type == L2CAP_IT_FEAT_MASK) {
 		conn->feat_mask = get_unaligned_le32(rsp->data);
 
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 026205c..befc3a5 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -1183,7 +1183,7 @@ int __init rfcomm_init_ttys(void)
 	return 0;
 }
 
-void __exit rfcomm_cleanup_ttys(void)
+void rfcomm_cleanup_ttys(void)
 {
 	tty_unregister_driver(rfcomm_tty_driver);
 	put_tty_driver(rfcomm_tty_driver);
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 7cc4f91..798a91b 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -685,10 +685,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	return 0;
 
+#ifdef CONFIG_INET
  fail_ifa:
 	pm_qos_remove_notifier(PM_QOS_NETWORK_LATENCY,
 			       &local->network_latency_notifier);
 	rtnl_lock();
+#endif
  fail_pm_qos:
 	ieee80211_led_exit(local);
 	ieee80211_remove_interfaces(local);
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 41f20fb..872d7b6 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -400,19 +400,7 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 	else
 		__set_bit(SCAN_SW_SCANNING, &local->scanning);
 
-	/*
-	 * Kicking off the scan need not be protected,
-	 * only the scan variable stuff, since now
-	 * local->scan_req is assigned and other callers
-	 * will abort their scan attempts.
-	 *
-	 * This avoids too many locking dependencies
-	 * so that the scan completed calls have more
-	 * locking freedom.
-	 */
-
 	ieee80211_recalc_idle(local);
-	mutex_unlock(&local->scan_mtx);
 
 	if (local->ops->hw_scan) {
 		WARN_ON(!ieee80211_prep_hw_scan(local));
@@ -420,8 +408,6 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 	} else
 		rc = ieee80211_start_sw_scan(local);
 
-	mutex_lock(&local->scan_mtx);
-
 	if (rc) {
 		kfree(local->hw_scan_req);
 		local->hw_scan_req = NULL;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
