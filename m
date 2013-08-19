From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 3/6] bnx2x: Consider DCBX remote error
Date: Mon, 19 Aug 2013 09:11:58 +0300
Message-ID: <1376892721-10410-4-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2760 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab3HSGMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:17 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

When publishing information via getfeatcfg(), bnx2x driver didn't consider
remote errors (e.g., switch that doesn't support DCBX) when setting the
error flags.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index d537d51..fcf2761 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2391,21 +2391,24 @@ static u8 bnx2x_dcbnl_get_featcfg(struct net_device *netdev, int featid,
 		case DCB_FEATCFG_ATTR_PG:
 			if (bp->dcbx_local_feat.ets.enabled)
 				*flags |= DCB_FEATCFG_ENABLE;
-			if (bp->dcbx_error & DCBX_LOCAL_ETS_ERROR)
+			if (bp->dcbx_error & (DCBX_LOCAL_ETS_ERROR |
+					      DCBX_REMOTE_MIB_ERROR))
 				*flags |= DCB_FEATCFG_ERROR;
 			break;
 		case DCB_FEATCFG_ATTR_PFC:
 			if (bp->dcbx_local_feat.pfc.enabled)
 				*flags |= DCB_FEATCFG_ENABLE;
 			if (bp->dcbx_error & (DCBX_LOCAL_PFC_ERROR |
-			    DCBX_LOCAL_PFC_MISMATCH))
+					      DCBX_LOCAL_PFC_MISMATCH |
+					      DCBX_REMOTE_MIB_ERROR))
 				*flags |= DCB_FEATCFG_ERROR;
 			break;
 		case DCB_FEATCFG_ATTR_APP:
 			if (bp->dcbx_local_feat.app.enabled)
 				*flags |= DCB_FEATCFG_ENABLE;
 			if (bp->dcbx_error & (DCBX_LOCAL_APP_ERROR |
-			    DCBX_LOCAL_APP_MISMATCH))
+					      DCBX_LOCAL_APP_MISMATCH |
+					      DCBX_REMOTE_MIB_ERROR))
 				*flags |= DCB_FEATCFG_ERROR;
 			break;
 		default:
-- 
1.8.1.227.g44fe835
