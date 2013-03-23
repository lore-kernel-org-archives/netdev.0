From: Kumar Amit Mehta <gmate.amit@gmail.com>
Subject: [PATCH] bnx2x: fix assignment of signed expression to unsigned variable
Date: Sat, 23 Mar 2013 11:52:55 -0700
Message-ID: <1364064775-19319-1-git-send-email-gmate.amit@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: eilong@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix for incorrect assignment of signed expression to unsigned variable.

Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 5682054..b90533a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2139,12 +2139,12 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
 			break;
 		default:
 			BNX2X_ERR("Non valid capability ID\n");
-			rval = -EINVAL;
+			rval = EINVAL;
 			break;
 		}
 	} else {
 		DP(BNX2X_MSG_DCB, "DCB disabled\n");
-		rval = -EINVAL;
+		rval = EINVAL;
 	}
 
 	DP(BNX2X_MSG_DCB, "capid %d:%x\n", capid, *cap);
@@ -2154,7 +2154,7 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
 static int bnx2x_dcbnl_get_numtcs(struct net_device *netdev, int tcid, u8 *num)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
-	u8 rval = 0;
+	s8 rval = 0;
 
 	DP(BNX2X_MSG_DCB, "tcid %d\n", tcid);
 
@@ -2188,7 +2188,7 @@ static int bnx2x_dcbnl_set_numtcs(struct net_device *netdev, int tcid, u8 num)
 	return -EINVAL;
 }
 
-static u8  bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
+static u8 bnx2x_dcbnl_get_pfc_state(struct net_device *netdev)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 	DP(BNX2X_MSG_DCB, "state = %d\n", bp->dcbx_local_feat.pfc.enabled);
@@ -2282,7 +2282,7 @@ static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
 	else {
 		/* app table is full */
 		BNX2X_ERR("Application table is too large\n");
-		return -EBUSY;
+		return EBUSY;
 	}
 
 	/* up configured, if not 0 make sure feature is enabled */
@@ -2312,7 +2312,7 @@ static u8 bnx2x_dcbnl_set_app_up(struct net_device *netdev, u8 idtype,
 		break;
 	default:
 		DP(BNX2X_MSG_DCB, "Wrong ID type\n");
-		return -EINVAL;
+		return EINVAL;
 	}
 	return bnx2x_set_admin_app_up(bp, idtype, idval, up);
 }
@@ -2390,12 +2390,12 @@ static u8 bnx2x_dcbnl_get_featcfg(struct net_device *netdev, int featid,
 			break;
 		default:
 			BNX2X_ERR("Non valid featrue-ID\n");
-			rval = -EINVAL;
+			rval = EINVAL;
 			break;
 		}
 	} else {
 		DP(BNX2X_MSG_DCB, "DCB disabled\n");
-		rval = -EINVAL;
+		rval = EINVAL;
 	}
 
 	return rval;
@@ -2431,12 +2431,12 @@ static u8 bnx2x_dcbnl_set_featcfg(struct net_device *netdev, int featid,
 			break;
 		default:
 			BNX2X_ERR("Non valid featrue-ID\n");
-			rval = -EINVAL;
+			rval = EINVAL;
 			break;
 		}
 	} else {
 		DP(BNX2X_MSG_DCB, "dcbnl call not valid\n");
-		rval = -EINVAL;
+		rval = EINVAL;
 	}
 
 	return rval;
-- 
1.7.9.5
