From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 3/6] bnx2x: add missing VF resource allocation
 during init
Date: Mon, 23 Sep 2013 10:12:52 +0300
Message-ID: <1379920375-10303-4-git-send-email-yuvalmin@broadcom.com>
References: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4116 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308Ab3IWHNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:07 -0400
In-Reply-To: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

bnx2x_iov_static_resc() should be called after IGU was read for information on
the number of available VFs, so that resources will be correctly set.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index d9370d4..9ad012b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3180,6 +3180,7 @@ int bnx2x_enable_sriov(struct bnx2x *bp)
 		/* set local queue arrays */
 		vf->vfqs = &bp->vfdb->vfqs[qcount];
 		qcount += vf_sb_count(vf);
+		bnx2x_iov_static_resc(bp, vf);
 	}
 
 	/* prepare msix vectors in VF configuration space */
@@ -3187,6 +3188,8 @@ int bnx2x_enable_sriov(struct bnx2x *bp)
 		bnx2x_pretend_func(bp, HW_VF_HANDLE(bp, vf_idx));
 		REG_WR(bp, PCICFG_OFFSET + GRC_CONFIG_REG_VF_MSIX_CONTROL,
 		       num_vf_queues);
+		DP(BNX2X_MSG_IOV, "set msix vec num in VF %d cfg space to %d\n",
+		   vf_idx, num_vf_queues);
 	}
 	bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
 
-- 
1.8.1.4
