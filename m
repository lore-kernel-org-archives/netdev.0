From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25] BNX2X: prevent ethtool from setting port type
Date: Sun, 23 Mar 2008 08:05:06 +0200
Message-ID: <1206252306.13326.3.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1407 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbYCWGFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 02:05:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BNX2X: prevent ethtool from setting port type

On 10GBaseT boards setting the type to TP will cause the driver to try
to configure 1GBaseT.
Since there are currently no boards that support setting of the port
type, disable this for now.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

---
 drivers/net/bnx2x.c |   36 ++----------------------------------
 1 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 8af142c..de32b3f 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -63,8 +63,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "1.40.22"
-#define DRV_MODULE_RELDATE      "2007/11/27"
+#define DRV_MODULE_VERSION      "1.42.3"
+#define DRV_MODULE_RELDATE      "2008/3/9"
 #define BNX2X_BC_VER    	0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
@@ -8008,38 +8008,6 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
-	switch (cmd->port) {
-	case PORT_TP:
-		if (!(bp->supported & SUPPORTED_TP)) {
-			DP(NETIF_MSG_LINK, "TP not supported\n");
-			return -EINVAL;
-		}
-
-		if (bp->phy_flags & PHY_XGXS_FLAG) {
-			bnx2x_link_reset(bp);
-			bnx2x_link_settings_supported(bp, SWITCH_CFG_1G);
-			bnx2x_phy_deassert(bp);
-		}
-		break;
-
-	case PORT_FIBRE:
-		if (!(bp->supported & SUPPORTED_FIBRE)) {
-			DP(NETIF_MSG_LINK, "FIBRE not supported\n");
-			return -EINVAL;
-		}
-
-		if (!(bp->phy_flags & PHY_XGXS_FLAG)) {
-			bnx2x_link_reset(bp);
-			bnx2x_link_settings_supported(bp, SWITCH_CFG_10G);
-			bnx2x_phy_deassert(bp);
-		}
-		break;
-
-	default:
-		DP(NETIF_MSG_LINK, "Unknown port type\n");
-		return -EINVAL;
-	}
-
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		if (!(bp->supported & SUPPORTED_Autoneg)) {
 			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
-- 
1.5.3.2




