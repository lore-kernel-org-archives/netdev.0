From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix cl_id allocation for non-eth clients for
 NPAR mode
Date: Mon, 10 Oct 2011 11:57:36 +0200
Message-ID: <1318240656-24657-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4733 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097Ab1JJJ5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 05:57:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some consolidations of NPAR configuration
when FCoE and iSCSI L2 clients will get the same id,
in this case FCoE ring will be non-functional.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h     |   20 +++++++++++++-------
 drivers/net/bnx2x/bnx2x_cmn.h |    2 +-
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index e46df53..9a7eb3b 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -239,13 +239,19 @@ void bnx2x_int_disable(struct bnx2x *bp);
  *  FUNC_N_CLID_X = N * NUM_SPECIAL_CLIENTS + FUNC_0_CLID_X
  *
  */
-/* iSCSI L2 */
-#define BNX2X_ISCSI_ETH_CL_ID_IDX	1
-#define BNX2X_ISCSI_ETH_CID		49
+enum {
+	BNX2X_ISCSI_ETH_CL_ID_IDX,
+	BNX2X_FCOE_ETH_CL_ID_IDX,
+	BNX2X_MAX_CNIC_ETH_CL_ID_IDX,
+};
 
-/* FCoE L2 */
-#define BNX2X_FCOE_ETH_CL_ID_IDX	2
-#define BNX2X_FCOE_ETH_CID		50
+#define BNX2X_CNIC_START_ETH_CID	48
+enum {
+	/* iSCSI L2 */
+	BNX2X_ISCSI_ETH_CID = BNX2X_CNIC_START_ETH_CID,
+	/* FCoE L2 */
+	BNX2X_FCOE_ETH_CID,
+};
 
 /** Additional rings budgeting */
 #ifdef BCM_CNIC
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 223bfee..2dc1199 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1297,7 +1297,7 @@ static inline void bnx2x_init_txdata(struct bnx2x *bp,
 static inline u8 bnx2x_cnic_eth_cl_id(struct bnx2x *bp, u8 cl_idx)
 {
 	return bp->cnic_base_cl_id + cl_idx +
-		(bp->pf_num >> 1) * NON_ETH_CONTEXT_USE;
+		(bp->pf_num >> 1) * BNX2X_MAX_CNIC_ETH_CL_ID_IDX;
 }
 
 static inline u8 bnx2x_cnic_fw_sb_id(struct bnx2x *bp)
-- 
1.7.2.2
