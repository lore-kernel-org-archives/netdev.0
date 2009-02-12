From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 34/41]bnx2x: Sparse endianity annotation
Date: Thu, 12 Feb 2009 20:38:17 +0200
Message-ID: <1234463897.1863.166.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Harvey Harrison" <harvey.harrison@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758681AbZBLSio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 34/41]bnx2x: Sparse endianity annotation
Resolving the majority of the issues, but there are still some left for future
patches.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   22 +++---
 drivers/net/bnx2x_hsi.h  |  178 +++++++++++++++++++++++-----------------------
 drivers/net/bnx2x_main.c |   63 ++++++++--------
 3 files changed, 132 insertions(+), 131 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index e07d915..bec5aff 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -270,10 +270,10 @@ struct bnx2x_fastpath {
 	u16			tx_pkt_cons;
 	u16			tx_bd_prod;
 	u16			tx_bd_cons;
-	u16			*tx_cons_sb;
+	__le16			*tx_cons_sb;
 
-	u16			fp_c_idx;
-	u16			fp_u_idx;
+	__le16			fp_c_idx;
+	__le16			fp_u_idx;
 
 	u16			rx_bd_prod;
 	u16			rx_bd_cons;
@@ -282,8 +282,8 @@ struct bnx2x_fastpath {
 	u16			rx_sge_prod;
 	/* The last maximal completed SGE */
 	u16			last_max_sge;
-	u16			*rx_cons_sb;
-	u16			*rx_bd_cons_sb;
+	__le16			*rx_cons_sb;
+	__le16			*rx_bd_cons_sb;
 
 	unsigned long		tx_pkt,
 				rx_pkt,
@@ -806,11 +806,11 @@ struct bnx2x {
 
 	struct host_def_status_block *def_status_blk;
 #define DEF_SB_ID			16
-	u16			def_c_idx;
-	u16			def_u_idx;
-	u16			def_x_idx;
-	u16			def_t_idx;
-	u16			def_att_idx;
+	__le16			def_c_idx;
+	__le16			def_u_idx;
+	__le16			def_x_idx;
+	__le16			def_t_idx;
+	__le16			def_att_idx;
 	u32			attn_state;
 	struct attn_route	attn_group[MAX_DYNAMIC_ATTN_GRPS];
 
@@ -820,7 +820,7 @@ struct bnx2x {
 	u16			spq_prod_idx;
 	struct eth_spe		*spq_prod_bd;
 	struct eth_spe		*spq_last_bd;
-	u16			*dsb_sp_prod;
+	__le16			*dsb_sp_prod;
 	u16			spq_left; /* serialize spq */
 	/* used to synchronize spq accesses */
 	spinlock_t		spq_lock;
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 88b2aa3..c779999 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1201,12 +1201,12 @@ struct host_func_stats {
  * attention bits
  */
 struct atten_def_status_block {
-	u32 attn_bits;
-	u32 attn_bits_ack;
+	__le32 attn_bits;
+	__le32 attn_bits_ack;
 	u8 status_block_id;
 	u8 reserved0;
-	u16 attn_bits_index;
-	u32 reserved1;
+	__le16 attn_bits_index;
+	__le32 reserved1;
 };
 
 
@@ -1279,7 +1279,7 @@ struct igu_ack_register {
  * Parser parsing flags field
  */
 struct parsing_flags {
-	u16 flags;
+	__le16 flags;
 #define PARSING_FLAGS_ETHERNET_ADDRESS_TYPE (0x1<<0)
 #define PARSING_FLAGS_ETHERNET_ADDRESS_TYPE_SHIFT 0
 #define PARSING_FLAGS_VLAN (0x1<<1)
@@ -1310,8 +1310,8 @@ struct parsing_flags {
 
 
 struct regpair {
-	u32 lo;
-	u32 hi;
+	__le32 lo;
+	__le32 hi;
 };
 
 
@@ -1470,16 +1470,16 @@ struct ustorm_eth_st_context_config {
  * The eth Rx Buffer Descriptor
  */
 struct eth_rx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 };
 
 /*
  * The eth Rx SGE Descriptor
  */
 struct eth_rx_sge {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 };
 
 /*
@@ -1882,11 +1882,11 @@ struct eth_tx_bd_flags {
  * The eth Tx Buffer Descriptor
  */
 struct eth_tx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
-	u16 nbd;
-	u16 nbytes;
-	u16 vlan;
+	__le32 addr_lo;
+	__le32 addr_hi;
+	__le16 nbd;
+	__le16 nbytes;
+	__le16 vlan;
 	struct eth_tx_bd_flags bd_flags;
 	u8 general_data;
 #define ETH_TX_BD_HDR_NBDS (0x3F<<0)
@@ -1929,11 +1929,11 @@ struct eth_tx_parse_bd {
 #define ETH_TX_PARSE_BD_CWR_FLG_SHIFT 7
 	u8 ip_hlen;
 	s8 cs_offset;
-	u16 total_hlen;
-	u16 lso_mss;
-	u16 tcp_pseudo_csum;
-	u16 ip_id;
-	u32 tcp_send_seq;
+	__le16 total_hlen;
+	__le16 lso_mss;
+	__le16 tcp_pseudo_csum;
+	__le16 ip_id;
+	__le32 tcp_send_seq;
 };
 
 /*
@@ -2049,44 +2049,44 @@ struct eth_tx_doorbell {
  * ustorm status block
  */
 struct ustorm_def_status_block {
-	u16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
  * cstorm status block
  */
 struct cstorm_def_status_block {
-	u16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
  * xstorm status block
  */
 struct xstorm_def_status_block {
-	u16 index_values[HC_XSTORM_DEF_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_XSTORM_DEF_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
  * tstorm status block
  */
 struct tstorm_def_status_block {
-	u16 index_values[HC_TSTORM_DEF_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_TSTORM_DEF_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
@@ -2105,22 +2105,22 @@ struct host_def_status_block {
  * ustorm status block
  */
 struct ustorm_status_block {
-	u16 index_values[HC_USTORM_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_USTORM_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
  * cstorm status block
  */
 struct cstorm_status_block {
-	u16 index_values[HC_CSTORM_SB_NUM_INDICES];
-	u16 status_block_index;
+	__le16 index_values[HC_CSTORM_SB_NUM_INDICES];
+	__le16 status_block_index;
 	u8 func;
 	u8 status_block_id;
-	u32 __flags;
+	__le32 __flags;
 };
 
 /*
@@ -2186,12 +2186,12 @@ struct eth_fast_path_rx_cqe {
 #define ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG_SHIFT 7
 	u8 placement_offset;
 	u8 queue_index;
-	u32 rss_hash_result;
-	u16 vlan_tag;
-	u16 pkt_len;
-	u16 len_on_bd;
+	__le32 rss_hash_result;
+	__le16 vlan_tag;
+	__le16 pkt_len;
+	__le16 len_on_bd;
 	struct parsing_flags pars_flags;
-	u16 sgl[8];
+	__le16 sgl[8];
 };
 
 
@@ -2225,8 +2225,8 @@ struct eth_query_ramrod_data {
  * Place holder for ramrods protocol specific data
  */
 struct ramrod_data {
-	u32 data_lo;
-	u32 data_hi;
+	__le32 data_lo;
+	__le32 data_hi;
 };
 
 /*
@@ -2257,23 +2257,23 @@ struct common_ramrod_eth_rx_cqe {
 #define COMMON_RAMROD_ETH_RX_CQE_RESERVED0 (0x7F<<1)
 #define COMMON_RAMROD_ETH_RX_CQE_RESERVED0_SHIFT 1
 	u8 conn_type;
-	u16 reserved1;
-	u32 conn_and_cmd_data;
+	__le16 reserved1;
+	__le32 conn_and_cmd_data;
 #define COMMON_RAMROD_ETH_RX_CQE_CID (0xFFFFFF<<0)
 #define COMMON_RAMROD_ETH_RX_CQE_CID_SHIFT 0
 #define COMMON_RAMROD_ETH_RX_CQE_CMD_ID (0xFF<<24)
 #define COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT 24
 	struct ramrod_data protocol_data;
-	u32 reserved2[4];
+	__le32 reserved2[4];
 };
 
 /*
  * Rx Last CQE in page (in ETH)
  */
 struct eth_rx_cqe_next_page {
-	u32 addr_lo;
-	u32 addr_hi;
-	u32 reserved[6];
+	__le32 addr_lo;
+	__le32 addr_hi;
+	__le32 reserved[6];
 };
 
 /*
@@ -2290,17 +2290,17 @@ union eth_rx_cqe {
  * common data for all protocols
  */
 struct spe_hdr {
-	u32 conn_and_cmd_data;
+	__le32 conn_and_cmd_data;
 #define SPE_HDR_CID (0xFFFFFF<<0)
 #define SPE_HDR_CID_SHIFT 0
 #define SPE_HDR_CMD_ID (0xFF<<24)
 #define SPE_HDR_CMD_ID_SHIFT 24
-	u16 type;
+	__le16 type;
 #define SPE_HDR_CONN_TYPE (0xFF<<0)
 #define SPE_HDR_CONN_TYPE_SHIFT 0
 #define SPE_HDR_COMMON_RAMROD (0xFF<<8)
 #define SPE_HDR_COMMON_RAMROD_SHIFT 8
-	u16 reserved;
+	__le16 reserved;
 };
 
 /*
@@ -2329,9 +2329,9 @@ struct eth_spe {
  * doorbell data in host memory
  */
 struct eth_tx_db_data {
-	u32 packets_prod;
-	u16 bds_prod;
-	u16 reserved;
+	__le32 packets_prod;
+	__le16 bds_prod;
+	__le16 reserved;
 };
 
 
@@ -2410,10 +2410,10 @@ struct mac_configuration_hdr {
  * MAC address in list for ramrod
  */
 struct tstorm_cam_entry {
-	u16 lsb_mac_addr;
-	u16 middle_mac_addr;
-	u16 msb_mac_addr;
-	u16 flags;
+	__le16 lsb_mac_addr;
+	__le16 middle_mac_addr;
+	__le16 msb_mac_addr;
+	__le16 flags;
 #define TSTORM_CAM_ENTRY_PORT_ID (0x1<<0)
 #define TSTORM_CAM_ENTRY_PORT_ID_SHIFT 0
 #define TSTORM_CAM_ENTRY_RSRVVAL0 (0x7<<1)
@@ -2462,11 +2462,11 @@ struct mac_configuration_cmd {
  * MAC address in list for ramrod
  */
 struct mac_configuration_entry_e1h {
-	u16 lsb_mac_addr;
-	u16 middle_mac_addr;
-	u16 msb_mac_addr;
-	u16 vlan_id;
-	u16 e1hov_id;
+	__le16 lsb_mac_addr;
+	__le16 middle_mac_addr;
+	__le16 msb_mac_addr;
+	__le16 vlan_id;
+	__le16 e1hov_id;
 	u8 client_id;
 	u8 flags;
 #define MAC_CONFIGURATION_ENTRY_E1H_PORT (0x1<<0)
@@ -2721,16 +2721,16 @@ struct cmng_struct_per_port {
  */
 struct xstorm_per_client_stats {
 	struct regpair total_sent_bytes;
-	u32 total_sent_pkts;
-	u32 unicast_pkts_sent;
+	__le32 total_sent_pkts;
+	__le32 unicast_pkts_sent;
 	struct regpair unicast_bytes_sent;
 	struct regpair multicast_bytes_sent;
-	u32 multicast_pkts_sent;
-	u32 broadcast_pkts_sent;
+	__le32 multicast_pkts_sent;
+	__le32 broadcast_pkts_sent;
 	struct regpair broadcast_bytes_sent;
-	u16 stats_counter;
-	u16 reserved0;
-	u32 reserved1;
+	__le16 stats_counter;
+	__le16 reserved0;
+	__le32 reserved1;
 };
 
 
@@ -2746,10 +2746,10 @@ struct xstorm_common_stats {
  * Protocol-common statistics collected by the Tstorm (per port)
  */
 struct tstorm_per_port_stats {
-	u32 mac_filter_discard;
-	u32 xxoverflow_discard;
-	u32 brb_truncate_discard;
-	u32 mac_discard;
+	__le32 mac_filter_discard;
+	__le32 xxoverflow_discard;
+	__le32 brb_truncate_discard;
+	__le32 mac_discard;
 };
 
 
@@ -2762,17 +2762,17 @@ struct tstorm_per_client_stats {
 	struct regpair rcv_broadcast_bytes;
 	struct regpair rcv_multicast_bytes;
 	struct regpair rcv_error_bytes;
-	u32 checksum_discard;
-	u32 packets_too_big_discard;
-	u32 total_rcv_pkts;
-	u32 rcv_unicast_pkts;
-	u32 rcv_broadcast_pkts;
-	u32 rcv_multicast_pkts;
-	u32 no_buff_discard;
-	u32 ttl0_discard;
-	u16 stats_counter;
-	u16 reserved0;
-	u32 reserved1;
+	__le32 checksum_discard;
+	__le32 packets_too_big_discard;
+	__le32 total_rcv_pkts;
+	__le32 rcv_unicast_pkts;
+	__le32 rcv_broadcast_pkts;
+	__le32 rcv_multicast_pkts;
+	__le32 no_buff_discard;
+	__le32 ttl0_discard;
+	__le16 stats_counter;
+	__le16 reserved0;
+	__le32 reserved1;
 };
 
 /*
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2542ba8..26451f6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -473,7 +473,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 static void bnx2x_fw_dump(struct bnx2x *bp)
 {
 	u32 mark, offset;
-	u32 data[9];
+	__be32 data[9];
 	int word;
 
 	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
@@ -3000,8 +3000,8 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 
 #define UPDATE_EXTEND_TSTAT(s, t) \
 	do { \
-		diff = le32_to_cpu(tclient->s) - old_tclient->s; \
-		old_tclient->s = le32_to_cpu(tclient->s); \
+		diff = le32_to_cpu(tclient->s) - le32_to_cpu(old_tclient->s); \
+		old_tclient->s = tclient->s; \
 		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
 	} while (0)
 
@@ -3014,8 +3014,8 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 
 #define UPDATE_EXTEND_XSTAT(s, t) \
 	do { \
-		diff = le32_to_cpu(xclient->s) - old_xclient->s; \
-		old_xclient->s = le32_to_cpu(xclient->s); \
+		diff = le32_to_cpu(xclient->s) - le32_to_cpu(old_xclient->s); \
+		old_xclient->s = xclient->s; \
 		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
 	} while (0)
 
@@ -3524,7 +3524,10 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 	struct bmac_stats *new = bnx2x_sp(bp, mac_stats.bmac_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
-	struct regpair diff;
+	struct {
+		u32 lo;
+		u32 hi;
+	} diff;
 
 	UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
 	UPDATE_STAT64(rx_stat_grfcs, rx_stat_dot3statsfcserrors);
@@ -3630,7 +3633,10 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 	struct nig_stats *old = &(bp->port.old_nig_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
-	struct regpair diff;
+	struct {
+		u32 lo;
+		u32 hi;
+	} diff;
 	u32 nig_timer_max;
 
 	if (bp->link_vars.mac_type == MAC_TYPE_BMAC)
@@ -3994,12 +4000,12 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 			"mac_discard %u  mac_filter_discard %u  "
 			"xxovrflow_discard %u  brb_truncate_discard %u  "
 			"ttl0_discard %u\n",
-		       old_tclient->checksum_discard,
+		       le32_to_cpu(old_tclient->checksum_discard),
 		       bnx2x_hilo(&qstats->etherstatsoverrsizepkts_hi),
 		       bnx2x_hilo(&qstats->no_buff_discard_hi),
 		       estats->mac_discard, estats->mac_filter_discard,
 		       estats->xxoverflow_discard, estats->brb_truncate_discard,
-		       old_tclient->ttl0_discard);
+		       le32_to_cpu(old_tclient->ttl0_discard));
 
 		for_each_queue(bp, i) {
 			printk(KERN_DEBUG "[%d]: %lu\t%lu\t%lu\n", i,
@@ -6610,9 +6616,9 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	   config->config_table[0].cam_entry.lsb_mac_addr);
 
 	/* broadcast */
-	config->config_table[1].cam_entry.msb_mac_addr = 0xffff;
-	config->config_table[1].cam_entry.middle_mac_addr = 0xffff;
-	config->config_table[1].cam_entry.lsb_mac_addr = 0xffff;
+	config->config_table[1].cam_entry.msb_mac_addr = cpu_to_le16(0xffff);
+	config->config_table[1].cam_entry.middle_mac_addr = cpu_to_le16(0xffff);
+	config->config_table[1].cam_entry.lsb_mac_addr = cpu_to_le16(0xffff);
 	config->config_table[1].cam_entry.flags = cpu_to_le16(port);
 	if (set)
 		config->config_table[1].target_table_entry.flags =
@@ -7035,7 +7041,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 static int bnx2x_stop_leading(struct bnx2x *bp)
 {
-	u16 dsb_sp_prod_idx;
+	__le16 dsb_sp_prod_idx;
 	/* if the other port is handling traffic,
 	   this can take a lot of time */
 	int cnt = 500;
@@ -8625,7 +8631,7 @@ static void bnx2x_disable_nvram_access(struct bnx2x *bp)
 			MCPR_NVM_ACCESS_ENABLE_WR_EN)));
 }
 
-static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
+static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 				  u32 cmd_flags)
 {
 	int count, i, rc;
@@ -8661,8 +8667,7 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
 			/* we read nvram data in cpu order
 			 * but ethtool sees it as an array of bytes
 			 * converting to big-endian will do the work */
-			val = cpu_to_be32(val);
-			*ret_val = val;
+			*ret_val = cpu_to_be32(val);
 			rc = 0;
 			break;
 		}
@@ -8676,7 +8681,7 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 {
 	int rc;
 	u32 cmd_flags;
-	u32 val;
+	__be32 val;
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(BNX2X_MSG_NVM,
@@ -8795,7 +8800,7 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	int rc;
 	u32 cmd_flags;
 	u32 align_offset;
-	u32 val;
+	__be32 val;
 
 	if (offset + buf_size > bp->common.flash_size) {
 		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
@@ -9387,11 +9392,9 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	wmb();
 
-	fp->hw_tx_prods->bds_prod =
-		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + 1);
+	le16_add_cpu(&fp->hw_tx_prods->bds_prod, 1);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod =
-		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
 	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
@@ -9491,7 +9494,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x778,  0x70 },
 		{     0,     0 }
 	};
-	u32 buf[0x350 / 4];
+	__be32 buf[0x350 / 4];
 	u8 *data = (u8 *)buf;
 	int i, rc;
 	u32 magic, csum;
@@ -10130,7 +10133,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		rc = XMIT_PLAIN;
 
 	else {
-		if (skb->protocol == ntohs(ETH_P_IPV6)) {
+		if (skb->protocol == htons(ETH_P_IPV6)) {
 			rc = XMIT_CSUM_V6;
 			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 				rc |= XMIT_CSUM_TCP;
@@ -10340,9 +10343,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		hlen = (skb_network_header(skb) - skb->data + vlan_off) / 2;
 
 		/* for now NS flag is not used in Linux */
-		pbd->global_data = (hlen |
-				    ((skb->protocol == ntohs(ETH_P_8021Q)) <<
-				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
+		pbd->global_data =
+			(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
+				 ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
 
 		pbd->ip_hlen = (skb_transport_header(skb) -
 				skb_network_header(skb)) / 2;
@@ -10486,11 +10489,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	wmb();
 
-	fp->hw_tx_prods->bds_prod =
-		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
+	le16_add_cpu(&fp->hw_tx_prods->bds_prod, nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod =
-		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
 	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
-- 
1.5.4.3




