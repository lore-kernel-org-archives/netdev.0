From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 7/8] bnx2x: Fix self test of BCM57800
Date: Sun, 27 Nov 2011 20:18:00 +0200
Message-ID: <1322417881-17760-8-git-send-email-yanivr@broadcom.com>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3348 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755824Ab1K0QTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 11:19:11 -0500
In-Reply-To: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the MAC test of the 1G port of the BCM57800 to use the UMAC instead of the XMAC.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ec31871..5cf4880 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1749,8 +1749,18 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 			return -EINVAL;
 		break;
 	case BNX2X_MAC_LOOPBACK:
-		bp->link_params.loopback_mode = CHIP_IS_E3(bp) ?
-						LOOPBACK_XMAC : LOOPBACK_BMAC;
+		if (CHIP_IS_E3(bp)) {
+			int cfg_idx = bnx2x_get_link_cfg_idx(bp);
+			if (bp->port.supported[cfg_idx] &
+			    (SUPPORTED_10000baseT_Full |
+				 SUPPORTED_20000baseMLD2_Full |
+				 SUPPORTED_20000baseKR2_Full))
+				bp->link_params.loopback_mode = LOOPBACK_XMAC;
+			else
+				bp->link_params.loopback_mode = LOOPBACK_UMAC;
+		} else
+			bp->link_params.loopback_mode = LOOPBACK_BMAC;
+
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		break;
 	default:
-- 
1.7.7.1
