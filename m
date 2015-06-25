From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 6/9] bnx2x: Fix self-test for 20g devices
Date: Thu, 25 Jun 2015 15:19:26 +0300
Message-ID: <1435234769-5625-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29854 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751509AbbFYMUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:12 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

20g-capable devices are not configured properly for self-test, using
10g as their speed which cause the link indication to remain down and
fail the internal loopback test.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c1033a5..3df03bb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2347,12 +2347,16 @@ int bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		if (load_mode == LOAD_DIAG) {
 			struct link_params *lp = &bp->link_params;
 			lp->loopback_mode = LOOPBACK_XGXS;
-			/* do PHY loopback at 10G speed, if possible */
-			if (lp->req_line_speed[cfx_idx] < SPEED_10000) {
+			/* Prefer doing PHY loopback at highest speed */
+			if (lp->req_line_speed[cfx_idx] < SPEED_20000) {
 				if (lp->speed_cap_mask[cfx_idx] &
-				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+				    PORT_HW_CFG_SPEED_CAPABILITY_D0_20G)
 					lp->req_line_speed[cfx_idx] =
-					SPEED_10000;
+					SPEED_20000;
+				else if (lp->speed_cap_mask[cfx_idx] &
+					    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+						lp->req_line_speed[cfx_idx] =
+						SPEED_10000;
 				else
 					lp->req_line_speed[cfx_idx] =
 					SPEED_1000;
-- 
1.9.3
