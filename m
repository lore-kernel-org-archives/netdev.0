From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 02/13] netxen: fix endianness in firmware commands
Date: Mon, 12 Jan 2009 11:23:00 -0800
Message-ID: <1231788191-23794-3-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:36352 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754988AbZALT3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:29:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Set restricted (little endian) data types in firmware command
  requests and responses.
o Remove unnecessary conversion to le when writing registers.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h     |  100 +++++++++++++++++------------------
 drivers/net/netxen/netxen_nic_ctx.c |   38 +++++++-------
 drivers/net/netxen/netxen_nic_hw.c  |   27 ++++++---
 3 files changed, 86 insertions(+), 79 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index a434bae..43fcc8a 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -995,31 +995,31 @@ struct netxen_recv_context {
  */
 
 typedef struct {
-	u64 host_phys_addr;	/* Ring base addr */
-	u32 ring_size;		/* Ring entries */
-	u16 msi_index;
-	u16 rsvd;		/* Padding */
+	__le64 host_phys_addr;	/* Ring base addr */
+	__le32 ring_size;		/* Ring entries */
+	__le16 msi_index;
+	__le16 rsvd;		/* Padding */
 } nx_hostrq_sds_ring_t;
 
 typedef struct {
-	u64 host_phys_addr;	/* Ring base addr */
-	u64 buff_size;		/* Packet buffer size */
-	u32 ring_size;		/* Ring entries */
-	u32 ring_kind;		/* Class of ring */
+	__le64 host_phys_addr;	/* Ring base addr */
+	__le64 buff_size;		/* Packet buffer size */
+	__le32 ring_size;		/* Ring entries */
+	__le32 ring_kind;		/* Class of ring */
 } nx_hostrq_rds_ring_t;
 
 typedef struct {
-	u64 host_rsp_dma_addr;	/* Response dma'd here */
-	u32 capabilities[4];	/* Flag bit vector */
-	u32 host_int_crb_mode;	/* Interrupt crb usage */
-	u32 host_rds_crb_mode;	/* RDS crb usage */
+	__le64 host_rsp_dma_addr;	/* Response dma'd here */
+	__le32 capabilities[4];	/* Flag bit vector */
+	__le32 host_int_crb_mode;	/* Interrupt crb usage */
+	__le32 host_rds_crb_mode;	/* RDS crb usage */
 	/* These ring offsets are relative to data[0] below */
-	u32 rds_ring_offset;	/* Offset to RDS config */
-	u32 sds_ring_offset;	/* Offset to SDS config */
-	u16 num_rds_rings;	/* Count of RDS rings */
-	u16 num_sds_rings;	/* Count of SDS rings */
-	u16 rsvd1;		/* Padding */
-	u16 rsvd2;		/* Padding */
+	__le32 rds_ring_offset;	/* Offset to RDS config */
+	__le32 sds_ring_offset;	/* Offset to SDS config */
+	__le16 num_rds_rings;	/* Count of RDS rings */
+	__le16 num_sds_rings;	/* Count of SDS rings */
+	__le16 rsvd1;		/* Padding */
+	__le16 rsvd2;		/* Padding */
 	u8  reserved[128]; 	/* reserve space for future expansion*/
 	/* MUST BE 64-bit aligned.
 	   The following is packed:
@@ -1029,24 +1029,24 @@ typedef struct {
 } nx_hostrq_rx_ctx_t;
 
 typedef struct {
-	u32 host_producer_crb;	/* Crb to use */
-	u32 rsvd1;		/* Padding */
+	__le32 host_producer_crb;	/* Crb to use */
+	__le32 rsvd1;		/* Padding */
 } nx_cardrsp_rds_ring_t;
 
 typedef struct {
-	u32 host_consumer_crb;	/* Crb to use */
-	u32 interrupt_crb;	/* Crb to use */
+	__le32 host_consumer_crb;	/* Crb to use */
+	__le32 interrupt_crb;	/* Crb to use */
 } nx_cardrsp_sds_ring_t;
 
 typedef struct {
 	/* These ring offsets are relative to data[0] below */
-	u32 rds_ring_offset;	/* Offset to RDS config */
-	u32 sds_ring_offset;	/* Offset to SDS config */
-	u32 host_ctx_state;	/* Starting State */
-	u32 num_fn_per_port;	/* How many PCI fn share the port */
-	u16 num_rds_rings;	/* Count of RDS rings */
-	u16 num_sds_rings;	/* Count of SDS rings */
-	u16 context_id;		/* Handle for context */
+	__le32 rds_ring_offset;	/* Offset to RDS config */
+	__le32 sds_ring_offset;	/* Offset to SDS config */
+	__le32 host_ctx_state;	/* Starting State */
+	__le32 num_fn_per_port;	/* How many PCI fn share the port */
+	__le16 num_rds_rings;	/* Count of RDS rings */
+	__le16 num_sds_rings;	/* Count of SDS rings */
+	__le16 context_id;		/* Handle for context */
 	u8  phys_port;		/* Physical id of port */
 	u8  virt_port;		/* Virtual/Logical id of port */
 	u8  reserved[128];	/* save space for future expansion */
@@ -1072,34 +1072,34 @@ typedef struct {
  */
 
 typedef struct {
-	u64 host_phys_addr;	/* Ring base addr */
-	u32 ring_size;		/* Ring entries */
-	u32 rsvd;		/* Padding */
+	__le64 host_phys_addr;	/* Ring base addr */
+	__le32 ring_size;		/* Ring entries */
+	__le32 rsvd;		/* Padding */
 } nx_hostrq_cds_ring_t;
 
 typedef struct {
-	u64 host_rsp_dma_addr;	/* Response dma'd here */
-	u64 cmd_cons_dma_addr;	/*  */
-	u64 dummy_dma_addr;	/*  */
-	u32 capabilities[4];	/* Flag bit vector */
-	u32 host_int_crb_mode;	/* Interrupt crb usage */
-	u32 rsvd1;		/* Padding */
-	u16 rsvd2;		/* Padding */
-	u16 interrupt_ctl;
-	u16 msi_index;
-	u16 rsvd3;		/* Padding */
+	__le64 host_rsp_dma_addr;	/* Response dma'd here */
+	__le64 cmd_cons_dma_addr;	/*  */
+	__le64 dummy_dma_addr;	/*  */
+	__le32 capabilities[4];	/* Flag bit vector */
+	__le32 host_int_crb_mode;	/* Interrupt crb usage */
+	__le32 rsvd1;		/* Padding */
+	__le16 rsvd2;		/* Padding */
+	__le16 interrupt_ctl;
+	__le16 msi_index;
+	__le16 rsvd3;		/* Padding */
 	nx_hostrq_cds_ring_t cds_ring;	/* Desc of cds ring */
 	u8  reserved[128];	/* future expansion */
 } nx_hostrq_tx_ctx_t;
 
 typedef struct {
-	u32 host_producer_crb;	/* Crb to use */
-	u32 interrupt_crb;	/* Crb to use */
+	__le32 host_producer_crb;	/* Crb to use */
+	__le32 interrupt_crb;	/* Crb to use */
 } nx_cardrsp_cds_ring_t;
 
 typedef struct {
-	u32 host_ctx_state;	/* Starting state */
-	u16 context_id;		/* Handle for context */
+	__le32 host_ctx_state;	/* Starting state */
+	__le16 context_id;		/* Handle for context */
 	u8  phys_port;		/* Physical id of port */
 	u8  virt_port;		/* Virtual/Logical id of port */
 	nx_cardrsp_cds_ring_t cds_ring;	/* Card cds settings */
@@ -1202,9 +1202,9 @@ enum {
 #define VPORT_MISS_MODE_ACCEPT_MULTI	2 /* accept unmatched multicast */
 
 typedef struct {
-	u64 qhdr;
-	u64 req_hdr;
-	u64 words[6];
+	__le64 qhdr;
+	__le64 req_hdr;
+	__le64 words[6];
 } nx_nic_req_t;
 
 typedef struct {
@@ -1617,8 +1617,6 @@ int netxen_is_flash_supported(struct netxen_adapter *adapter);
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac);
 int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
-extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
-				int *valp);
 
 extern struct ethtool_ops netxen_nic_ethtool_ops;
 
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 64b5164..765d79e 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -110,19 +110,19 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 		return NX_RCODE_TIMEOUT;
 
 	netxen_nic_write_w1(adapter, NX_SIGN_CRB_OFFSET,
-			cpu_to_le32(signature));
+			(__force u32)cpu_to_le32(signature));
 
 	netxen_nic_write_w1(adapter, NX_ARG1_CRB_OFFSET,
-			cpu_to_le32(arg1));
+			(__force u32)cpu_to_le32(arg1));
 
 	netxen_nic_write_w1(adapter, NX_ARG2_CRB_OFFSET,
-			cpu_to_le32(arg2));
+			(__force u32)cpu_to_le32(arg2));
 
 	netxen_nic_write_w1(adapter, NX_ARG3_CRB_OFFSET,
-			cpu_to_le32(arg3));
+			(__force u32)cpu_to_le32(arg3));
 
 	netxen_nic_write_w1(adapter, NX_CDRP_CRB_OFFSET,
-			cpu_to_le32(NX_CDRP_FORM_CMD(cmd)));
+			(__force u32)cpu_to_le32(NX_CDRP_FORM_CMD(cmd)));
 
 	rsp = netxen_poll_rsp(adapter);
 
@@ -183,7 +183,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	int i, nrds_rings, nsds_rings;
 	size_t rq_size, rsp_size;
-	u32 cap, reg;
+	u32 cap, reg, val;
 
 	int err;
 
@@ -225,11 +225,14 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	prq->num_rds_rings = cpu_to_le16(nrds_rings);
 	prq->num_sds_rings = cpu_to_le16(nsds_rings);
-	prq->rds_ring_offset = 0;
-	prq->sds_ring_offset = prq->rds_ring_offset +
+	prq->rds_ring_offset = cpu_to_le32(0);
+
+	val = le32_to_cpu(prq->rds_ring_offset) +
 		(sizeof(nx_hostrq_rds_ring_t) * nrds_rings);
+	prq->sds_ring_offset = cpu_to_le32(val);
 
-	prq_rds = (nx_hostrq_rds_ring_t *)(prq->data + prq->rds_ring_offset);
+	prq_rds = (nx_hostrq_rds_ring_t *)(prq->data +
+			le32_to_cpu(prq->rds_ring_offset));
 
 	for (i = 0; i < nrds_rings; i++) {
 
@@ -241,17 +244,14 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
 	}
 
-	prq_sds = (nx_hostrq_sds_ring_t *)(prq->data + prq->sds_ring_offset);
+	prq_sds = (nx_hostrq_sds_ring_t *)(prq->data +
+			le32_to_cpu(prq->sds_ring_offset));
 
 	prq_sds[0].host_phys_addr =
 		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
 	prq_sds[0].ring_size = cpu_to_le32(adapter->max_rx_desc_count);
 	/* only one msix vector for now */
-	prq_sds[0].msi_index = cpu_to_le32(0);
-
-	/* now byteswap offsets */
-	prq->rds_ring_offset = cpu_to_le32(prq->rds_ring_offset);
-	prq->sds_ring_offset = cpu_to_le32(prq->sds_ring_offset);
+	prq_sds[0].msi_index = cpu_to_le16(0);
 
 	phys_addr = hostrq_phys_addr;
 	err = netxen_issue_cmd(adapter,
@@ -269,9 +269,9 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 
 	prsp_rds = ((nx_cardrsp_rds_ring_t *)
-			 &prsp->data[prsp->rds_ring_offset]);
+			 &prsp->data[le32_to_cpu(prsp->rds_ring_offset)]);
 
-	for (i = 0; i < le32_to_cpu(prsp->num_rds_rings); i++) {
+	for (i = 0; i < le16_to_cpu(prsp->num_rds_rings); i++) {
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
@@ -279,7 +279,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	}
 
 	prsp_sds = ((nx_cardrsp_sds_ring_t *)
-			&prsp->data[prsp->sds_ring_offset]);
+			&prsp->data[le32_to_cpu(prsp->sds_ring_offset)]);
 	reg = le32_to_cpu(prsp_sds[0].host_consumer_crb);
 	recv_ctx->crb_sts_consumer = NETXEN_NIC_REG(reg - 0x200);
 
@@ -288,7 +288,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
 	recv_ctx->context_id = le16_to_cpu(prsp->context_id);
-	recv_ctx->virt_port = le16_to_cpu(prsp->virt_port);
+	recv_ctx->virt_port = prsp->virt_port;
 
 out_free_rsp:
 	pci_free_consistent(adapter->pdev, rsp_size, prsp, cardrsp_phys_addr);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index b9cd6a7..0b150ca 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -540,12 +540,15 @@ static int nx_p3_sre_macaddr_change(struct net_device *dev,
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	nx_nic_req_t req;
 	nx_mac_req_t mac_req;
+	u64 word;
 	int rv;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
-	req.qhdr |= (NX_NIC_REQUEST << 23);
-	req.req_hdr |= NX_MAC_EVENT;
-	req.req_hdr |= ((u64)adapter->portnum << 16);
+	req.qhdr = cpu_to_le64(NX_NIC_REQUEST << 23);
+
+	word = NX_MAC_EVENT | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
 	mac_req.op = op;
 	memcpy(&mac_req.mac_addr, addr, 6);
 	req.words[0] = cpu_to_le64(*(u64 *)&mac_req);
@@ -612,12 +615,16 @@ send_fw_cmd:
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 {
 	nx_nic_req_t req;
+	u64 word;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
-	req.qhdr |= (NX_HOST_REQUEST << 23);
-	req.req_hdr |= NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE;
-	req.req_hdr |= ((u64)adapter->portnum << 16);
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE |
+			((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
 	req.words[0] = cpu_to_le64(mode);
 
 	return netxen_send_cmd_descs(adapter,
@@ -632,13 +639,15 @@ int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 {
 	nx_nic_req_t req;
+	u64 word;
 	int rv;
 
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
-	req.qhdr |= (NX_NIC_REQUEST << 23);
-	req.req_hdr |= NETXEN_CONFIG_INTR_COALESCE;
-	req.req_hdr |= ((u64)adapter->portnum << 16);
+	req.qhdr = cpu_to_le64(NX_NIC_REQUEST << 23);
+
+	word = NETXEN_CONFIG_INTR_COALESCE | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
 
 	memcpy(&req.words[0], &adapter->coal, sizeof(adapter->coal));
 
-- 
1.6.0.2

