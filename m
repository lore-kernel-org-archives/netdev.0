From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 05/19] bna: use BIT(x) instead of (1 << x)
Date: Thu, 11 Jun 2015 15:52:17 +0200
Message-ID: <1434030751-28835-6-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596AbbFKNwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:11 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |  2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |  2 +-
 drivers/net/ethernet/brocade/bna/bfi_enet.h        | 66 ++++++++++----------
 drivers/net/ethernet/brocade/bna/bna_enet.c        |  4 +-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     | 70 +++++++++++-----------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       | 22 +++----
 6 files changed, 83 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 679a503..16090fd 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -75,7 +75,7 @@ enum {
 	CB_GPIO_FC4P2   = (4),		/*!< 4G 2port FC card		*/
 	CB_GPIO_FC4P1   = (5),		/*!< 4G 1port FC card		*/
 	CB_GPIO_DFLY    = (6),		/*!< 8G 2port FC mezzanine card	*/
-	CB_GPIO_PROTO   = (1 << 7)	/*!< 8G 2port FC prototypes	*/
+	CB_GPIO_PROTO   = BIT(7)	/*!< 8G 2port FC prototypes	*/
 };
 
 #define bfa_mfg_adapter_prop_init_gpio(gpio, card_type, prop)	\
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index 2e72445..4247d8a 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -24,7 +24,7 @@
 #include "bfa_defs.h"
 
 #define bfa_ioc_ct_sync_pos(__ioc)	\
-		((u32) (1 << bfa_ioc_pcifn(__ioc)))
+		((u32)BIT(bfa_ioc_pcifn(__ioc)))
 #define BFA_IOC_SYNC_REQD_SH		16
 #define bfa_ioc_ct_get_sync_ackd(__val) (__val & 0x0000ffff)
 #define bfa_ioc_ct_clear_sync_ackd(__val) (__val & 0xffff0000)
diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index fad3a12..d7be7ea8 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -68,13 +68,13 @@ union bfi_addr_be_u {
 #define BFI_ENET_TXQ_WI_EXTENSION	(0x104)	/* Extension WI */
 
 /* TxQ Entry Control Flags */
-#define BFI_ENET_TXQ_WI_CF_FCOE_CRC	(1 << 8)
-#define BFI_ENET_TXQ_WI_CF_IPID_MODE	(1 << 5)
-#define BFI_ENET_TXQ_WI_CF_INS_PRIO	(1 << 4)
-#define BFI_ENET_TXQ_WI_CF_INS_VLAN	(1 << 3)
-#define BFI_ENET_TXQ_WI_CF_UDP_CKSUM	(1 << 2)
-#define BFI_ENET_TXQ_WI_CF_TCP_CKSUM	(1 << 1)
-#define BFI_ENET_TXQ_WI_CF_IP_CKSUM	(1 << 0)
+#define BFI_ENET_TXQ_WI_CF_FCOE_CRC	BIT(8)
+#define BFI_ENET_TXQ_WI_CF_IPID_MODE	BIT(5)
+#define BFI_ENET_TXQ_WI_CF_INS_PRIO	BIT(4)
+#define BFI_ENET_TXQ_WI_CF_INS_VLAN	BIT(3)
+#define BFI_ENET_TXQ_WI_CF_UDP_CKSUM	BIT(2)
+#define BFI_ENET_TXQ_WI_CF_TCP_CKSUM	BIT(1)
+#define BFI_ENET_TXQ_WI_CF_IP_CKSUM	BIT(0)
 
 struct bfi_enet_txq_wi_base {
 	u8			reserved;
@@ -122,32 +122,32 @@ struct bfi_enet_rxq_entry {
 
 /*   R X   C O M P L E T I O N   Q U E U E   D E F I N E S   */
 /* CQ Entry Flags */
-#define	BFI_ENET_CQ_EF_MAC_ERROR	(1 <<  0)
-#define	BFI_ENET_CQ_EF_FCS_ERROR	(1 <<  1)
-#define	BFI_ENET_CQ_EF_TOO_LONG		(1 <<  2)
-#define	BFI_ENET_CQ_EF_FC_CRC_OK	(1 <<  3)
+#define BFI_ENET_CQ_EF_MAC_ERROR	BIT(0)
+#define BFI_ENET_CQ_EF_FCS_ERROR	BIT(1)
+#define BFI_ENET_CQ_EF_TOO_LONG		BIT(2)
+#define BFI_ENET_CQ_EF_FC_CRC_OK	BIT(3)
 
-#define	BFI_ENET_CQ_EF_RSVD1		(1 <<  4)
-#define	BFI_ENET_CQ_EF_L4_CKSUM_OK	(1 <<  5)
-#define	BFI_ENET_CQ_EF_L3_CKSUM_OK	(1 <<  6)
-#define	BFI_ENET_CQ_EF_HDS_HEADER	(1 <<  7)
+#define BFI_ENET_CQ_EF_RSVD1		BIT(4)
+#define BFI_ENET_CQ_EF_L4_CKSUM_OK	BIT(5)
+#define BFI_ENET_CQ_EF_L3_CKSUM_OK	BIT(6)
+#define BFI_ENET_CQ_EF_HDS_HEADER	BIT(7)
 
-#define	BFI_ENET_CQ_EF_UDP		(1 <<  8)
-#define	BFI_ENET_CQ_EF_TCP		(1 <<  9)
-#define	BFI_ENET_CQ_EF_IP_OPTIONS	(1 << 10)
-#define	BFI_ENET_CQ_EF_IPV6		(1 << 11)
+#define BFI_ENET_CQ_EF_UDP		BIT(8)
+#define BFI_ENET_CQ_EF_TCP		BIT(9)
+#define BFI_ENET_CQ_EF_IP_OPTIONS	BIT(10)
+#define BFI_ENET_CQ_EF_IPV6		BIT(11)
 
-#define	BFI_ENET_CQ_EF_IPV4		(1 << 12)
-#define	BFI_ENET_CQ_EF_VLAN		(1 << 13)
-#define	BFI_ENET_CQ_EF_RSS		(1 << 14)
-#define	BFI_ENET_CQ_EF_RSVD2		(1 << 15)
+#define BFI_ENET_CQ_EF_IPV4		BIT(12)
+#define BFI_ENET_CQ_EF_VLAN		BIT(13)
+#define BFI_ENET_CQ_EF_RSS		BIT(14)
+#define BFI_ENET_CQ_EF_RSVD2		BIT(15)
 
-#define	BFI_ENET_CQ_EF_MCAST_MATCH	(1 << 16)
-#define	BFI_ENET_CQ_EF_MCAST		(1 << 17)
-#define BFI_ENET_CQ_EF_BCAST		(1 << 18)
-#define	BFI_ENET_CQ_EF_REMOTE		(1 << 19)
+#define BFI_ENET_CQ_EF_MCAST_MATCH	BIT(16)
+#define BFI_ENET_CQ_EF_MCAST		BIT(17)
+#define BFI_ENET_CQ_EF_BCAST		BIT(18)
+#define BFI_ENET_CQ_EF_REMOTE		BIT(19)
 
-#define	BFI_ENET_CQ_EF_LOCAL		(1 << 20)
+#define BFI_ENET_CQ_EF_LOCAL		BIT(20)
 
 /* CQ Entry Structure */
 struct bfi_enet_cq_entry {
@@ -672,11 +672,11 @@ struct bfi_enet_stats_req {
 } __packed;
 
 /* defines for "stats_mask" above. */
-#define BFI_ENET_STATS_MAC    (1 << 0)    /* !< MAC Statistics */
-#define BFI_ENET_STATS_BPC    (1 << 1)    /* !< Pause Stats from BPC */
-#define BFI_ENET_STATS_RAD    (1 << 2)    /* !< Rx Admission Statistics */
-#define BFI_ENET_STATS_RX_FC  (1 << 3)    /* !< Rx FC Stats from RxA */
-#define BFI_ENET_STATS_TX_FC  (1 << 4)    /* !< Tx FC Stats from TxA */
+#define BFI_ENET_STATS_MAC    BIT(0)    /* !< MAC Statistics */
+#define BFI_ENET_STATS_BPC    BIT(1)    /* !< Pause Stats from BPC */
+#define BFI_ENET_STATS_RAD    BIT(2)    /* !< Rx Admission Statistics */
+#define BFI_ENET_STATS_RX_FC  BIT(3)    /* !< Rx FC Stats from RxA */
+#define BFI_ENET_STATS_TX_FC  BIT(4)    /* !< Tx FC Stats from TxA */
 
 #define BFI_ENET_STATS_ALL    0x1f
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 5a1e6b5..54902ce 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -207,7 +207,7 @@ bna_bfi_stats_get_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr)
 	for (i = 0; i < BFI_ENET_CFG_MAX; i++) {
 		stats_dst = (u64 *)&(bna->stats.hw_stats.rxf_stats[i]);
 		memset(stats_dst, 0, sizeof(struct bfi_enet_stats_rxf));
-		if (rx_enet_mask & ((u32)(1 << i))) {
+		if (rx_enet_mask & ((u32)BIT(i))) {
 			int k;
 			count = sizeof(struct bfi_enet_stats_rxf) /
 				sizeof(u64);
@@ -222,7 +222,7 @@ bna_bfi_stats_get_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr)
 	for (i = 0; i < BFI_ENET_CFG_MAX; i++) {
 		stats_dst = (u64 *)&(bna->stats.hw_stats.txf_stats[i]);
 		memset(stats_dst, 0, sizeof(struct bfi_enet_stats_txf));
-		if (tx_enet_mask & ((u32)(1 << i))) {
+		if (tx_enet_mask & ((u32)BIT(i))) {
 			int k;
 			count = sizeof(struct bfi_enet_stats_txf) /
 				sizeof(u64);
diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index 174af0e..52b45c9 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -213,7 +213,7 @@ do {									\
  * 15 bits (32K) should  be large enough to accumulate, anyways, and the max.
  * acked events to h/w can be (32K + max poll weight) (currently 64).
  */
-#define	BNA_IB_MAX_ACK_EVENTS		(1 << 15)
+#define BNA_IB_MAX_ACK_EVENTS		BIT(15)
 
 /* These macros build the data portion of the TxQ/RxQ doorbell */
 #define BNA_DOORBELL_Q_PRD_IDX(_pi)	(0x80000000 | (_pi))
@@ -282,13 +282,13 @@ do {									\
 #define BNA_TXQ_WI_EXTENSION		(0x104)	/* Extension WI */
 
 /* TxQ Entry Control Flags */
-#define BNA_TXQ_WI_CF_FCOE_CRC		(1 << 8)
-#define BNA_TXQ_WI_CF_IPID_MODE		(1 << 5)
-#define BNA_TXQ_WI_CF_INS_PRIO		(1 << 4)
-#define BNA_TXQ_WI_CF_INS_VLAN		(1 << 3)
-#define BNA_TXQ_WI_CF_UDP_CKSUM		(1 << 2)
-#define BNA_TXQ_WI_CF_TCP_CKSUM		(1 << 1)
-#define BNA_TXQ_WI_CF_IP_CKSUM		(1 << 0)
+#define BNA_TXQ_WI_CF_FCOE_CRC		BIT(8)
+#define BNA_TXQ_WI_CF_IPID_MODE		BIT(5)
+#define BNA_TXQ_WI_CF_INS_PRIO		BIT(4)
+#define BNA_TXQ_WI_CF_INS_VLAN		BIT(3)
+#define BNA_TXQ_WI_CF_UDP_CKSUM		BIT(2)
+#define BNA_TXQ_WI_CF_TCP_CKSUM		BIT(1)
+#define BNA_TXQ_WI_CF_IP_CKSUM		BIT(0)
 
 #define BNA_TXQ_WI_L4_HDR_N_OFFSET(_hdr_size, _offset) \
 		(((_hdr_size) << 10) | ((_offset) & 0x3FF))
@@ -297,36 +297,36 @@ do {									\
  * Completion Q defines
  */
 /* CQ Entry Flags */
-#define	BNA_CQ_EF_MAC_ERROR	(1 <<  0)
-#define	BNA_CQ_EF_FCS_ERROR	(1 <<  1)
-#define	BNA_CQ_EF_TOO_LONG	(1 <<  2)
-#define	BNA_CQ_EF_FC_CRC_OK	(1 <<  3)
-
-#define	BNA_CQ_EF_RSVD1		(1 <<  4)
-#define	BNA_CQ_EF_L4_CKSUM_OK	(1 <<  5)
-#define	BNA_CQ_EF_L3_CKSUM_OK	(1 <<  6)
-#define	BNA_CQ_EF_HDS_HEADER	(1 <<  7)
-
-#define	BNA_CQ_EF_UDP		(1 <<  8)
-#define	BNA_CQ_EF_TCP		(1 <<  9)
-#define	BNA_CQ_EF_IP_OPTIONS	(1 << 10)
-#define	BNA_CQ_EF_IPV6		(1 << 11)
-
-#define	BNA_CQ_EF_IPV4		(1 << 12)
-#define	BNA_CQ_EF_VLAN		(1 << 13)
-#define	BNA_CQ_EF_RSS		(1 << 14)
-#define	BNA_CQ_EF_RSVD2		(1 << 15)
-
-#define	BNA_CQ_EF_MCAST_MATCH   (1 << 16)
-#define	BNA_CQ_EF_MCAST		(1 << 17)
-#define BNA_CQ_EF_BCAST		(1 << 18)
-#define	BNA_CQ_EF_REMOTE	(1 << 19)
-
-#define	BNA_CQ_EF_LOCAL		(1 << 20)
+#define BNA_CQ_EF_MAC_ERROR	BIT(0)
+#define BNA_CQ_EF_FCS_ERROR	BIT(1)
+#define BNA_CQ_EF_TOO_LONG	BIT(2)
+#define BNA_CQ_EF_FC_CRC_OK	BIT(3)
+
+#define BNA_CQ_EF_RSVD1		BIT(4)
+#define BNA_CQ_EF_L4_CKSUM_OK	BIT(5)
+#define BNA_CQ_EF_L3_CKSUM_OK	BIT(6)
+#define BNA_CQ_EF_HDS_HEADER	BIT(7)
+
+#define BNA_CQ_EF_UDP		BIT(8)
+#define BNA_CQ_EF_TCP		BIT(9)
+#define BNA_CQ_EF_IP_OPTIONS	BIT(10)
+#define BNA_CQ_EF_IPV6		BIT(11)
+
+#define BNA_CQ_EF_IPV4		BIT(12)
+#define BNA_CQ_EF_VLAN		BIT(13)
+#define BNA_CQ_EF_RSS		BIT(14)
+#define BNA_CQ_EF_RSVD2		BIT(15)
+
+#define BNA_CQ_EF_MCAST_MATCH   BIT(16)
+#define BNA_CQ_EF_MCAST		BIT(17)
+#define BNA_CQ_EF_BCAST		BIT(18)
+#define BNA_CQ_EF_REMOTE	BIT(19)
+
+#define BNA_CQ_EF_LOCAL		BIT(20)
 /* CAT2 ASIC does not use bit 21 as per the SPEC.
  * Bit 31 is set in every end of frame completion
  */
-#define BNA_CQ_EF_EOP		(1 << 31)
+#define BNA_CQ_EF_EOP		BIT(31)
 
 /* Data structures */
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index e13f8c9..2c85f72 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -566,7 +566,7 @@ bna_rxf_vlan_cfg_apply(struct bna_rxf *rxf)
 			block_idx++;
 			vlan_pending_bitmask >>= 1;
 		}
-		rxf->vlan_pending_bitmask &= ~(1 << block_idx);
+		rxf->vlan_pending_bitmask &= ~BIT(block_idx);
 		bna_bfi_rx_vlan_filter_set(rxf, block_idx);
 		return 1;
 	}
@@ -1105,12 +1105,12 @@ bna_rx_vlan_add(struct bna_rx *rx, int vlan_id)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	int index = (vlan_id >> BFI_VLAN_WORD_SHIFT);
-	int bit = (1 << (vlan_id & BFI_VLAN_WORD_MASK));
+	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));
 	int group_id = (vlan_id >> BFI_VLAN_BLOCK_SHIFT);
 
 	rxf->vlan_filter_table[index] |= bit;
 	if (rxf->vlan_filter_status == BNA_STATUS_T_ENABLED) {
-		rxf->vlan_pending_bitmask |= (1 << group_id);
+		rxf->vlan_pending_bitmask |= BIT(group_id);
 		bfa_fsm_send_event(rxf, RXF_E_CONFIG);
 	}
 }
@@ -1120,12 +1120,12 @@ bna_rx_vlan_del(struct bna_rx *rx, int vlan_id)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	int index = (vlan_id >> BFI_VLAN_WORD_SHIFT);
-	int bit = (1 << (vlan_id & BFI_VLAN_WORD_MASK));
+	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));
 	int group_id = (vlan_id >> BFI_VLAN_BLOCK_SHIFT);
 
 	rxf->vlan_filter_table[index] &= ~bit;
 	if (rxf->vlan_filter_status == BNA_STATUS_T_ENABLED) {
-		rxf->vlan_pending_bitmask |= (1 << group_id);
+		rxf->vlan_pending_bitmask |= BIT(group_id);
 		bfa_fsm_send_event(rxf, RXF_E_CONFIG);
 	}
 }
@@ -2619,7 +2619,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 		if (intr_info->intr_type == BNA_INTR_T_MSIX)
 			rxp->cq.ib.intr_vector = rxp->vector;
 		else
-			rxp->cq.ib.intr_vector = (1 << rxp->vector);
+			rxp->cq.ib.intr_vector = BIT(rxp->vector);
 		rxp->cq.ib.coalescing_timeo = rx_cfg->coalescing_timeo;
 		rxp->cq.ib.interpkt_count = BFI_RX_INTERPKT_COUNT;
 		rxp->cq.ib.interpkt_timeo = BFI_RX_INTERPKT_TIMEO;
@@ -2724,7 +2724,7 @@ bna_rx_create(struct bna *bna, struct bnad *bnad,
 
 	bfa_fsm_set_state(rx, bna_rx_sm_stopped);
 
-	rx_mod->rid_mask |= (1 << rx->rid);
+	rx_mod->rid_mask |= BIT(rx->rid);
 
 	return rx;
 }
@@ -2776,7 +2776,7 @@ bna_rx_destroy(struct bna_rx *rx)
 		}
 	}
 
-	rx_mod->rid_mask &= ~(1 << rx->rid);
+	rx_mod->rid_mask &= ~BIT(rx->rid);
 
 	rx->bna = NULL;
 	rx->priv = NULL;
@@ -3778,7 +3778,7 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 					intr_info->idl[0].vector :
 					intr_info->idl[i].vector;
 		if (intr_info->intr_type == BNA_INTR_T_INTX)
-			txq->ib.intr_vector = (1 <<  txq->ib.intr_vector);
+			txq->ib.intr_vector = BIT(txq->ib.intr_vector);
 		txq->ib.coalescing_timeo = tx_cfg->coalescing_timeo;
 		txq->ib.interpkt_timeo = BFI_TX_INTERPKT_TIMEO;
 		txq->ib.interpkt_count = BFI_TX_INTERPKT_COUNT;
@@ -3820,7 +3820,7 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 
 	bfa_fsm_set_state(tx, bna_tx_sm_stopped);
 
-	tx_mod->rid_mask |= (1 << tx->rid);
+	tx_mod->rid_mask |= BIT(tx->rid);
 
 	return tx;
 
@@ -3841,7 +3841,7 @@ bna_tx_destroy(struct bna_tx *tx)
 			(tx->tcb_destroy_cbfn)(tx->bna->bnad, txq->tcb);
 	}
 
-	tx->bna->tx_mod.rid_mask &= ~(1 << tx->rid);
+	tx->bna->tx_mod.rid_mask &= ~BIT(tx->rid);
 	bna_tx_free(tx);
 }
 
-- 
2.3.6
