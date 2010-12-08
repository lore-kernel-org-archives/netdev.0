From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2x: Fixed a compilation warning
Date: Wed, 8 Dec 2010 13:43:29 +0200
Message-ID: <1291808609.30114.67.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2222 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065Ab0LHLnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 06:43:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_src_init_t2() is used only when BCM_CNIC is defined.
So, to avoid a compilation warning, we won't define it unless
BCM_CNIC is defined.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_init_ops.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_init_ops.h b/drivers/net/bnx2x/bnx2x_init_ops.h
index a306b0e..66df29f 100644
--- a/drivers/net/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x/bnx2x_init_ops.h
@@ -838,7 +838,7 @@ static void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
 /****************************************************************************
 * SRC initializations
 ****************************************************************************/
-
+#ifdef BCM_CNIC
 /* called during init func stage */
 static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 			      dma_addr_t t2_mapping, int src_cid_count)
@@ -862,5 +862,5 @@ static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
 		    U64_HI((u64)t2_mapping +
 			   (src_cid_count-1) * sizeof(struct src_ent)));
 }
-
+#endif
 #endif /* BNX2X_INIT_OPS_H */
-- 
1.7.0.4




