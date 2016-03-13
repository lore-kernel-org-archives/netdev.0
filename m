From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 05/12] cxgb4, iw_cxgb4, cxgb4i: remove duplicate definitions
Date: Sun, 13 Mar 2016 18:58:55 +0530
Message-ID: <98c6ebab234a6e08ffcd875699be85a18e82b3f2.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:25645 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932138AbcCMN31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 09:29:27 -0400
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move struct ulptx_idata definition to
common header file t4_msg.h.

Signed-off-by: Varun Prakash <varun@chelsio.com>
Signed-off-by: Nicholas Bellinger <nab@linux-iscsi.org>
---
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h   | 9 ---------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 5 +++++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h          | 5 -----
 3 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 5b66da3..5f47e03 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -753,15 +753,6 @@ struct fw_ri_wr {
 #define FW_RI_WR_P2PTYPE_G(x)	\
 	(((x) >> FW_RI_WR_P2PTYPE_S) & FW_RI_WR_P2PTYPE_M)
 
-struct ulptx_idata {
-	__be32 cmd_more;
-	__be32 len;
-};
-
-#define ULPTX_NSGE_S    0
-#define ULPTX_NSGE_M    0xFFFF
-#define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
-
 #define RX_DACK_MODE_S    29
 #define RX_DACK_MODE_M    0x3
 #define RX_DACK_MODE_V(x) ((x) << RX_DACK_MODE_S)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 5753bd4..8cfc6a8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1222,6 +1222,11 @@ struct ulptx_sgl {
 	struct ulptx_sge_pair sge[0];
 };
 
+struct ulptx_idata {
+	__be32 cmd_more;
+	__be32 len;
+};
+
 #define ULPTX_NSGE_S    0
 #define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
 
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
index 22dd8d6..e5f8f65 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
@@ -25,11 +25,6 @@
 
 #define T5_ISS_VALID		(1 << 18)
 
-struct ulptx_idata {
-	__be32 cmd_more;
-	__be32 len;
-};
-
 struct cpl_rx_data_ddp {
 	union opcode_tid ot;
 	__be16 urg;
-- 
2.0.2
