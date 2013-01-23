From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 09/12] bnx2x: correct memory release scheme
Date: Wed, 23 Jan 2013 15:21:51 +0200
Message-ID: <1358947314-3851-10-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1315 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab3AWOXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:17 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix an incorrect SR-IOV memory release which was committed in 1ab4434.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 6 ++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h | 1 +
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f511c3c..ac00ddc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7738,10 +7738,6 @@ void bnx2x_free_mem(struct bnx2x *bp)
 {
 	int i;
 
-	/* fastpath */
-	bnx2x_free_fp_mem(bp);
-	/* end of fastpath */
-
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
 		       sizeof(struct host_sp_status_block));
 
@@ -7762,6 +7758,8 @@ void bnx2x_free_mem(struct bnx2x *bp)
 
 	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
 		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
+
+	bnx2x_iov_free_mem(bp);
 }
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index d51189b..b405017 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -773,6 +773,7 @@ static inline void bnx2x_vf_mbx(struct bnx2x *bp,
 static inline int bnx2x_iov_init_ilt(struct bnx2x *bp, u16 line) {return line; }
 static inline void bnx2x_iov_init_dq(struct bnx2x *bp) {}
 static inline int bnx2x_iov_alloc_mem(struct bnx2x *bp) {return 0; }
+static inline void bnx2x_iov_free_mem(struct bnx2x *bp) {}
 static inline int bnx2x_iov_chip_cleanup(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_iov_init_dmae(struct bnx2x *bp) {}
 static inline int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
-- 
1.8.1.227.g44fe835
