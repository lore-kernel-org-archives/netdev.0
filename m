From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 11/11] bnx2x: allow all functions to display the phy
 FW version
Date: Wed, 15 Feb 2012 07:10:32 -0500
Message-ID: <1329307832-32454-12-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4937 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936Ab2BOFQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:25 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

The phy FW version is stored in regular memory, no MDC-MDIO access or
any special locks are required to read it in the current implementation.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   10 ++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    4 ++--
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c18dc1d..7e57fa4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -806,14 +806,8 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 
 	phy_fw_ver[0] = '\0';
-	if (bp->port.pmf) {
-		bnx2x_acquire_phy_lock(bp);
-		bnx2x_get_ext_phy_fw_version(&bp->link_params,
-					     (bp->state != BNX2X_STATE_CLOSED),
-					     phy_fw_ver, PHY_FW_VER_LEN);
-		bnx2x_release_phy_lock(bp);
-	}
-
+	bnx2x_get_ext_phy_fw_version(&bp->link_params,
+				     phy_fw_ver, PHY_FW_VER_LEN);
 	strlcpy(info->fw_version, bp->fw_ver, sizeof(info->fw_version));
 	snprintf(info->fw_version + strlen(bp->fw_ver), 32 - strlen(bp->fw_ver),
 		 "bc %d.%d.%d%s%s",
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 57fe056..beb4cdb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6042,8 +6042,8 @@ static int bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
 	return 0;
 }
 
-int bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
-				 u8 *version, u16 len)
+int bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 *version,
+				 u16 len)
 {
 	struct bnx2x *bp;
 	u32 spirom_ver = 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 9cc7baf..7ba557a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -337,8 +337,8 @@ int bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 void bnx2x_link_status_update(struct link_params *input,
 			    struct link_vars *output);
 /* returns string representing the fw_version of the external phy */
-int bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
-				 u8 *version, u16 len);
+int bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 *version,
+				 u16 len);
 
 /* Set/Unset the led
    Basically, the CLC takes care of the led for the link, but in case one needs
-- 
1.7.9.rc2
