From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] drivers/net/wireless/ath5k - convert == (true|false) to
	simple logical tests
Date: Fri, 07 Mar 2008 14:21:16 -0800
Message-ID: <1204928476.5541.92.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(test == true) is not nice.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

 drivers/net/wireless/ath5k/hw.c  |   42 +++++++++++++++++++-------------------
 drivers/net/wireless/ath5k/phy.c |   10 ++++----
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index c2de2d9..e214a2f 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -1,4 +1,4 @@
- /*
+/*
  * Copyright (c) 2004-2007 Reyk Floeter <reyk-7YlrpqBBQ3VAfugRpC6u6w@public.gmane.org>
  * Copyright (c) 2006-2007 Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
  * Copyright (c) 2007 Matthew W. S. Bell  <mentor-b3NiPy265MhAfugRpC6u6w@public.gmane.org>
@@ -81,12 +81,12 @@ static int ath5k_hw_disable_pspoll(struct ath5k_hw *);
 
 static inline unsigned int ath5k_hw_htoclock(unsigned int usec, bool turbo)
 {
-	return turbo == true ? (usec * 80) : (usec * 40);
+	return turbo ? (usec * 80) : (usec * 40);
 }
 
 static inline unsigned int ath5k_hw_clocktoh(unsigned int clock, bool turbo)
 {
-	return turbo == true ? (clock / 80) : (clock / 40);
+	return turbo ? (clock / 80) : (clock / 40);
 }
 
 /*
@@ -100,7 +100,7 @@ int ath5k_hw_register_timeout(struct ath5k_hw *ah, u32 reg, u32 flag, u32 val,
 
 	for (i = AR5K_TUNE_REGISTER_TIMEOUT; i > 0; i--) {
 		data = ath5k_hw_reg_read(ah, reg);
-		if ((is_set == true) && (data & flag))
+		if (is_set && (data & flag))
 			break;
 		else if ((data & flag) == val)
 			break;
@@ -358,7 +358,7 @@ static int ath5k_hw_nic_wakeup(struct ath5k_hw *ah, int flags, bool initial)
 	}
 
 	/* ...reset chipset and PCI device */
-	if (ah->ah_single_chip == false && ath5k_hw_nic_reset(ah,
+	if (!ah->ah_single_chip && ath5k_hw_nic_reset(ah,
 				AR5K_RESET_CTL_CHIP | AR5K_RESET_CTL_PCI)) {
 		ATH5K_ERR(ah->ah_sc, "failed to reset the MAC Chip + PCI\n");
 		return -EIO;
@@ -583,7 +583,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 	 */
 	/*DCU/Antenna selection not available on 5210*/
 	if (ah->ah_version != AR5K_AR5210) {
-		if (change_channel == true) {
+		if (change_channel) {
 			/* Seq number for queue 0 -do this for all queues ? */
 			s_seq = ath5k_hw_reg_read(ah,
 					AR5K_QUEUE_DFS_SEQNUM(0));
@@ -597,7 +597,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah, enum ieee80211_if_types op_mode,
 	s_led[1] = ath5k_hw_reg_read(ah, AR5K_GPIOCR);
 	s_led[2] = ath5k_hw_reg_read(ah, AR5K_GPIODO);
 
-	if (change_channel == true && ah->ah_rf_banks != NULL)
+	if (change_channel && ah->ah_rf_banks != NULL)
 		ath5k_hw_get_rf_gain(ah);
 
 
@@ -1063,7 +1063,7 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 		staid &= ~AR5K_STA_ID1_DEFAULT_ANTENNA;
 		/* fallthrough */
 	case AR5K_PM_NETWORK_SLEEP:
-		if (set_chip == true)
+		if (set_chip)
 			ath5k_hw_reg_write(ah,
 				AR5K_SLEEP_CTL_SLE | sleep_duration,
 				AR5K_SLEEP_CTL);
@@ -1072,7 +1072,7 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 		break;
 
 	case AR5K_PM_FULL_SLEEP:
-		if (set_chip == true)
+		if (set_chip)
 			ath5k_hw_reg_write(ah, AR5K_SLEEP_CTL_SLE_SLP,
 				AR5K_SLEEP_CTL);
 
@@ -1080,7 +1080,7 @@ int ath5k_hw_set_power(struct ath5k_hw *ah, enum ath5k_power_mode mode,
 		break;
 
 	case AR5K_PM_AWAKE:
-		if (set_chip == false)
+		if (!set_chip)
 			goto commit;
 
 		ath5k_hw_reg_write(ah, AR5K_SLEEP_CTL_SLE_WAKE,
@@ -1387,7 +1387,7 @@ int ath5k_hw_update_tx_triglevel(struct ath5k_hw *ah, bool increase)
 	trigger_level = AR5K_REG_MS(ath5k_hw_reg_read(ah, AR5K_TXCFG),
 			AR5K_TXCFG_TXFULL);
 
-	if (increase == false) {
+	if (!increase) {
 		if (--trigger_level < AR5K_TUNE_MIN_TX_FIFO_THRES)
 			goto done;
 	} else
@@ -2051,7 +2051,7 @@ static bool ath5k_eeprom_regulation_domain(struct ath5k_hw *ah, bool write,
 	u16 ee_regdomain;
 
 	/* Read current value */
-	if (write != true) {
+	if (!write) {
 		ee_regdomain = ah->ah_capabilities.cap_eeprom.ee_regdomain;
 		*regdomain = ath5k_regdom_to_ieee(ee_regdomain);
 		return true;
@@ -2080,7 +2080,7 @@ int ath5k_hw_set_regdomain(struct ath5k_hw *ah, u16 regdomain)
 
 	ieee_regdomain = ath5k_regdom_to_ieee(regdomain);
 
-	if (ath5k_eeprom_regulation_domain(ah, true, &ieee_regdomain) == true)
+	if (ath5k_eeprom_regulation_domain(ah, true, &ieee_regdomain))
 		return 0;
 
 	return -EIO;
@@ -3184,19 +3184,19 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
 			return 0;
 
 		/* Set Slot time */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			AR5K_INIT_SLOT_TIME_TURBO : AR5K_INIT_SLOT_TIME,
 			AR5K_SLOT_TIME);
 		/* Set ACK_CTS timeout */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			AR5K_INIT_ACK_CTS_TIMEOUT_TURBO :
 			AR5K_INIT_ACK_CTS_TIMEOUT, AR5K_SLOT_TIME);
 		/* Set Transmit Latency */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			AR5K_INIT_TRANSMIT_LATENCY_TURBO :
 			AR5K_INIT_TRANSMIT_LATENCY, AR5K_USEC_5210);
 		/* Set IFS0 */
-		if (ah->ah_turbo == true)
+		if (ah->ah_turbo)
 			 ath5k_hw_reg_write(ah, ((AR5K_INIT_SIFS_TURBO +
 				(ah->ah_aifs + tq->tqi_aifs) *
 				AR5K_INIT_SLOT_TIME_TURBO) <<
@@ -3209,16 +3209,16 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
 				AR5K_INIT_SIFS, AR5K_IFS0);
 
 		/* Set IFS1 */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			AR5K_INIT_PROTO_TIME_CNTRL_TURBO :
 			AR5K_INIT_PROTO_TIME_CNTRL, AR5K_IFS1);
 		/* Set PHY register 0x9844 (??) */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			(ath5k_hw_reg_read(ah, AR5K_PHY(17)) & ~0x7F) | 0x38 :
 			(ath5k_hw_reg_read(ah, AR5K_PHY(17)) & ~0x7F) | 0x1C,
 			AR5K_PHY(17));
 		/* Set Frame Control Register */
-		ath5k_hw_reg_write(ah, ah->ah_turbo == true ?
+		ath5k_hw_reg_write(ah, ah->ah_turbo ?
 			(AR5K_PHY_FRAME_CTL_INI | AR5K_PHY_TURBO_MODE |
 			AR5K_PHY_TURBO_SHORT | 0x2020) :
 			(AR5K_PHY_FRAME_CTL_INI | 0x1020),
@@ -3257,7 +3257,7 @@ int ath5k_hw_reset_tx_queue(struct ath5k_hw *ah, unsigned int queue)
 	/*
 	 * Calculate and set retry limits
 	 */
-	if (ah->ah_software_retry == true) {
+	if (ah->ah_software_retry) {
 		/* XXX Need to test this */
 		retry_lg = ah->ah_limit_tx_retries;
 		retry_sh = retry_lg = retry_lg > AR5K_DCU_RETRY_LMT_SH_RETRY ?
diff --git a/drivers/net/wireless/ath5k/phy.c b/drivers/net/wireless/ath5k/phy.c
index b959417..a0e4fdf 100644
--- a/drivers/net/wireless/ath5k/phy.c
+++ b/drivers/net/wireless/ath5k/phy.c
@@ -844,14 +844,14 @@ static unsigned int ath5k_hw_rfregs_op(u32 *rf, u32 offset, u32 reg, u32 bits,
 	entry = ((first - 1) / 8) + offset;
 	position = (first - 1) % 8;
 
-	if (set == true)
+	if (set)
 		data = ath5k_hw_bitswap(reg, bits);
 
 	for (i = shift = 0, left = bits; left > 0; position = 0, entry++, i++) {
 		last = (position + left > 8) ? 8 : position + left;
 		mask = (((1 << last) - 1) ^ ((1 << position) - 1)) << (col * 8);
 
-		if (set == true) {
+		if (set) {
 			rf[entry] &= ~mask;
 			rf[entry] |= ((data << position) << (col * 8)) & mask;
 			data >>= (8 - position);
@@ -864,7 +864,7 @@ static unsigned int ath5k_hw_rfregs_op(u32 *rf, u32 offset, u32 reg, u32 bits,
 		left -= 8 - position;
 	}
 
-	data = set == true ? 1 : ath5k_hw_bitswap(data, bits);
+	data = set ? 1 : ath5k_hw_bitswap(data, bits);
 
 	return data;
 }
@@ -1825,7 +1825,7 @@ static int ath5k_hw_rf511x_calibrate(struct ath5k_hw *ah,
 	s32 iq_corr, i_coff, i_coffd, q_coff, q_coffd;
 	ATH5K_TRACE(ah->ah_sc);
 
-	if (ah->ah_calibration == false ||
+	if (!ah->ah_calibration ||
 			ath5k_hw_reg_read(ah, AR5K_PHY_IQ) & AR5K_PHY_IQ_RUN)
 		goto done;
 
@@ -2048,7 +2048,7 @@ ath5k_hw_txpower(struct ath5k_hw *ah, struct ieee80211_channel *channel,
 		AR5K_TXPOWER_CCK(13, 16) | AR5K_TXPOWER_CCK(12, 8) |
 		AR5K_TXPOWER_CCK(11, 0), AR5K_PHY_TXPOWER_RATE4);
 
-	if (ah->ah_txpower.txp_tpc == true)
+	if (ah->ah_txpower.txp_tpc)
 		ath5k_hw_reg_write(ah, AR5K_PHY_TXPOWER_RATE_MAX_TPC_ENABLE |
 			AR5K_TUNE_MAX_TXPOWER, AR5K_PHY_TXPOWER_RATE_MAX);
 	else


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
