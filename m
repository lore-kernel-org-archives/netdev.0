From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 7/11] bnx2x: Remove useless return variables
Date: Sat, 31 May 2014 10:14:07 -0300
Message-ID: <1401542051-3174-7-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ariel Elior <ariele@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

Verified by compilation only.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 9b6b3d7..4fef1e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -2218,7 +2218,6 @@ int bnx2x_update_pfc(struct link_params *params,
 	 */
 	u32 val;
 	struct bnx2x *bp = params->bp;
-	int bnx2x_status = 0;
 	u8 bmac_loopback = (params->loopback_mode == LOOPBACK_BMAC);
 
 	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
@@ -2232,7 +2231,7 @@ int bnx2x_update_pfc(struct link_params *params,
 	bnx2x_update_pfc_nig(params, vars, pfc_params);
 
 	if (!vars->link_up)
-		return bnx2x_status;
+		return 0;
 
 	DP(NETIF_MSG_LINK, "About to update PFC in BMAC\n");
 
@@ -2246,7 +2245,7 @@ int bnx2x_update_pfc(struct link_params *params,
 		    == 0) {
 			DP(NETIF_MSG_LINK, "About to update PFC in EMAC\n");
 			bnx2x_emac_enable(params, vars, 0);
-			return bnx2x_status;
+			return 0;
 		}
 		if (CHIP_IS_E2(bp))
 			bnx2x_update_pfc_bmac2(params, vars, bmac_loopback);
@@ -2260,7 +2259,7 @@ int bnx2x_update_pfc(struct link_params *params,
 			val = 1;
 		REG_WR(bp, NIG_REG_BMAC0_PAUSE_OUT_EN + params->port*4, val);
 	}
-	return bnx2x_status;
+	return 0;
 }
 
 static int bnx2x_bmac1_enable(struct link_params *params,
@@ -6473,7 +6472,6 @@ int bnx2x_test_link(struct link_params *params, struct link_vars *vars,
 static int bnx2x_link_initialize(struct link_params *params,
 				 struct link_vars *vars)
 {
-	int rc = 0;
 	u8 phy_index, non_ext_phy;
 	struct bnx2x *bp = params->bp;
 	/* In case of external phy existence, the line speed would be the
@@ -6546,7 +6544,7 @@ static int bnx2x_link_initialize(struct link_params *params,
 			NIG_STATUS_XGXS0_LINK_STATUS |
 			NIG_STATUS_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
-	return rc;
+	return 0;
 }
 
 static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
