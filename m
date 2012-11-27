From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 8/9] bnx2x: Add warning message in case of
 non-10G SFP module
Date: Tue, 27 Nov 2012 15:46:35 +0200
Message-ID: <1354023996-3512-9-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4627 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755502Ab2K0Lrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:32 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The string was split to several lines since it reached over 180 chars, which
seems too much.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 661d3ea..ebab35d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -7986,9 +7986,8 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u32 sync_offset = 0, phy_idx, media_types;
-	u8 val[2], check_limiting_mode = 0;
+	u8 gport, val[2], check_limiting_mode = 0;
 	*edc_mode = EDC_MODE_LIMITING;
-
 	phy->media_type = ETH_PHY_UNSPECIFIED;
 	/* First check for copper cable */
 	if (bnx2x_read_sfp_module_eeprom(phy,
@@ -8043,8 +8042,15 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 			       SFP_EEPROM_COMP_CODE_LR_MASK |
 			       SFP_EEPROM_COMP_CODE_LRM_MASK)) == 0) {
 			DP(NETIF_MSG_LINK, "1G Optic module detected\n");
+			gport = params->port;
 			phy->media_type = ETH_PHY_SFP_1G_FIBER;
 			phy->req_line_speed = SPEED_1000;
+			if (!CHIP_IS_E1x(bp))
+				gport = BP_PATH(bp) + (params->port << 1);
+			netdev_err(bp->dev, "Warning: Link speed was forced to 1000Mbps."
+			      " Current SFP module in port %d is not"
+			      " compliant with 10G Ethernet\n",
+			 gport);
 		} else {
 			int idx, cfg_idx = 0;
 			DP(NETIF_MSG_LINK, "10G Optic module detected\n");
-- 
1.7.1
