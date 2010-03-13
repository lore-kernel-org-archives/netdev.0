From: Steven Harms <sjharms@gmail.com>
Subject: [PATCH] NET: tg3: fix brace, switch, and comma spacing coding style in tg3.c This is a patch to the tg3.c file that aligns switch and case statements, else statements following braces, and inserts a space after commas listed in the coding style guidelines and verified by checkpatch.pl tool.
Date: Sat, 13 Mar 2010 14:39:11 -0500
Message-ID: <1268509151-27281-1-git-send-email-sharms@ubuntu.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sharms@ubuntu.com
To: mcarlson@broadcom.com, mchan@broadcom.com, davem@davemloft.net,
	benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:52421 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935476Ab0CMTjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 14:39:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/tg3.c |   60 +++++++++++++++++++++++-----------------------------
 1 files changed, 27 insertions(+), 33 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fa7688..02e6326 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -496,16 +496,16 @@ static void tg3_write32_mbox_5906(struct tg3 *tp, u32 off, u32 val)
 	writel(val, tp->regs + off + GRCMBOX_BASE);
 }
 
-#define tw32_mailbox(reg, val)	tp->write32_mbox(tp, reg, val)
-#define tw32_mailbox_f(reg, val)	tw32_mailbox_flush(tp, (reg), (val))
-#define tw32_rx_mbox(reg, val)	tp->write32_rx_mbox(tp, reg, val)
-#define tw32_tx_mbox(reg, val)	tp->write32_tx_mbox(tp, reg, val)
-#define tr32_mailbox(reg)	tp->read32_mbox(tp, reg)
+#define tw32_mailbox(reg, val)	(tp->write32_mbox(tp, reg, val))
+#define tw32_mailbox_f(reg, val)	(tw32_mailbox_flush(tp, (reg), (val)))
+#define tw32_rx_mbox(reg, val)	(tp->write32_rx_mbox(tp, reg, val))
+#define tw32_tx_mbox(reg, val)	(tp->write32_tx_mbox(tp, reg, val))
+#define tr32_mailbox(reg)	(tp->read32_mbox(tp, reg))
 
-#define tw32(reg,val)		tp->write32(tp, reg, val)
-#define tw32_f(reg,val)		_tw32_flush(tp,(reg),(val), 0)
-#define tw32_wait_f(reg,val,us)	_tw32_flush(tp,(reg),(val), (us))
-#define tr32(reg)		tp->read32(tp, reg)
+#define tw32(reg, val)		(tp->write32(tp, (reg), (val)))
+#define tw32_f(reg, val)		(_tw32_flush(tp, (reg), (val), 0))
+#define tw32_wait_f(reg, val, us)	(_tw32_flush(tp, (reg), (val), (us)))
+#define tr32(reg)		(tp->read32(tp, reg))
 
 static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 {
@@ -579,11 +579,11 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 		return 0;
 
 	switch (locknum) {
-		case TG3_APE_LOCK_GRC:
-		case TG3_APE_LOCK_MEM:
-			break;
-		default:
-			return -EINVAL;
+	case TG3_APE_LOCK_GRC:
+	case TG3_APE_LOCK_MEM:
+		break;
+	default:
+		return -EINVAL;
 	}
 
 	off = 4 * locknum;
@@ -617,11 +617,11 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 		return;
 
 	switch (locknum) {
-		case TG3_APE_LOCK_GRC:
-		case TG3_APE_LOCK_MEM:
-			break;
-		default:
-			return;
+	case TG3_APE_LOCK_GRC:
+	case TG3_APE_LOCK_MEM:
+		break;
+	default:
+		return;
 	}
 
 	off = 4 * locknum;
@@ -1855,8 +1855,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
 		/* Set Extended packet length bit for jumbo frames */
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4400);
-	}
-	else {
+	} else {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	}
 
@@ -1974,8 +1973,7 @@ out:
 		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x401f);
 		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x14e2);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
-	}
-	else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
+	} else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
 		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
 		if (tp->tg3_flags2 & TG3_FLG2_PHY_ADJUST_TRIM) {
@@ -3425,7 +3423,7 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 	ap->rxconfig = rx_cfg_reg;
 	ret = ANEG_OK;
 
-	switch(ap->state) {
+	switch (ap->state) {
 	case ANEG_STATE_UNKNOWN:
 		if (ap->flags & (MR_AN_ENABLE | MR_RESTART_AN))
 			ap->state = ANEG_STATE_AN_ENABLE;
@@ -3463,11 +3461,10 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 		/* fallthru */
 	case ANEG_STATE_RESTART:
 		delta = ap->cur_time - ap->link_time;
-		if (delta > ANEG_STATE_SETTLE_TIME) {
+		if (delta > ANEG_STATE_SETTLE_TIME)
 			ap->state = ANEG_STATE_ABILITY_DETECT_INIT;
-		} else {
+		else
 			ret = ANEG_TIMER_ENAB;
-		}
 		break;
 
 	case ANEG_STATE_DISABLE_LINK_OK:
@@ -3491,9 +3488,8 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 		break;
 
 	case ANEG_STATE_ABILITY_DETECT:
-		if (ap->ability_match != 0 && ap->rxconfig != 0) {
+		if (ap->ability_match != 0 && ap->rxconfig != 0)
 			ap->state = ANEG_STATE_ACK_DETECT_INIT;
-		}
 		break;
 
 	case ANEG_STATE_ACK_DETECT_INIT:
@@ -4171,8 +4167,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
-			}
-			else
+			} else
 				current_link_up = 0;
 		}
 	}
@@ -4240,8 +4235,7 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 				tp->tg3_flags2 |= TG3_FLG2_PARALLEL_DETECT;
 			}
 		}
-	}
-	else if (netif_carrier_ok(tp->dev) &&
+	} else if (netif_carrier_ok(tp->dev) &&
 		 (tp->link_config.autoneg == AUTONEG_ENABLE) &&
 		 (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
 		u32 phy2;
-- 
1.6.3.3

