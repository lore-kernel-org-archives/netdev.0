From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH] bnx2x: correct LPI pass-through configuration
Date: Sun, 17 Jun 2012 15:04:50 +0300
Message-ID: <1339934690-28191-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2461 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756841Ab2FQMHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 08:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c8c60d88c59cbb48737732ba948663a3efe882aa contained
an incorrect logic which enabled a buffer overflow when accessing 
an array during LPI pass-through configuration.
This patch fixes this issue by removing that logic altogether.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Thanks goes to Dan Carpenter for finding this bug.

Dave, please apply this patch to 'net-next'. 

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index c7c814d..91aa565 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4057,18 +4057,12 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 			 MDIO_WC_REG_DIGITAL4_MISC3, val | 0x8080);
 
 	/* Enable LPI pass through */
-	if ((params->eee_mode & EEE_MODE_ADV_LPI) &&
-	    (phy->flags & FLAGS_EEE_10GBT) &&
-	    (!(params->eee_mode & EEE_MODE_ENABLE_LPI) ||
-	      bnx2x_eee_calc_timer(params)) &&
-	    (params->req_duplex[bnx2x_phy_selection(params)] == DUPLEX_FULL)) {
-		DP(NETIF_MSG_LINK, "Configure WC for LPI pass through\n");
-		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				 MDIO_WC_REG_EEE_COMBO_CONTROL0,
-				 0x7c);
-		bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
-					 MDIO_WC_REG_DIGITAL4_MISC5, 0xc000);
-	}
+	DP(NETIF_MSG_LINK, "Configure WC for LPI pass through\n");
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			 MDIO_WC_REG_EEE_COMBO_CONTROL0,
+			 0x7c);
+	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_DIGITAL4_MISC5, 0xc000);
 
 	/* 10G XFI Full Duplex */
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-- 
1.7.9.rc2
