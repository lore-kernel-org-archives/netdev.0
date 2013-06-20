From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2x: improve VF timings
Date: Thu, 20 Jun 2013 17:39:10 +0300
Message-ID: <1371739151-15744-4-git-send-email-yuvalmin@broadcom.com>
References: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4974 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757758Ab3FTOja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 10:39:30 -0400
In-Reply-To: <1371739151-15744-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Wait 100ms for FLR to complete in parallel over all VFs instead of serializing
the waits (which can amount to several seconds with 64 VFs).

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index f6177ba..bda4d7e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1469,9 +1469,6 @@ static u8 bnx2x_vf_is_pcie_pending(struct bnx2x *bp, u8 abs_vfid)
 
 int bnx2x_vf_flr_clnup_epilog(struct bnx2x *bp, u8 abs_vfid)
 {
-	/* Wait 100ms */
-	msleep(100);
-
 	/* Verify no pending pci transactions */
 	if (bnx2x_vf_is_pcie_pending(bp, abs_vfid))
 		BNX2X_ERR("PCIE Transactions still pending\n");
@@ -2174,6 +2171,9 @@ int bnx2x_iov_nic_init(struct bnx2x *bp)
 
 	DP(BNX2X_MSG_IOV, "num of vfs: %d\n", (bp)->vfdb->sriov.nr_virtfn);
 
+	/* let FLR complete ... */
+	msleep(100);
+
 	/* initialize vf database */
 	for_each_vf(bp, vfid) {
 		struct bnx2x_virtf *vf = BP_VF(bp, vfid);
@@ -2775,6 +2775,10 @@ int bnx2x_vf_init(struct bnx2x *bp, struct bnx2x_virtf *vf, dma_addr_t *sb_map)
 		   vf->abs_vfid, vf->state);
 		return -EINVAL;
 	}
+
+	/* let FLR complete ... */
+	msleep(100);
+
 	/* FLR cleanup epilogue */
 	if (bnx2x_vf_flr_clnup_epilog(bp, vf->abs_vfid))
 		return -EBUSY;
-- 
1.8.1.227.g44fe835
