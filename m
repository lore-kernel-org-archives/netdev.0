From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 07/14] amd-xgbe: Fixes for working with PHYs
 that support 2.5GbE
Date: Wed, 28 Jun 2017 13:42:25 -0500
Message-ID: <20170628184225.21972.15252.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0052.outbound.protection.outlook.com ([104.47.37.52]:47643
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751523AbdF1Smb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:42:31 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has some missing functionality when operating in the mode that
supports 2.5GbE.  Fix the driver to fully recognize and support this speed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 756e116..b8be62e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -1966,6 +1966,8 @@ static enum xgbe_mode xgbe_phy_get_baset_mode(struct xgbe_phy_data *phy_data,
 		return XGBE_MODE_SGMII_100;
 	case SPEED_1000:
 		return XGBE_MODE_SGMII_1000;
+	case SPEED_2500:
+		return XGBE_MODE_KX_2500;
 	case SPEED_10000:
 		return XGBE_MODE_KR;
 	default:
@@ -2109,6 +2111,9 @@ static bool xgbe_phy_use_baset_mode(struct xgbe_prv_data *pdata,
 	case XGBE_MODE_SGMII_1000:
 		return xgbe_phy_check_mode(pdata, mode,
 					   ADVERTISED_1000baseT_Full);
+	case XGBE_MODE_KX_2500:
+		return xgbe_phy_check_mode(pdata, mode,
+					   ADVERTISED_2500baseX_Full);
 	case XGBE_MODE_KR:
 		return xgbe_phy_check_mode(pdata, mode,
 					   ADVERTISED_10000baseT_Full);
@@ -2218,6 +2223,8 @@ static bool xgbe_phy_valid_speed_baset_mode(struct xgbe_phy_data *phy_data,
 	case SPEED_100:
 	case SPEED_1000:
 		return true;
+	case SPEED_2500:
+		return (phy_data->port_mode == XGBE_PORT_MODE_NBASE_T);
 	case SPEED_10000:
 		return (phy_data->port_mode == XGBE_PORT_MODE_10GBASE_T);
 	default:
