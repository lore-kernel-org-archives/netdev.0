From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 22/36] bnx2x: Updating regdump_len at drvinfo
Date: Wed, 12 Aug 2009 21:23:40 +0300
Message-ID: <1250101420.27379.174.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610AbZHLSYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   69 ++++++++++++++++++++++------------------------
 1 files changed, 33 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 347036f..dd9a77f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8946,50 +8946,15 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return 0;
 }
 
-#define PHY_FW_VER_LEN			10
-
-static void bnx2x_get_drvinfo(struct net_device *dev,
-			      struct ethtool_drvinfo *info)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	u8 phy_fw_ver[PHY_FW_VER_LEN];
-
-	strcpy(info->driver, DRV_MODULE_NAME);
-	strcpy(info->version, DRV_MODULE_VERSION);
-
-	phy_fw_ver[0] = '\0';
-	if (bp->port.pmf) {
-		bnx2x_acquire_phy_lock(bp);
-		bnx2x_get_ext_phy_fw_version(&bp->link_params,
-					     (bp->state != BNX2X_STATE_CLOSED),
-					     phy_fw_ver, PHY_FW_VER_LEN);
-		bnx2x_release_phy_lock(bp);
-	}
-
-	snprintf(info->fw_version, 32, "BC:%d.%d.%d%s%s",
-		 (bp->common.bc_ver & 0xff0000) >> 16,
-		 (bp->common.bc_ver & 0xff00) >> 8,
-		 (bp->common.bc_ver & 0xff),
-		 ((phy_fw_ver[0] != '\0') ? " PHY:" : ""), phy_fw_ver);
-	strcpy(info->bus_info, pci_name(bp->pdev));
-	info->n_stats = BNX2X_NUM_STATS;
-	info->testinfo_len = BNX2X_NUM_TESTS;
-	info->eedump_len = bp->common.flash_size;
-	info->regdump_len = 0;
-}
-
 #define IS_E1_ONLINE(info)	(((info) & RI_E1_ONLINE) == RI_E1_ONLINE)
 #define IS_E1H_ONLINE(info)	(((info) & RI_E1H_ONLINE) == RI_E1H_ONLINE)
 
 static int bnx2x_get_regs_len(struct net_device *dev)
 {
-	static u32 regdump_len;
 	struct bnx2x *bp = netdev_priv(dev);
+	int regdump_len = 0;
 	int i;
 
-	if (regdump_len)
-		return regdump_len;
-
 	if (CHIP_IS_E1(bp)) {
 		for (i = 0; i < REGS_COUNT; i++)
 			if (IS_E1_ONLINE(reg_addrs[i].info))
@@ -9056,6 +9021,38 @@ static void bnx2x_get_regs(struct net_device *dev,
 	}
 }
 
+#define PHY_FW_VER_LEN			10
+
+static void bnx2x_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *info)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	u8 phy_fw_ver[PHY_FW_VER_LEN];
+
+	strcpy(info->driver, DRV_MODULE_NAME);
+	strcpy(info->version, DRV_MODULE_VERSION);
+
+	phy_fw_ver[0] = '\0';
+	if (bp->port.pmf) {
+		bnx2x_acquire_phy_lock(bp);
+		bnx2x_get_ext_phy_fw_version(&bp->link_params,
+					     (bp->state != BNX2X_STATE_CLOSED),
+					     phy_fw_ver, PHY_FW_VER_LEN);
+		bnx2x_release_phy_lock(bp);
+	}
+
+	snprintf(info->fw_version, 32, "BC:%d.%d.%d%s%s",
+		 (bp->common.bc_ver & 0xff0000) >> 16,
+		 (bp->common.bc_ver & 0xff00) >> 8,
+		 (bp->common.bc_ver & 0xff),
+		 ((phy_fw_ver[0] != '\0') ? " PHY:" : ""), phy_fw_ver);
+	strcpy(info->bus_info, pci_name(bp->pdev));
+	info->n_stats = BNX2X_NUM_STATS;
+	info->testinfo_len = BNX2X_NUM_TESTS;
+	info->eedump_len = bp->common.flash_size;
+	info->regdump_len = bnx2x_get_regs_len(dev);
+}
+
 static void bnx2x_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-- 
1.5.4.3




