From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 5/5] bnx2x: Disable AN KR work-around for BCM57810
Date: Tue, 17 Jan 2012 14:33:29 +0200
Message-ID: <1326803609-25526-6-git-send-email-yanivr@broadcom.com>
References: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3460 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093Ab2AQKez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:34:55 -0500
In-Reply-To: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the work-around for the autoneg KR of the BCM57810 in case the Warpcore version is 0xD108 and above, which fixes this problem.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a6c48d6..2091e5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3763,7 +3763,15 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	/* Advertise pause */
 	bnx2x_ext_phy_set_pause(params, phy, vars);
 
-	vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
+	/*
+	 * Set KR Autoneg Work-Around flag for Warpcore version older than D108
+	 */
+	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
+			MDIO_WC_REG_UC_INFO_B1_VERSION, &val16);
+	if (val16 < 0xd108) {
+		DP(NETIF_MSG_LINK, "Enable AN KR work-around\n");
+		vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
+	}
 
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 			MDIO_WC_REG_DIGITAL5_MISC7, &val16);
-- 
1.7.7.1
