From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next v2 1/4] cxgb4/iw_cxgb4/cxgb4i: remove duplicate definitions
Date: Mon, 13 Apr 2015 19:34:23 +0530
Message-ID: <6358f849b5a1a3727879f4f2f5c855e3a5b95ab4.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13159 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754017AbbDMOF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:05:27 -0400
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

define struct ulptx_idata in common header file t4_msg.h
to remove duplicate definitions.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h   |    9 ---------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |    5 +++++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h          |    5 -----
 3 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 5e53327..210f04a 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -818,15 +818,6 @@ struct cpl_pass_accept_req {
 #define SYN_INTF_V(x) ((x) << SYN_INTF_S)
 #define SYN_INTF_G(x) (((x) >> SYN_INTF_S) & SYN_INTF_M)
 
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
index 30a2f56..7e2137d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1054,6 +1054,11 @@ struct ulptx_sgl {
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
index 1096026..342263b 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.h
@@ -23,11 +23,6 @@
 #define CXGB4I_TX_HEADER_LEN \
 	(sizeof(struct fw_ofld_tx_data_wr) + sizeof(struct sge_opaque_hdr))
 
-struct ulptx_idata {
-	__be32 cmd_more;
-	__be32 len;
-};
-
 struct cpl_rx_data_ddp {
 	union opcode_tid ot;
 	__be16 urg;
-- 
1.7.1
