From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next] bnx2x: Add new PHY BCM54616
Date: Tue, 23 Aug 2011 19:33:24 +0300
Message-ID: <1314117204.28819.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2383 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1HWQda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 12:33:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCM54616 PHY is very similar to the 54618SE, only without EEE support, which will not be activated due to querying the actual PHY type.
This check is already done by reading a dedicated PHY register.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index dc24de4..e44b858 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -704,6 +704,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84833      0x00000d00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54618SE    0x00000e00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8722       0x00000f00
+		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54616      0x00001000
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_FAILURE       0x0000fd00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_NOT_CONN      0x0000ff00
 
@@ -759,6 +760,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833       0x00000d00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE     0x00000e00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8722        0x00000f00
+		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616       0x00001000
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT_WC      0x0000fc00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE        0x0000fd00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN       0x0000ff00
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e3de6fe..8e9b87b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11242,6 +11242,7 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
 		*phy = phy_84833;
 		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE:
 		*phy = phy_54618se;
 		break;
-- 
1.7.1





