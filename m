From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net] bnx2x: Restore a call to config_init
Date: Fri, 6 Sep 2013 12:55:02 +0300
Message-ID: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	netdev <netdev@vger.kernel.org>, "Dave Jones" <davej@redhat.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3644 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895Ab3IFJzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 05:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c0a77ec74f295013d7ba3204dd3ed25fccf83cb4 'bnx2x: Add missing braces in
bnx2x:bnx2x_link_initialize' identified indentation problem, but resolved it
by adding braces instead of fixing the indentation. The braces now prevents a
config_init call in some cases, though it should be called regardless of that
condition. This patch removes the braces and fix the confusing indentation
that caused this mess.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
CC: Dave Jones <davej@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 6645684..d60a2ea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6501,13 +6501,10 @@ static int bnx2x_link_initialize(struct link_params *params,
 		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		if (vars->line_speed == SPEED_AUTO_NEG &&
 		    (CHIP_IS_E1x(bp) ||
-		     CHIP_IS_E2(bp))) {
+		     CHIP_IS_E2(bp)))
 			bnx2x_set_parallel_detection(phy, params);
-			if (params->phy[INT_PHY].config_init)
-				params->phy[INT_PHY].config_init(phy,
-								 params,
-								 vars);
-		}
+		if (params->phy[INT_PHY].config_init)
+			params->phy[INT_PHY].config_init(phy, params, vars);
 	}
 
 	/* Init external phy*/
-- 
1.8.3.1
