From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 31/34]bnx2x: Legacy speeds autoneg failures
Date: Wed, 14 Jan 2009 18:44:21 +0200
Message-ID: <1231951461.11301.152.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764209AbZANQpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10M/100M autoneg was not establishing link.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 4ce107c..2fd6be0 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3882,9 +3882,15 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	}
 
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		if (params->req_line_speed &&
+		if ((params->req_line_speed &&
 		    ((params->req_line_speed == SPEED_100) ||
-		     (params->req_line_speed == SPEED_10))) {
+		     (params->req_line_speed == SPEED_10))) ||
+		    (!params->req_line_speed &&
+		     (params->speed_cap_mask >=
+		       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) &&
+		     (params->speed_cap_mask <
+		       PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
+		     ))  {
 			vars->phy_flags |= PHY_SGMII_FLAG;
 		} else {
 			vars->phy_flags &= ~PHY_SGMII_FLAG;
-- 
1.5.4.3




