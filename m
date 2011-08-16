From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 07/14] bna: Formatting and Code Cleanup
Date: Tue, 16 Aug 2011 14:19:44 -0700
Message-ID: <1313529591-3718-8-git-send-email-rmody@brocade.com>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:47908 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752823Ab1HPVUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:20:35 -0400
In-Reply-To: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Print log messages when running with reduced number of MSI-X vectors
   and when defaulting to INTx mode.
 - Remove BUG_ONs and header file inclusion that are not needed
 - Comments addition/cleanup
 - Unused code cleanup
 - Add New Line to Print msg in bfa_sm_fault
 - Formatting fix

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_cee.c         |    2 -
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |    1 -
 drivers/net/ethernet/brocade/bna/bfi.h             |   46 --------------------
 drivers/net/ethernet/brocade/bna/bna.h             |   18 +++-----
 drivers/net/ethernet/brocade/bna/bna_types.h       |    1 -
 drivers/net/ethernet/brocade/bna/bnad.c            |   46 ++++++--------------
 drivers/net/ethernet/brocade/bna/bnad.h            |   13 +++---
 drivers/net/ethernet/brocade/bna/cna.h             |   11 ++---
 8 files changed, 31 insertions(+), 107 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index b45b8eb..8e62718 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -16,8 +16,6 @@
  * www.brocade.com
  */
 
-#include "bfa_defs_cna.h"
-#include "cna.h"
 #include "bfa_cee.h"
 #include "bfi_cna.h"
 #include "bfa_ioc.h"
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 7ddd16f..7e5df90 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -18,7 +18,6 @@
 #ifndef __BFA_DEFS_MFG_COMM_H__
 #define __BFA_DEFS_MFG_COMM_H__
 
-#include "cna.h"
 #include "bfa_defs.h"
 
 /**
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 19654cc..4e04c14 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -73,20 +73,6 @@ struct bfi_mhdr {
  ****************************************************************************
  */
 
-#define BFI_SGE_INLINE	1
-#define BFI_SGE_INLINE_MAX	(BFI_SGE_INLINE + 1)
-
-/**
- * SG Flags
- */
-enum {
-	BFI_SGE_DATA		= 0,	/*!< data address, not last	     */
-	BFI_SGE_DATA_CPL	= 1,	/*!< data addr, last in current page */
-	BFI_SGE_DATA_LAST	= 3,	/*!< data address, last		     */
-	BFI_SGE_LINK		= 2,	/*!< link address		     */
-	BFI_SGE_PGDLEN		= 2,	/*!< cumulative data length for page */
-};
-
 /**
  * DMA addresses
  */
@@ -97,33 +83,6 @@ union bfi_addr_u {
 	} a32;
 };
 
-/**
- * Scatter Gather Element
- */
-struct bfi_sge {
-#ifdef __BIGENDIAN
-	u32	flags:2,
-			rsvd:2,
-			sg_len:28;
-#else
-	u32	sg_len:28,
-			rsvd:2,
-			flags:2;
-#endif
-	union bfi_addr_u sga;
-};
-
-/**
- * Scatter Gather Page
- */
-#define BFI_SGPG_DATA_SGES		7
-#define BFI_SGPG_SGES_MAX		(BFI_SGPG_DATA_SGES + 1)
-#define BFI_SGPG_RSVD_WD_LEN	8
-struct bfi_sgpg {
-	struct bfi_sge sges[BFI_SGPG_SGES_MAX];
-	u32	rsvd[BFI_SGPG_RSVD_WD_LEN];
-};
-
 /*
  * Large Message structure - 128 Bytes size Msgs
  */
@@ -131,11 +90,6 @@ struct bfi_sgpg {
 #define BFI_LMSG_PL_WSZ	\
 			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr)) / 4)
 
-struct bfi_msg {
-	struct bfi_mhdr mhdr;
-	u32	pl[BFI_LMSG_PL_WSZ];
-};
-
 /**
  * Mailbox message structure
  */
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index e4f914c..c0e5ba8 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -10,12 +10,17 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
 #ifndef __BNA_H__
 #define __BNA_H__
 
-#include "bfa_cs.h"
+#include "bfa_defs.h"
 #include "bfa_ioc.h"
-#include "cna.h"
+#include "bfi_enet.h"
 #include "bna_types.h"
 
 extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
@@ -403,12 +408,8 @@ void bna_mod_init(struct bna *bna, struct bna_res_info *res_info);
 void bna_uninit(struct bna *bna);
 int bna_num_txq_set(struct bna *bna, int num_txq);
 int bna_num_rxp_set(struct bna *bna, int num_rxp);
-void bna_stats_get(struct bna *bna);
-void bna_get_perm_mac(struct bna *bna, u8 *mac);
 void bna_hw_stats_get(struct bna *bna);
 
-/* APIs for Rx */
-
 /* APIs for RxF */
 struct bna_mac *bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod);
 void bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod,
@@ -529,11 +530,6 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
-void bna_rx_hds_enable(struct bna_rx *rx, struct bna_hds_config *hds_config,
-		       void (*cbfn)(struct bnad *, struct bna_rx *));
-void bna_rx_hds_disable(struct bna_rx *rx,
-			void (*cbfn)(struct bnad *, struct bna_rx *));
-
 /**
  * ENET
  */
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index 8a6da0c..59417b1 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -21,7 +21,6 @@
 #include "cna.h"
 #include "bna_hw_defs.h"
 #include "bfa_cee.h"
-#include "bfi_enet.h"
 #include "bfa_msgq.h"
 
 /**
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 0faa8a1..869d172 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -402,10 +402,9 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 	BNA_RXQ_QPGE_PTR_GET(unmap_prod, rcb->sw_qpt, rxent, wi_range);
 
 	while (to_alloc--) {
-		if (!wi_range) {
+		if (!wi_range)
 			BNA_RXQ_QPGE_PTR_GET(unmap_prod, rcb->sw_qpt, rxent,
 					     wi_range);
-		}
 		skb = netdev_alloc_skb_ip_align(bnad->netdev,
 						rcb->rxq->buffer_size);
 		if (unlikely(!skb)) {
@@ -567,27 +566,6 @@ next:
 }
 
 static void
-bnad_disable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
-{
-	if (unlikely(!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-		return;
-
-	bna_ib_coalescing_timer_set(ccb->i_dbell, 0);
-	bna_ib_ack(ccb->i_dbell, 0);
-}
-
-static void
-bnad_enable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
-{
-	unsigned long flags;
-
-	/* Because of polling context */
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bnad_enable_rx_irq_unsafe(ccb);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-}
-
-static void
 bnad_netif_rx_schedule_poll(struct bnad *bnad, struct bna_ccb *ccb)
 {
 	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
@@ -1687,7 +1665,7 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 		return rcvd;
 
 poll_exit:
-	napi_complete((napi));
+	napi_complete(napi);
 
 	rx_ctrl->rx_complete++;
 
@@ -2098,15 +2076,13 @@ bnad_enable_default_bcast(struct bnad *bnad)
 	return 0;
 }
 
-/* Called with bnad_conf_lock() held */
+/* Called with mutex_lock(&bnad->conf_mutex) held */
 static void
 bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 {
 	u16 vid;
 	unsigned long flags;
 
-	BUG_ON(!(VLAN_N_VID == BFI_ENET_VLAN_ID_MAX));
-
 	for_each_set_bit(vid, bnad->active_vlans, VLAN_N_VID) {
 		spin_lock_irqsave(&bnad->bna_lock, flags);
 		bna_rx_vlan_add(bnad->rx_info[rx_id].rx, vid);
@@ -2215,9 +2191,6 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 {
 	int err;
 
-	/* SKB_GSO_TCPV4 and SKB_GSO_TCPV6 is defined since 2.6.18. */
-	BUG_ON(!(skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4 ||
-		   skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6));
 	if (skb_header_cloned(skb)) {
 		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 		if (err) {
@@ -2244,7 +2217,6 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 	} else {
 		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
-		BUG_ON(!(skb->protocol == htons(ETH_P_IPV6)));
 		ipv6h->payload_len = 0;
 		tcp_hdr(skb)->check =
 			~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, 0,
@@ -2402,6 +2374,8 @@ bnad_enable_msix(struct bnad *bnad)
 	ret = pci_enable_msix(bnad->pcidev, bnad->msix_table, bnad->msix_num);
 	if (ret > 0) {
 		/* Not enough MSI-X vectors. */
+		pr_warn("BNA: %d MSI-X vectors allocated < %d requested\n",
+			ret, bnad->msix_num);
 
 		spin_lock_irqsave(&bnad->bna_lock, flags);
 		/* ret = #of vectors that we got */
@@ -2430,6 +2404,7 @@ bnad_enable_msix(struct bnad *bnad)
 	return;
 
 intx_mode:
+	pr_warn("BNA: MSI-X enable failed - operating in INTx mode\n");
 
 	kfree(bnad->msix_table);
 	bnad->msix_table = NULL;
@@ -2585,7 +2560,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unmap_q = tcb->unmap_q;
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
-	 * and the netif_stop_all_queue() call.
+	 * and the netif_tx_stop_all_queues() call.
 	 */
 	BNAD_DROP_AND_RETURN_IF(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags),
 				tx_skb_stopping);
@@ -2633,7 +2608,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	txq_prod = tcb->producer_index;
 	BNA_TXQ_QPGE_PTR_GET(txq_prod, tcb->sw_qpt, txqent, wi_range);
-	BUG_ON(!(wi_range <= tcb->q_depth));
 	txqent->hdr.wi.reserved = 0;
 	txqent->hdr.wi.num_vectors = vectors;
 
@@ -3062,6 +3036,12 @@ bnad_netpoll(struct net_device *netdev)
 		bnad_isr(bnad->pcidev->irq, netdev);
 		bna_intx_enable(&bnad->bna, curr_mask);
 	} else {
+		/*
+		 * Tx processing may happen in sending context, so no need
+		 * to explicitly process completions here
+		 */
+
+		/* Rx processing */
 		for (i = 0; i < bnad->num_rx; i++) {
 			rx_info = &bnad->rx_info[i];
 			if (!rx_info->rx)
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index f402149..516fbdd 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -64,8 +64,6 @@ struct bnad_rx_ctrl {
 
 #define BNAD_RXMODE_PROMISC_DEFAULT	BNA_RXMODE_PROMISC
 
-#define BNAD_GET_TX_ID(_skb)	(0)
-
 /*
  * GLOBAL #defines (CONSTANTS)
  */
@@ -154,7 +152,6 @@ struct bnad_drv_stats {
 	u64		tcpcsum_offload;
 	u64		udpcsum_offload;
 	u64		csum_help;
-	u64		csum_help_err;
 	u64		tx_skb_too_short;
 	u64		tx_skb_stopping;
 	u64		tx_skb_max_vectors;
@@ -171,13 +168,10 @@ struct bnad_drv_stats {
 	u64		tx_skb_len_mismatch;
 
 	u64		hw_stats_updates;
-	u64		netif_rx_schedule;
-	u64		netif_rx_complete;
 	u64		netif_rx_dropped;
 
 	u64		link_toggle;
 	u64		cee_toggle;
-	u64		cee_up;
 
 	u64		rxp_info_alloc_failed;
 	u64		mbox_intr_disabled;
@@ -386,6 +380,13 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 #define bnad_dim_timer_running(_bnad)				\
 	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) &&		\
 	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
+
+/*
+ * Stops the DIM timer
+ * Called with bnad->bna_lock held
+ * Implemented as macro, since we want to use
+ * the correct flags(on stack) while unlocking.
+ */
 #define bnad_dim_timer_stop(_bnad, _flags)		\
 do {							\
 	int to_del = 0;					\
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 50fce15..cb48742 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -21,21 +21,18 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/mutex.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/bitops.h>
 #include <linux/timer.h>
 #include <linux/interrupt.h>
+#include <linux/if_vlan.h>
 #include <linux/if_ether.h>
-#include <asm/page.h>
-#include <asm/io.h>
-#include <asm/string.h>
-
-#include <linux/list.h>
 
 #define bfa_sm_fault(__event)    do {                            \
-	pr_err("SM Assertion failure: %s: %d: event = %d", __FILE__, __LINE__, \
-		__event); \
+	pr_err("SM Assertion failure: %s: %d: event = %d\n",	\
+		 __FILE__, __LINE__, __event);			\
 } while (0)
 
 extern char bfa_version[];
-- 
1.7.1

