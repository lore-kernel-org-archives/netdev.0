From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 21/25] bnx2x: Driver info
Date: Wed, 13 Aug 2008 17:16:09 +0300
Message-ID: <1218636969.547.97.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3059 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756691AbYHMOQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver info
The internal FW which is downloaded by the driver should not be
displayed - it is only causing confusion and it is redundant since it
can be concluded from the driver version. Display only FW which is
burned on the board nvram

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 594b08a..721db29 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7763,7 +7763,7 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 			      struct ethtool_drvinfo *info)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	char phy_fw_ver[PHY_FW_VER_LEN];
+	u8 phy_fw_ver[PHY_FW_VER_LEN];
 
 	strcpy(info->driver, DRV_MODULE_NAME);
 	strcpy(info->version, DRV_MODULE_VERSION);
@@ -7777,11 +7777,11 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 		bnx2x_release_phy_lock(bp);
 	}
 
-	snprintf(info->fw_version, 32, "%d.%d.%d:%d BC:%x%s%s",
-		 BCM_5710_FW_MAJOR_VERSION, BCM_5710_FW_MINOR_VERSION,
-		 BCM_5710_FW_REVISION_VERSION,
-		 BCM_5710_FW_COMPILE_FLAGS, bp->common.bc_ver,
-		 ((phy_fw_ver[0] != '\0')? " PHY:":""), phy_fw_ver);
+	snprintf(info->fw_version, 32, "BC:%d.%d.%d%s%s",
+		 (bp->common.bc_ver & 0xff0000) >> 16,
+		 (bp->common.bc_ver & 0xff00) >> 8,
+		 (bp->common.bc_ver & 0xff),
+		 ((phy_fw_ver[0] != '\0') ? " PHY:" : ""), phy_fw_ver);
 	strcpy(info->bus_info, pci_name(bp->pdev));
 	info->n_stats = BNX2X_NUM_STATS;
 	info->testinfo_len = BNX2X_NUM_TESTS;
-- 
1.5.3.2




