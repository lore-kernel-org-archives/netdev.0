From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/6] bnx2x: Fix support for VFs on some PFs
Date: Mon, 23 Sep 2013 10:12:51 +0300
Message-ID: <1379920375-10303-3-git-send-email-yuvalmin@broadcom.com>
References: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2400 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab3IWHNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:07 -0400
In-Reply-To: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Due to incorrect usage of PF macros when reading information relating to
interrupts, some PFs were erroneously unable to support VFs.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2604b62..d9370d4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1819,7 +1819,7 @@ bnx2x_get_vf_igu_cam_info(struct bnx2x *bp)
 		fid = GET_FIELD((val), IGU_REG_MAPPING_MEMORY_FID);
 		if (fid & IGU_FID_ENCODE_IS_PF)
 			current_pf = fid & IGU_FID_PF_NUM_MASK;
-		else if (current_pf == BP_ABS_FUNC(bp))
+		else if (current_pf == BP_FUNC(bp))
 			bnx2x_vf_set_igu_info(bp, sb_id,
 					      (fid & IGU_FID_VF_NUM_MASK));
 		DP(BNX2X_MSG_IOV, "%s[%d], igu_sb_id=%d, msix=%d\n",
-- 
1.8.1.4
