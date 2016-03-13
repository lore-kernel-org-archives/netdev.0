From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 07/12] cxgb4: add definitions for iSCSI target ULD
Date: Sun, 13 Mar 2016 19:49:29 +0530
Message-ID: <3cc5e8cd8fb1be6f0828814edebdc9980465f808.1457877852.git.varun@chelsio.com>
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

add structure, macro and constant definitions
for iSCSI Tx and Rx.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h   | 107 ++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |   7 ++
 2 files changed, 114 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 7279245..03da7a7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -51,6 +51,7 @@ enum {
 	CPL_TX_PKT            = 0xE,
 	CPL_L2T_WRITE_REQ     = 0x12,
 	CPL_TID_RELEASE       = 0x1A,
+	CPL_TX_DATA_ISO	      = 0x1F,
 
 	CPL_CLOSE_LISTSRV_RPL = 0x20,
 	CPL_L2T_WRITE_RPL     = 0x23,
@@ -914,6 +915,95 @@ struct cpl_rx_data_ddp {
 
 #define cpl_rx_iscsi_ddp cpl_rx_data_ddp
 
+struct cpl_iscsi_data {
+	union opcode_tid ot;
+	__u8 rsvd0[2];
+	__be16 len;
+	__be32 seq;
+	__be16 urg;
+	__u8 rsvd1;
+	__u8 status;
+};
+
+struct cpl_tx_data_iso {
+	__be32 op_to_scsi;
+	__u8   reserved1;
+	__u8   ahs_len;
+	__be16 mpdu;
+	__be32 burst_size;
+	__be32 len;
+	__be32 reserved2_seglen_offset;
+	__be32 datasn_offset;
+	__be32 buffer_offset;
+	__be32 reserved3;
+
+	/* encapsulated CPL_TX_DATA follows here */
+};
+
+/* cpl_tx_data_iso.op_to_scsi fields */
+#define CPL_TX_DATA_ISO_OP_S	24
+#define CPL_TX_DATA_ISO_OP_M	0xff
+#define CPL_TX_DATA_ISO_OP_V(x)	((x) << CPL_TX_DATA_ISO_OP_S)
+#define CPL_TX_DATA_ISO_OP_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_OP_S) & CPL_TX_DATA_ISO_OP_M)
+
+#define CPL_TX_DATA_ISO_FIRST_S		23
+#define CPL_TX_DATA_ISO_FIRST_M		0x1
+#define CPL_TX_DATA_ISO_FIRST_V(x)	((x) << CPL_TX_DATA_ISO_FIRST_S)
+#define CPL_TX_DATA_ISO_FIRST_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_FIRST_S) & CPL_TX_DATA_ISO_FIRST_M)
+#define CPL_TX_DATA_ISO_FIRST_F	CPL_TX_DATA_ISO_FIRST_V(1U)
+
+#define CPL_TX_DATA_ISO_LAST_S		22
+#define CPL_TX_DATA_ISO_LAST_M		0x1
+#define CPL_TX_DATA_ISO_LAST_V(x)	((x) << CPL_TX_DATA_ISO_LAST_S)
+#define CPL_TX_DATA_ISO_LAST_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_LAST_S) & CPL_TX_DATA_ISO_LAST_M)
+#define CPL_TX_DATA_ISO_LAST_F	CPL_TX_DATA_ISO_LAST_V(1U)
+
+#define CPL_TX_DATA_ISO_CPLHDRLEN_S	21
+#define CPL_TX_DATA_ISO_CPLHDRLEN_M	0x1
+#define CPL_TX_DATA_ISO_CPLHDRLEN_V(x)	((x) << CPL_TX_DATA_ISO_CPLHDRLEN_S)
+#define CPL_TX_DATA_ISO_CPLHDRLEN_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_CPLHDRLEN_S) & CPL_TX_DATA_ISO_CPLHDRLEN_M)
+#define CPL_TX_DATA_ISO_CPLHDRLEN_F	CPL_TX_DATA_ISO_CPLHDRLEN_V(1U)
+
+#define CPL_TX_DATA_ISO_HDRCRC_S	20
+#define CPL_TX_DATA_ISO_HDRCRC_M	0x1
+#define CPL_TX_DATA_ISO_HDRCRC_V(x)	((x) << CPL_TX_DATA_ISO_HDRCRC_S)
+#define CPL_TX_DATA_ISO_HDRCRC_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_HDRCRC_S) & CPL_TX_DATA_ISO_HDRCRC_M)
+#define CPL_TX_DATA_ISO_HDRCRC_F	CPL_TX_DATA_ISO_HDRCRC_V(1U)
+
+#define CPL_TX_DATA_ISO_PLDCRC_S	19
+#define CPL_TX_DATA_ISO_PLDCRC_M	0x1
+#define CPL_TX_DATA_ISO_PLDCRC_V(x)	((x) << CPL_TX_DATA_ISO_PLDCRC_S)
+#define CPL_TX_DATA_ISO_PLDCRC_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_PLDCRC_S) & CPL_TX_DATA_ISO_PLDCRC_M)
+#define CPL_TX_DATA_ISO_PLDCRC_F	CPL_TX_DATA_ISO_PLDCRC_V(1U)
+
+#define CPL_TX_DATA_ISO_IMMEDIATE_S	18
+#define CPL_TX_DATA_ISO_IMMEDIATE_M	0x1
+#define CPL_TX_DATA_ISO_IMMEDIATE_V(x)	((x) << CPL_TX_DATA_ISO_IMMEDIATE_S)
+#define CPL_TX_DATA_ISO_IMMEDIATE_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_IMMEDIATE_S) & CPL_TX_DATA_ISO_IMMEDIATE_M)
+#define CPL_TX_DATA_ISO_IMMEDIATE_F	CPL_TX_DATA_ISO_IMMEDIATE_V(1U)
+
+#define CPL_TX_DATA_ISO_SCSI_S		16
+#define CPL_TX_DATA_ISO_SCSI_M		0x3
+#define CPL_TX_DATA_ISO_SCSI_V(x)	((x) << CPL_TX_DATA_ISO_SCSI_S)
+#define CPL_TX_DATA_ISO_SCSI_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_SCSI_S) & CPL_TX_DATA_ISO_SCSI_M)
+
+/* cpl_tx_data_iso.reserved2_seglen_offset fields */
+#define CPL_TX_DATA_ISO_SEGLEN_OFFSET_S		0
+#define CPL_TX_DATA_ISO_SEGLEN_OFFSET_M		0xffffff
+#define CPL_TX_DATA_ISO_SEGLEN_OFFSET_V(x)	\
+	((x) << CPL_TX_DATA_ISO_SEGLEN_OFFSET_S)
+#define CPL_TX_DATA_ISO_SEGLEN_OFFSET_G(x)	\
+	(((x) >> CPL_TX_DATA_ISO_SEGLEN_OFFSET_S) & \
+	 CPL_TX_DATA_ISO_SEGLEN_OFFSET_M)
+
 struct cpl_rx_data {
 	union opcode_tid ot;
 	__be16 rsvd;
@@ -1184,6 +1274,12 @@ struct cpl_fw4_ack {
 	__be64 rsvd1;
 };
 
+enum {
+	CPL_FW4_ACK_FLAGS_SEQVAL	= 0x1,	/* seqn valid */
+	CPL_FW4_ACK_FLAGS_CH		= 0x2,	/* channel change complete */
+	CPL_FW4_ACK_FLAGS_FLOWC		= 0x4,	/* fw_flowc_wr complete */
+};
+
 struct cpl_fw6_msg {
 	u8 opcode;
 	u8 type;
@@ -1209,6 +1305,17 @@ struct cpl_fw6_msg_ofld_connection_wr_rpl {
 	__u8    rsvd[2];
 };
 
+struct cpl_tx_data {
+	union opcode_tid ot;
+	__be32 len;
+	__be32 rsvd;
+	__be32 flags;
+};
+
+/* cpl_tx_data.flags field */
+#define TX_FORCE_S	13
+#define TX_FORCE_V(x)	((x) << TX_FORCE_S)
+
 enum {
 	ULP_TX_MEM_READ = 2,
 	ULP_TX_MEM_WRITE = 3,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index a32de30..7ad6d4e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -101,6 +101,7 @@ enum fw_wr_opcodes {
 	FW_RI_BIND_MW_WR               = 0x18,
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
+	FW_ISCSI_TX_DATA_WR	       = 0x45,
 	FW_LASTC2E_WR                  = 0x70
 };
 
@@ -561,6 +562,12 @@ enum fw_flowc_mnem {
 	FW_FLOWC_MNEM_SNDBUF,
 	FW_FLOWC_MNEM_MSS,
 	FW_FLOWC_MNEM_TXDATAPLEN_MAX,
+	FW_FLOWC_MNEM_TCPSTATE,
+	FW_FLOWC_MNEM_EOSTATE,
+	FW_FLOWC_MNEM_SCHEDCLASS,
+	FW_FLOWC_MNEM_DCBPRIO,
+	FW_FLOWC_MNEM_SND_SCALE,
+	FW_FLOWC_MNEM_RCV_SCALE,
 };
 
 struct fw_flowc_mnemval {
-- 
2.0.2
