From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 08/36] bnx2x: get_ext_phy_fw_version returns NULL if
 not applicable
Date: Wed, 12 Aug 2009 21:22:59 +0300
Message-ID: <1250101379.27379.160.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbZHLSXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid confusion, if the PHY does not have a FW (and so, no FW version) make
sure that the string is NULL.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index c925249..aee9fff 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -5393,7 +5393,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	struct bnx2x *bp;
 	u32 ext_phy_type = 0;
 	u32 spirom_ver = 0;
-	u8 status = 0 ;
+	u8 status;
 
 	if (version == NULL || params == NULL)
 		return -EINVAL;
@@ -5403,6 +5403,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 		   offsetof(struct shmem_region,
 			    port_mb[params->port].ext_phy_fw_version));
 
+	status = 0;
 	/* reset the returned value to zero */
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	switch (ext_phy_type) {
@@ -5421,7 +5422,6 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		status = bnx2x_format_ver(spirom_ver, version, len);
@@ -5432,6 +5432,8 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 		status = bnx2x_format_ver(spirom_ver, version, len);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+		version[0] = '\0';
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-- 
1.5.4.3




