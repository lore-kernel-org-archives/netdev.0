From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next v2 7/9] bnx2x: Fix self test of BCM57800
Date: Mon, 28 Nov 2011 12:49:51 +0200
Message-ID: <1322477393-22904-8-git-send-email-yanivr@broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4119 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab1K1Iuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 03:50:52 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the MAC test of the 1G port of the BCM57800 to use the UMAC instead of the XMAC.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ec31871..f1bf1f5 100644
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
+			     SUPPORTED_20000baseMLD2_Full |
+			     SUPPORTED_20000baseKR2_Full))
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
