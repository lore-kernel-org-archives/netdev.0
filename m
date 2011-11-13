From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 07/12] bnx2x: simplify definition of
 RX_SGE_MASK_LEN and use it.
Date: Sun, 13 Nov 2011 14:47:24 +0200
Message-ID: <1321188449-5822-8-git-send-email-dmitry@broadcom.com>
References: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4273 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567Ab1KMMrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:47:47 -0500
In-Reply-To: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |    3 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e17a739..b78c384 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -411,8 +411,7 @@ union db_prod {
 
 
 /* Number of u64 elements in SGE mask array */
-#define RX_SGE_MASK_LEN			((NUM_RX_SGE_PAGES * RX_SGE_CNT) / \
-					 BIT_VEC64_ELEM_SZ)
+#define RX_SGE_MASK_LEN			(NUM_RX_SGE / BIT_VEC64_ELEM_SZ)
 #define RX_SGE_MASK_LEN_MASK		(RX_SGE_MASK_LEN - 1)
 #define NEXT_SGE_MASK_ELEM(el)		(((el) + 1) & RX_SGE_MASK_LEN_MASK)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 59f1291..e8efb01 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -874,8 +874,7 @@ static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
 static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
 {
 	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
-	memset(fp->sge_mask, 0xff,
-	       (NUM_RX_SGE >> BIT_VEC64_ELEM_SHIFT)*sizeof(u64));
+	memset(fp->sge_mask, 0xff, RX_SGE_MASK_LEN * sizeof(u64));
 
 	/* Clear the two last indices in the page to 1:
 	   these are the indices that correspond to the "next" element,
-- 
1.7.7.2
