From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/5] bnx2x: Fix link-forcing for KR2
Date: Sun, 21 Feb 2016 15:07:25 +0200
Message-ID: <1456060049-10678-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.om>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35839 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751688AbcBURqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:46:33 -0500
In-Reply-To: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when link is using KR2 it cannot be forced to any speed other
than 20g.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.om>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index d946bba..a529905 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -13807,8 +13807,10 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 	if (CHIP_IS_E3(bp)) {
 		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		bnx2x_set_aer_mmd(params, phy);
-		if ((phy->supported & SUPPORTED_20000baseKR2_Full) &&
-		    (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_20G))
+		if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+		     (phy->speed_cap_mask &
+		      PORT_HW_CFG_SPEED_CAPABILITY_D0_20G)) ||
+		    (phy->req_line_speed == SPEED_20000))
 			bnx2x_check_kr2_wa(params, vars, phy);
 		bnx2x_check_over_curr(params, vars);
 		if (vars->rx_tx_asic_rst)
-- 
1.9.3
