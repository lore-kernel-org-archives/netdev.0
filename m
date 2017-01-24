From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH] cxgbit: use T6 specific macro to set force bit
Date: Tue, 24 Jan 2017 17:07:02 +0530
Message-ID: <1485257822-729-1-git-send-email-varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
        indranil@chelsio.com, varun@chelsio.com
To: bart.vanassche@sandisk.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:39091 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdAXLhg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:37:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For T6 adapters use T6 specific macro to set
force bit.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 4 ++++
 drivers/target/iscsi/cxgbit/cxgbit_target.c | 4 +++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index a267173..21fc2fe 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1349,6 +1349,10 @@ struct cpl_tx_data {
 #define TX_FORCE_S	13
 #define TX_FORCE_V(x)	((x) << TX_FORCE_S)
 
+#define T6_TX_FORCE_S		20
+#define T6_TX_FORCE_V(x)	((x) << T6_TX_FORCE_S)
+#define T6_TX_FORCE_F		T6_TX_FORCE_V(1U)
+
 enum {
 	ULP_TX_MEM_READ = 2,
 	ULP_TX_MEM_WRITE = 3,
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_target.c b/drivers/target/iscsi/cxgbit/cxgbit_target.c
index 8bcb9b7..bcf94aa 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_target.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_target.c
@@ -162,12 +162,14 @@ cxgbit_tx_data_wr(struct cxgbit_sock *csk, struct sk_buff *skb, u32 dlen,
 		  u32 len, u32 credits, u32 compl)
 {
 	struct fw_ofld_tx_data_wr *req;
+	const struct cxgb4_lld_info *lldi = &csk->com.cdev->lldi;
 	u32 submode = cxgbit_skcb_submode(skb);
 	u32 wr_ulp_mode = 0;
 	u32 hdr_size = sizeof(*req);
 	u32 opcode = FW_OFLD_TX_DATA_WR;
 	u32 immlen = 0;
-	u32 force = TX_FORCE_V(!submode);
+	u32 force = is_t5(lldi->adapter_type) ? TX_FORCE_V(!submode) :
+		    T6_TX_FORCE_F;
 
 	if (cxgbit_skcb_flags(skb) & SKCBF_TX_ISO) {
 		opcode = FW_ISCSI_TX_DATA_WR;
-- 
2.0.2
