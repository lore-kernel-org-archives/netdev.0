From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 06/12] cxgb4, cxgb4i: move struct cpl_rx_data_ddp definition
Date: Sun, 13 Mar 2016 19:49:28 +0530
Message-ID: <2e4101f9c306049896ffff513b575e3ba61f93d9.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move struct cpl_rx_data_ddp definition to
common header file t4_msg.h.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 15 +++++++++++++++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h          | 12 ------------
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 8cfc6a8..7279245 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -899,6 +899,21 @@ struct cpl_iscsi_hdr {
 #define ISCSI_DDP_V(x) ((x) << ISCSI_DDP_S)
 #define ISCSI_DDP_F    ISCSI_DDP_V(1U)
 
+struct cpl_rx_data_ddp {
+	union opcode_tid ot;
+	__be16 urg;
+	__be16 len;
+	__be32 seq;
+	union {
+		__be32 nxt_seq;
+		__be32 ddp_report;
+	};
+	__be32 ulp_crc;
+	__be32 ddpvld;
+};
+
+#define cpl_rx_iscsi_ddp cpl_rx_data_ddp
+
 struct cpl_rx_data {
 	union opcode_tid ot;
 	__be16 rsvd;
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
index e5f8f65..2fd9c76 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
@@ -25,16 +25,4 @@
 
 #define T5_ISS_VALID		(1 << 18)
 
-struct cpl_rx_data_ddp {
-	union opcode_tid ot;
-	__be16 urg;
-	__be16 len;
-	__be32 seq;
-	union {
-		__be32 nxt_seq;
-		__be32 ddp_report;
-	};
-	__be32 ulp_crc;
-	__be32 ddpvld;
-};
 #endif	/* __CXGB4I_H__ */
-- 
2.0.2
