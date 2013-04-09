From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] tg3: Use bool not int
Date: Tue, 09 Apr 2013 13:18:14 -0700
Message-ID: <1365538694.18072.8.camel@joe-AO722>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, mchan@broadcom.com
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56937 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S935895Ab3DIUSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 16:18:15 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using bool can make code more readable.

Convert uses and tests of int to bool.

This also makes a comparison of tg3->link_up
(itself bool) a bool comparison instead of int.

Reorder stack variable declarations to make
bool fit declaration holes where appropriate.

$ size drivers/net/ethernet/broadcom/tg3.o*
   text	   data	    bss	    dec	    hex	filename
 169958	  27249	  58896	 256103	  3e867	drivers/net/ethernet/broadcom/tg3.o.new
 169968	  27249	  58896	 256113	  3e871	drivers/net/ethernet/broadcom/tg3.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---

Reduces allyesconfig object size 10 bytes! (wow!!)

 drivers/net/ethernet/broadcom/tg3.c | 157 ++++++++++++++++++------------------
 1 file changed, 80 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0fe6444..ce98572 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2228,7 +2228,7 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 	tg3_writephy(tp, MII_TG3_MISC_SHDW, reg);
 }
 
-static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
+static void tg3_phy_toggle_automdix(struct tg3 *tp, bool enable)
 {
 	u32 phy;
 
@@ -2320,7 +2320,7 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 	tg3_phy_toggle_auxctl_smdsp(tp, false);
 }
 
-static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
+static void tg3_phy_eee_adjust(struct tg3 *tp, bool current_link_up)
 {
 	u32 val;
 
@@ -2330,7 +2330,7 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 	tp->setlpicnt = 0;
 
 	if (tp->link_config.autoneg == AUTONEG_ENABLE &&
-	    current_link_up == 1 &&
+	    current_link_up &&
 	    tp->link_config.active_duplex == DUPLEX_FULL &&
 	    (tp->link_config.active_speed == SPEED_100 ||
 	     tp->link_config.active_speed == SPEED_1000)) {
@@ -2352,7 +2352,7 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 	}
 
 	if (!tp->setlpicnt) {
-		if (current_link_up == 1 &&
+		if (current_link_up &&
 		   !tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0000);
 			tg3_phy_toggle_auxctl_smdsp(tp, false);
@@ -2705,7 +2705,7 @@ out:
 	if (tg3_chip_rev_id(tp) == CHIPREV_ID_5762_A0)
 		tg3_phydsp_write(tp, 0xffb, 0x4000);
 
-	tg3_phy_toggle_automdix(tp, 1);
+	tg3_phy_toggle_automdix(tp, true);
 	tg3_phy_set_wirespeed(tp);
 	return 0;
 }
@@ -3851,7 +3851,7 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 
 
 /* tp->lock is held. */
-static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
+static void __tg3_set_mac_addr(struct tg3 *tp, bool skip_mac_1)
 {
 	u32 addr_high, addr_low;
 	int i;
@@ -3914,7 +3914,7 @@ static int tg3_power_up(struct tg3 *tp)
 	return err;
 }
 
-static int tg3_setup_phy(struct tg3 *, int);
+static int tg3_setup_phy(struct tg3 *, bool);
 
 static int tg3_power_down_prepare(struct tg3 *tp)
 {
@@ -3986,7 +3986,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			tp->phy_flags |= TG3_PHYFLG_IS_LOW_POWER;
 
 		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
-			tg3_setup_phy(tp, 0);
+			tg3_setup_phy(tp, false);
 	}
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5906) {
@@ -4583,7 +4583,7 @@ static bool tg3_phy_copper_fetch_rmtadv(struct tg3 *tp, u32 *rmtadv)
 	return true;
 }
 
-static bool tg3_test_and_report_link_chg(struct tg3 *tp, int curr_link_up)
+static bool tg3_test_and_report_link_chg(struct tg3 *tp, bool curr_link_up)
 {
 	if (curr_link_up != tp->link_up) {
 		if (curr_link_up) {
@@ -4613,9 +4613,9 @@ static void tg3_clear_mac_status(struct tg3 *tp)
 	udelay(40);
 }
 
-static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
+static int tg3_setup_copper_phy(struct tg3 *tp, bool force_reset)
 {
-	int current_link_up;
+	bool current_link_up;
 	u32 bmsr, val;
 	u32 lcl_adv, rmt_adv;
 	u16 current_speed;
@@ -4642,7 +4642,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
 		    !(bmsr & BMSR_LSTATUS))
-			force_reset = 1;
+			force_reset = true;
 	}
 	if (force_reset)
 		tg3_phy_reset(tp);
@@ -4706,7 +4706,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 			tg3_writephy(tp, MII_TG3_EXT_CTRL, 0);
 	}
 
-	current_link_up = 0;
+	current_link_up = false;
 	current_speed = SPEED_UNKNOWN;
 	current_duplex = DUPLEX_UNKNOWN;
 	tp->phy_flags &= ~TG3_PHYFLG_MDIX_STATE;
@@ -4771,7 +4771,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 			    eee_config_ok &&
 			    tg3_phy_copper_an_config_ok(tp, &lcl_adv) &&
 			    tg3_phy_copper_fetch_rmtadv(tp, &rmt_adv))
-				current_link_up = 1;
+				current_link_up = true;
 
 			/* EEE settings changes take effect only after a phy
 			 * reset.  If we have skipped a reset due to Link Flap
@@ -4785,11 +4785,11 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
 			    tp->link_config.duplex == current_duplex) {
-				current_link_up = 1;
+				current_link_up = true;
 			}
 		}
 
-		if (current_link_up == 1 &&
+		if (current_link_up &&
 		    tp->link_config.active_duplex == DUPLEX_FULL) {
 			u32 reg, bit;
 
@@ -4809,11 +4809,11 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	}
 
 relink:
-	if (current_link_up == 0 || (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
+	if (!current_link_up || (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
 		tg3_phy_copper_begin(tp);
 
 		if (tg3_flag(tp, ROBOSWITCH)) {
-			current_link_up = 1;
+			current_link_up = true;
 			/* FIXME: when BCM5325 switch is used use 100 MBit/s */
 			current_speed = SPEED_1000;
 			current_duplex = DUPLEX_FULL;
@@ -4824,11 +4824,11 @@ relink:
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if ((!tg3_readphy(tp, MII_BMSR, &bmsr) && (bmsr & BMSR_LSTATUS)) ||
 		    (tp->mac_mode & MAC_MODE_PORT_INT_LPBACK))
-			current_link_up = 1;
+			current_link_up = true;
 	}
 
 	tp->mac_mode &= ~MAC_MODE_PORT_MODE_MASK;
-	if (current_link_up == 1) {
+	if (current_link_up) {
 		if (tp->link_config.active_speed == SPEED_100 ||
 		    tp->link_config.active_speed == SPEED_10)
 			tp->mac_mode |= MAC_MODE_PORT_MODE_MII;
@@ -4864,7 +4864,7 @@ relink:
 		tp->mac_mode |= MAC_MODE_HALF_DUPLEX;
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5700) {
-		if (current_link_up == 1 &&
+		if (current_link_up &&
 		    tg3_5700_link_polarity(tp, tp->link_config.active_speed))
 			tp->mac_mode |= MAC_MODE_LINK_POLARITY;
 		else
@@ -4895,7 +4895,7 @@ relink:
 	udelay(40);
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5700 &&
-	    current_link_up == 1 &&
+	    current_link_up &&
 	    tp->link_config.active_speed == SPEED_1000 &&
 	    (tg3_flag(tp, PCIX_MODE) || tg3_flag(tp, PCI_HIGH_SPEED))) {
 		udelay(120);
@@ -5335,19 +5335,19 @@ static void tg3_init_bcm8002(struct tg3 *tp)
 	tg3_writephy(tp, 0x10, 0x8011);
 }
 
-static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
+static bool tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 {
 	u16 flowctrl;
+	bool current_link_up;
 	u32 sg_dig_ctrl, sg_dig_status;
 	u32 serdes_cfg, expected_sg_dig_ctrl;
 	int workaround, port_a;
-	int current_link_up;
 
 	serdes_cfg = 0;
 	expected_sg_dig_ctrl = 0;
 	workaround = 0;
 	port_a = 1;
-	current_link_up = 0;
+	current_link_up = false;
 
 	if (tg3_chip_rev_id(tp) != CHIPREV_ID_5704_A0 &&
 	    tg3_chip_rev_id(tp) != CHIPREV_ID_5704_A1) {
@@ -5378,7 +5378,7 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 		}
 		if (mac_status & MAC_STATUS_PCS_SYNCED) {
 			tg3_setup_flow_control(tp, 0, 0);
-			current_link_up = 1;
+			current_link_up = true;
 		}
 		goto out;
 	}
@@ -5399,7 +5399,7 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 				    MAC_STATUS_RCVD_CFG)) ==
 		     MAC_STATUS_PCS_SYNCED)) {
 			tp->serdes_counter--;
-			current_link_up = 1;
+			current_link_up = true;
 			goto out;
 		}
 restart_autoneg:
@@ -5434,7 +5434,7 @@ restart_autoneg:
 					   mii_adv_to_ethtool_adv_x(remote_adv);
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
-			current_link_up = 1;
+			current_link_up = true;
 			tp->serdes_counter = 0;
 			tp->phy_flags &= ~TG3_PHYFLG_PARALLEL_DETECT;
 		} else if (!(sg_dig_status & SG_DIG_AUTONEG_COMPLETE)) {
@@ -5462,7 +5462,7 @@ restart_autoneg:
 				if ((mac_status & MAC_STATUS_PCS_SYNCED) &&
 				    !(mac_status & MAC_STATUS_RCVD_CFG)) {
 					tg3_setup_flow_control(tp, 0, 0);
-					current_link_up = 1;
+					current_link_up = true;
 					tp->phy_flags |=
 						TG3_PHYFLG_PARALLEL_DETECT;
 					tp->serdes_counter =
@@ -5480,9 +5480,9 @@ out:
 	return current_link_up;
 }
 
-static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
+static bool tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 {
-	int current_link_up = 0;
+	bool current_link_up = false;
 
 	if (!(mac_status & MAC_STATUS_PCS_SYNCED))
 		goto out;
@@ -5509,7 +5509,7 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 
-			current_link_up = 1;
+			current_link_up = true;
 		}
 		for (i = 0; i < 30; i++) {
 			udelay(20);
@@ -5524,15 +5524,15 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 		}
 
 		mac_status = tr32(MAC_STATUS);
-		if (current_link_up == 0 &&
+		if (!current_link_up &&
 		    (mac_status & MAC_STATUS_PCS_SYNCED) &&
 		    !(mac_status & MAC_STATUS_RCVD_CFG))
-			current_link_up = 1;
+			current_link_up = true;
 	} else {
 		tg3_setup_flow_control(tp, 0, 0);
 
 		/* Forcing 1000FD link up. */
-		current_link_up = 1;
+		current_link_up = true;
 
 		tw32_f(MAC_MODE, (tp->mac_mode | MAC_MODE_SEND_CONFIGS));
 		udelay(40);
@@ -5545,13 +5545,13 @@ out:
 	return current_link_up;
 }
 
-static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
+static int tg3_setup_fiber_phy(struct tg3 *tp, bool force_reset)
 {
 	u32 orig_pause_cfg;
 	u16 orig_active_speed;
 	u8 orig_active_duplex;
 	u32 mac_status;
-	int current_link_up;
+	bool current_link_up;
 	int i;
 
 	orig_pause_cfg = tp->link_config.active_flowctrl;
@@ -5588,7 +5588,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	tw32_f(MAC_EVENT, MAC_EVENT_LNKSTATE_CHANGED);
 	udelay(40);
 
-	current_link_up = 0;
+	current_link_up = false;
 	tp->link_config.rmt_adv = 0;
 	mac_status = tr32(MAC_STATUS);
 
@@ -5613,7 +5613,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 
 	mac_status = tr32(MAC_STATUS);
 	if ((mac_status & MAC_STATUS_PCS_SYNCED) == 0) {
-		current_link_up = 0;
+		current_link_up = false;
 		if (tp->link_config.autoneg == AUTONEG_ENABLE &&
 		    tp->serdes_counter == 0) {
 			tw32_f(MAC_MODE, (tp->mac_mode |
@@ -5623,7 +5623,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 		}
 	}
 
-	if (current_link_up == 1) {
+	if (current_link_up) {
 		tp->link_config.active_speed = SPEED_1000;
 		tp->link_config.active_duplex = DUPLEX_FULL;
 		tw32(MAC_LED_CTRL, (tp->led_ctrl |
@@ -5648,12 +5648,13 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	return 0;
 }
 
-static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
+static int tg3_setup_fiber_mii_phy(struct tg3 *tp, bool force_reset)
 {
-	int current_link_up = 0, err = 0;
+	int err = 0;
 	u32 bmsr, bmcr;
 	u16 current_speed = SPEED_UNKNOWN;
 	u8 current_duplex = DUPLEX_UNKNOWN;
+	bool current_link_up = false;
 	u32 local_adv, remote_adv, sgsr;
 
 	if ((tg3_asic_rev(tp) == ASIC_REV_5719 ||
@@ -5669,7 +5670,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 		if (!(sgsr & SERDES_TG3_LINK_UP)) {
 			tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
 		} else {
-			current_link_up = 1;
+			current_link_up = true;
 			if (sgsr & SERDES_TG3_SPEED_1000) {
 				current_speed = SPEED_1000;
 				tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
@@ -5789,7 +5790,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 
 	if (bmsr & BMSR_LSTATUS) {
 		current_speed = SPEED_1000;
-		current_link_up = 1;
+		current_link_up = true;
 		if (bmcr & BMCR_FULLDPLX)
 			current_duplex = DUPLEX_FULL;
 		else
@@ -5816,13 +5817,13 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 			} else if (!tg3_flag(tp, 5780_CLASS)) {
 				/* Link is up via parallel detect */
 			} else {
-				current_link_up = 0;
+				current_link_up = false;
 			}
 		}
 	}
 
 fiber_setup_done:
-	if (current_link_up == 1 && current_duplex == DUPLEX_FULL)
+	if (current_link_up && current_duplex == DUPLEX_FULL)
 		tg3_setup_flow_control(tp, local_adv, remote_adv);
 
 	tp->mac_mode &= ~MAC_MODE_HALF_DUPLEX;
@@ -5901,7 +5902,7 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 	}
 }
 
-static int tg3_setup_phy(struct tg3 *tp, int force_reset)
+static int tg3_setup_phy(struct tg3 *tp, bool force_reset)
 {
 	u32 val;
 	int err;
@@ -6802,7 +6803,7 @@ static void tg3_poll_link(struct tg3 *tp)
 				      MAC_STATUS_LNKSTATE_CHANGED));
 				udelay(40);
 			} else
-				tg3_setup_phy(tp, 0);
+				tg3_setup_phy(tp, false);
 			spin_unlock(&tp->lock);
 		}
 	}
@@ -7899,7 +7900,7 @@ static int tg3_phy_lpbk_set(struct tg3 *tp, u32 speed, bool extlpbk)
 	u32 val, bmcr, mac_mode, ptest = 0;
 
 	tg3_phy_toggle_apd(tp, false);
-	tg3_phy_toggle_automdix(tp, 0);
+	tg3_phy_toggle_automdix(tp, false);
 
 	if (extlpbk && tg3_phy_set_extloopbk(tp))
 		return -EIO;
@@ -8007,7 +8008,7 @@ static void tg3_set_loopback(struct net_device *dev, netdev_features_t features)
 		spin_lock_bh(&tp->lock);
 		tg3_mac_loopback(tp, false);
 		/* Force link status check */
-		tg3_setup_phy(tp, 1);
+		tg3_setup_phy(tp, true);
 		spin_unlock_bh(&tp->lock);
 		netdev_info(dev, "Internal MAC loopback mode disabled.\n");
 	}
@@ -8518,7 +8519,7 @@ err_out:
 /* To stop a block, clear the enable bit and poll till it
  * clears.  tp->lock is held.
  */
-static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int silent)
+static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, bool silent)
 {
 	unsigned int i;
 	u32 val;
@@ -8562,7 +8563,7 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int
 }
 
 /* tp->lock is held. */
-static int tg3_abort_hw(struct tg3 *tp, int silent)
+static int tg3_abort_hw(struct tg3 *tp, bool silent)
 {
 	int i, err;
 
@@ -8952,7 +8953,7 @@ static void tg3_get_nstats(struct tg3 *, struct rtnl_link_stats64 *);
 static void tg3_get_estats(struct tg3 *, struct tg3_ethtool_stats *);
 
 /* tp->lock is held. */
-static int tg3_halt(struct tg3 *tp, int kind, int silent)
+static int tg3_halt(struct tg3 *tp, int kind, bool silent)
 {
 	int err;
 
@@ -8963,7 +8964,7 @@ static int tg3_halt(struct tg3 *tp, int kind, int silent)
 	tg3_abort_hw(tp, silent);
 	err = tg3_chip_reset(tp);
 
-	__tg3_set_mac_addr(tp, 0);
+	__tg3_set_mac_addr(tp, false);
 
 	tg3_write_sig_legacy(tp, kind);
 	tg3_write_sig_post_reset(tp, kind);
@@ -8987,7 +8988,8 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	struct sockaddr *addr = p;
-	int err = 0, skip_mac_1 = 0;
+	int err = 0;
+	bool skip_mac_1 = false;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -9008,7 +9010,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 		/* Skip MAC addr 1 if ASF is using it. */
 		if ((addr0_high != addr1_high || addr0_low != addr1_low) &&
 		    !(addr1_high == 0 && addr1_low == 0))
-			skip_mac_1 = 1;
+			skip_mac_1 = true;
 	}
 	spin_lock_bh(&tp->lock);
 	__tg3_set_mac_addr(tp, skip_mac_1);
@@ -9427,7 +9429,7 @@ static void tg3_rss_write_indir_tbl(struct tg3 *tp)
 }
 
 /* tp->lock is held. */
-static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
+static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 {
 	u32 val, rdmac_mode;
 	int i, err, limit;
@@ -9820,7 +9822,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tg3_rings_reset(tp);
 
 	/* Initialize MAC address and backoff seed. */
-	__tg3_set_mac_addr(tp, 0);
+	__tg3_set_mac_addr(tp, false);
 
 	/* MTU + ethernet header + FCS + optional VLAN tag */
 	tw32(MAC_RX_MTU_SIZE,
@@ -10271,7 +10273,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
 			tp->phy_flags &= ~TG3_PHYFLG_IS_LOW_POWER;
 
-		err = tg3_setup_phy(tp, 0);
+		err = tg3_setup_phy(tp, false);
 		if (err)
 			return err;
 
@@ -10351,7 +10353,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 /* Called at device open time to get the chip ready for
  * packet processing.  Invoked with tp->lock held.
  */
-static int tg3_init_hw(struct tg3 *tp, int reset_phy)
+static int tg3_init_hw(struct tg3 *tp, bool reset_phy)
 {
 	tg3_switch_clocks(tp);
 
@@ -10612,7 +10614,7 @@ static void tg3_timer(unsigned long __opaque)
 				phy_event = 1;
 
 			if (phy_event)
-				tg3_setup_phy(tp, 0);
+				tg3_setup_phy(tp, false);
 		} else if (tg3_flag(tp, POLL_SERDES)) {
 			u32 mac_stat = tr32(MAC_STATUS);
 			int need_setup = 0;
@@ -10635,7 +10637,7 @@ static void tg3_timer(unsigned long __opaque)
 					tw32_f(MAC_MODE, tp->mac_mode);
 					udelay(40);
 				}
-				tg3_setup_phy(tp, 0);
+				tg3_setup_phy(tp, false);
 			}
 		} else if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
 			   tg3_flag(tp, 5780_CLASS)) {
@@ -10721,7 +10723,7 @@ static void tg3_timer_stop(struct tg3 *tp)
 /* Restart hardware after configuration changes, self-test, etc.
  * Invoked with tp->lock held.
  */
-static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
+static int tg3_restart_hw(struct tg3 *tp, bool reset_phy)
 	__releases(tp->lock)
 	__acquires(tp->lock)
 {
@@ -10771,7 +10773,7 @@ static void tg3_reset_task(struct work_struct *work)
 	}
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
-	err = tg3_init_hw(tp, 1);
+	err = tg3_init_hw(tp, true);
 	if (err)
 		goto out;
 
@@ -10941,7 +10943,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	tg3_full_lock(tp, 1);
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-	err = tg3_init_hw(tp, 1);
+	err = tg3_init_hw(tp, true);
 
 	tg3_full_unlock(tp);
 
@@ -11814,7 +11816,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	tg3_warn_mgmt_link_flap(tp);
 
 	if (netif_running(dev))
-		tg3_setup_phy(tp, 1);
+		tg3_setup_phy(tp, true);
 
 	tg3_full_unlock(tp);
 
@@ -11970,7 +11972,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		err = tg3_restart_hw(tp, 0);
+		err = tg3_restart_hw(tp, false);
 		if (!err)
 			tg3_netif_start(tp);
 	}
@@ -12094,7 +12096,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 
 		if (netif_running(dev)) {
 			tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-			err = tg3_restart_hw(tp, 0);
+			err = tg3_restart_hw(tp, false);
 			if (!err)
 				tg3_netif_start(tp);
 		}
@@ -13164,7 +13166,7 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 		goto done;
 	}
 
-	err = tg3_reset_hw(tp, 1);
+	err = tg3_reset_hw(tp, true);
 	if (err) {
 		data[TG3_MAC_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
 		data[TG3_PHY_LOOPB_TEST] = TG3_LOOPBACK_FAILED;
@@ -13331,7 +13333,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
 			tg3_flag_set(tp, INIT_COMPLETE);
-			err2 = tg3_restart_hw(tp, 1);
+			err2 = tg3_restart_hw(tp, true);
 			if (!err2)
 				tg3_netif_start(tp);
 		}
@@ -13648,7 +13650,8 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int err, reset_phy = 0;
+	int err;
+	bool reset_phy = false;
 
 	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
 		return -EINVAL;
@@ -13675,7 +13678,7 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 	 * breaks all requests to 256 bytes.
 	 */
 	if (tg3_asic_rev(tp) == ASIC_REV_57766)
-		reset_phy = 1;
+		reset_phy = true;
 
 	err = tg3_restart_hw(tp, reset_phy);
 
@@ -16575,7 +16578,7 @@ out:
 }
 
 static int tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dma,
-			   int size, int to_device)
+			   int size, bool to_device)
 {
 	struct tg3_internal_buffer_desc test_desc;
 	u32 sram_dma_descs;
@@ -16775,7 +16778,7 @@ static int tg3_test_dma(struct tg3 *tp)
 			p[i] = i;
 
 		/* Send the buffer to the chip. */
-		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, 1);
+		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, true);
 		if (ret) {
 			dev_err(&tp->pdev->dev,
 				"%s: Buffer write failed. err = %d\n",
@@ -16798,7 +16801,7 @@ static int tg3_test_dma(struct tg3 *tp)
 		}
 #endif
 		/* Now read it back. */
-		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, 0);
+		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, false);
 		if (ret) {
 			dev_err(&tp->pdev->dev, "%s: Buffer read failed. "
 				"err = %d\n", __func__, ret);
@@ -17479,7 +17482,7 @@ static int tg3_suspend(struct device *device)
 		tg3_full_lock(tp, 0);
 
 		tg3_flag_set(tp, INIT_COMPLETE);
-		err2 = tg3_restart_hw(tp, 1);
+		err2 = tg3_restart_hw(tp, true);
 		if (err2)
 			goto out;
 
@@ -17653,7 +17656,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 
 	tg3_full_lock(tp, 0);
 	tg3_flag_set(tp, INIT_COMPLETE);
-	err = tg3_restart_hw(tp, 1);
+	err = tg3_restart_hw(tp, true);
 	if (err) {
 		tg3_full_unlock(tp);
 		netdev_err(netdev, "Cannot restart hardware after reset.\n");
