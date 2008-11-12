From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/5] bnx2: Reorganize timeout constants.
Date: Wed, 12 Nov 2008 15:10:03 -0800
Message-ID: <1226531404-26118-4-git-send-email-mchan@broadcom.com>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4067 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbYKLXDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 18:03:49 -0500
In-Reply-To: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all related timeout constants to the same location.  BNX2
prefix is also added to make them more consistent.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    8 ++++----
 drivers/net/bnx2.h |   14 +++++++-------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a52ffdc..84563b0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1656,7 +1656,7 @@ bnx2_setup_serdes_phy(struct bnx2 *bp, u8 port)
 		 * exchanging base pages plus 3 next pages and
 		 * normally completes in about 120 msec.
 		 */
-		bp->current_interval = SERDES_AN_TIMEOUT;
+		bp->current_interval = BNX2_SERDES_AN_TIMEOUT;
 		bp->serdes_an_pending = 1;
 		mod_timer(&bp->timer, jiffies + bp->current_interval);
 	} else {
@@ -2278,7 +2278,7 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 		return 0;
 
 	/* wait for an acknowledgement. */
-	for (i = 0; i < (FW_ACK_TIME_OUT_MS / 10); i++) {
+	for (i = 0; i < (BNX2_FW_ACK_TIME_OUT_MS / 10); i++) {
 		msleep(10);
 
 		val = bnx2_shmem_rd(bp, BNX2_FW_MB);
@@ -5705,7 +5705,7 @@ bnx2_5708_serdes_timer(struct bnx2 *bp)
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		if (bmcr & BMCR_ANENABLE) {
 			bnx2_enable_forced_2g5(bp);
-			bp->current_interval = SERDES_FORCED_TIMEOUT;
+			bp->current_interval = BNX2_SERDES_FORCED_TIMEOUT;
 		} else {
 			bnx2_disable_forced_2g5(bp);
 			bp->serdes_an_pending = 2;
@@ -6522,7 +6522,7 @@ bnx2_nway_reset(struct net_device *dev)
 
 		spin_lock_bh(&bp->phy_lock);
 
-		bp->current_interval = SERDES_AN_TIMEOUT;
+		bp->current_interval = BNX2_SERDES_AN_TIMEOUT;
 		bp->serdes_an_pending = 1;
 		mod_timer(&bp->timer, jiffies + bp->current_interval);
 	}
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 2b9649a..34ca478 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6679,8 +6679,6 @@ struct bnx2_napi {
 	struct bnx2_tx_ring_info	tx_ring;
 };
 
-#define BNX2_TIMER_INTERVAL			HZ
-
 struct bnx2 {
 	/* Fields used in the tx and intr/napi performance paths are grouped */
 	/* together in the beginning of the structure. */
@@ -6728,7 +6726,11 @@ struct bnx2 {
 
 	/* End of fields used in the performance code paths. */
 
-	int			current_interval;
+	unsigned int		current_interval;
+#define BNX2_TIMER_INTERVAL		HZ
+#define BNX2_SERDES_AN_TIMEOUT		(HZ / 3)
+#define BNX2_SERDES_FORCED_TIMEOUT	(HZ / 10)
+
 	struct			timer_list timer;
 	struct work_struct	reset_task;
 
@@ -6860,8 +6862,6 @@ struct bnx2 {
 #define PHY_LOOPBACK		2
 
 	u8			serdes_an_pending;
-#define SERDES_AN_TIMEOUT	(HZ / 3)
-#define SERDES_FORCED_TIMEOUT	(HZ / 10)
 
 	u8			mac_addr[8];
 
@@ -6959,14 +6959,14 @@ struct fw_info {
 /* This value (in milliseconds) determines the frequency of the driver
  * issuing the PULSE message code.  The firmware monitors this periodic
  * pulse to determine when to switch to an OS-absent mode. */
-#define DRV_PULSE_PERIOD_MS                 250
+#define BNX2_DRV_PULSE_PERIOD_MS                 250
 
 /* This value (in milliseconds) determines how long the driver should
  * wait for an acknowledgement from the firmware before timing out.  Once
  * the firmware has timed out, the driver will assume there is no firmware
  * running and there won't be any firmware-driver synchronization during a
  * driver reset. */
-#define FW_ACK_TIME_OUT_MS                  1000
+#define BNX2_FW_ACK_TIME_OUT_MS                  1000
 
 
 #define BNX2_DRV_RESET_SIGNATURE		0x00000000
-- 
1.5.6.GIT


