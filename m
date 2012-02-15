From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 09/11] bnx2x: allow BCM84833 phy to advertise
 100Base-T speeds
Date: Wed, 15 Feb 2012 07:10:30 -0500
Message-ID: <1329307832-32454-10-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4937 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2BOFQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:20 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1527aed..9f29119 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9298,6 +9298,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					SPEED_AUTO_NEG;
 				bp->port.advertising[idx] |=
 					bp->port.supported[idx];
+				if (bp->link_params.phy[EXT_PHY1].type ==
+				    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+					bp->port.advertising[idx] |=
+					(SUPPORTED_100baseT_Half |
+					 SUPPORTED_100baseT_Full);
 			} else {
 				/* force 10G, no AN */
 				bp->link_params.req_line_speed[idx] =
-- 
1.7.9.rc2
