From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 4/5] bnx2x: Specific Active-DAC is not detected on
 57810
Date: Sun, 22 Sep 2013 14:59:25 +0300
Message-ID: <1379851166-11959-5-git-send-email-yanivr@broadcom.com>
References: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4921 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab3IVL77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 07:59:59 -0400
In-Reply-To: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix Warpcore mode setting when active DAC (Direct Attached Cable) is detected.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 5c6d46c..dc67566 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -175,6 +175,7 @@ typedef int (*read_sfp_module_eeprom_func_p)(struct bnx2x_phy *phy,
 #define EDC_MODE_LINEAR				0x0022
 #define EDC_MODE_LIMITING				0x0044
 #define EDC_MODE_PASSIVE_DAC			0x0055
+#define EDC_MODE_ACTIVE_DAC			0x0066
 
 /* ETS defines*/
 #define DCBX_INVALID_COS					(0xFF)
@@ -8110,7 +8111,10 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 		if (copper_module_type &
 		    SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_ACTIVE) {
 			DP(NETIF_MSG_LINK, "Active Copper cable detected\n");
-			check_limiting_mode = 1;
+			if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)
+				*edc_mode = EDC_MODE_ACTIVE_DAC;
+			else
+				check_limiting_mode = 1;
 		} else if (copper_module_type &
 			SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE) {
 				DP(NETIF_MSG_LINK,
@@ -8585,6 +8589,7 @@ static void bnx2x_warpcore_set_limiting_mode(struct link_params *params,
 		mode = MDIO_WC_REG_UC_INFO_B1_FIRMWARE_MODE_DEFAULT;
 		break;
 	case EDC_MODE_PASSIVE_DAC:
+	case EDC_MODE_ACTIVE_DAC:
 		mode = MDIO_WC_REG_UC_INFO_B1_FIRMWARE_MODE_SFP_DAC;
 		break;
 	default:
-- 
1.7.1
