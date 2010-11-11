From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 01/10] cxgb4vf: minor comment/symbolic name cleanup.
Date: Wed, 10 Nov 2010 18:04:03 -0800
Message-ID: <1289441052-4925-1-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19754 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211Ab0KKCET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:19 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor cleanup of comments and symbolic constant names for clarity.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/adapter.h      |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c |    9 ++++-----
 drivers/net/cxgb4vf/sge.c          |    9 ++++++---
 drivers/net/cxgb4vf/t4vf_hw.c      |    4 ++--
 4 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb4vf/adapter.h b/drivers/net/cxgb4vf/adapter.h
index 8ea0196..4766b41 100644
--- a/drivers/net/cxgb4vf/adapter.h
+++ b/drivers/net/cxgb4vf/adapter.h
@@ -60,7 +60,7 @@ enum {
 	 * MSI-X interrupt index usage.
 	 */
 	MSIX_FW		= 0,		/* MSI-X index for firmware Q */
-	MSIX_NIQFLINT	= 1,		/* MSI-X index base for Ingress Qs */
+	MSIX_IQFLINT	= 1,		/* MSI-X index base for Ingress Qs */
 	MSIX_EXTRAS	= 1,
 	MSIX_ENTRIES	= MAX_ETH_QSETS + MSIX_EXTRAS,
 
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 6de5e2e..f5259a1 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -280,7 +280,7 @@ static void name_msix_vecs(struct adapter *adapter)
 		const struct port_info *pi = netdev_priv(dev);
 		int qs, msi;
 
-		for (qs = 0, msi = MSIX_NIQFLINT;
+		for (qs = 0, msi = MSIX_IQFLINT;
 		     qs < pi->nqsets;
 		     qs++, msi++) {
 			snprintf(adapter->msix_info[msi].desc, namelen,
@@ -309,7 +309,7 @@ static int request_msix_queue_irqs(struct adapter *adapter)
 	/*
 	 * Ethernet queues.
 	 */
-	msi = MSIX_NIQFLINT;
+	msi = MSIX_IQFLINT;
 	for_each_ethrxq(s, rxq) {
 		err = request_irq(adapter->msix_info[msi].vec,
 				  t4vf_sge_intr_msix, 0,
@@ -337,7 +337,7 @@ static void free_msix_queue_irqs(struct adapter *adapter)
 	int rxq, msi;
 
 	free_irq(adapter->msix_info[MSIX_FW].vec, &s->fw_evtq);
-	msi = MSIX_NIQFLINT;
+	msi = MSIX_IQFLINT;
 	for_each_ethrxq(s, rxq)
 		free_irq(adapter->msix_info[msi++].vec,
 			 &s->ethrxq[rxq].rspq);
@@ -527,7 +527,7 @@ static int setup_sge_queues(struct adapter *adapter)
 	 * brought up at which point lots of things get nailed down
 	 * permanently ...
 	 */
-	msix = MSIX_NIQFLINT;
+	msix = MSIX_IQFLINT;
 	for_each_port(adapter, pidx) {
 		struct net_device *dev = adapter->port[pidx];
 		struct port_info *pi = netdev_priv(dev);
@@ -2465,7 +2465,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		version_printed = 1;
 	}
 
-
 	/*
 	 * Initialize generic PCI device state.
 	 */
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f10864d..d791adb 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1536,6 +1536,9 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	} else
 		skb_checksum_none_assert(skb);
 
+	/*
+	 * Deliver the packet to the stack.
+	 */
 	if (unlikely(pkt->vlan_ex)) {
 		struct vlan_group *grp = pi->vlan_grp;
 
@@ -2115,7 +2118,7 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 
 		/*
 		 * Calculate the size of the hardware free list ring plus
-		 * status page (which the SGE will place at the end of the
+		 * Status Page (which the SGE will place after the end of the
 		 * free list ring) in Egress Queue Units.
 		 */
 		flsz = (fl->size / FL_PER_EQ_UNIT +
@@ -2212,8 +2215,8 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	struct port_info *pi = netdev_priv(dev);
 
 	/*
-	 * Calculate the size of the hardware TX Queue (including the
-	 * status age on the end) in units of TX Descriptors.
+	 * Calculate the size of the hardware TX Queue (including the Status
+	 * Page on the end of the TX Queue) in units of TX Descriptors.
 	 */
 	nentries = txq->q.size + STAT_LEN / sizeof(struct tx_desc);
 
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index ea1c123..2180181 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -1257,7 +1257,7 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
  */
 int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 {
-	struct fw_cmd_hdr *cmd_hdr = (struct fw_cmd_hdr *)rpl;
+	const struct fw_cmd_hdr *cmd_hdr = (const struct fw_cmd_hdr *)rpl;
 	u8 opcode = FW_CMD_OP_GET(be32_to_cpu(cmd_hdr->hi));
 
 	switch (opcode) {
@@ -1265,7 +1265,7 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		/*
 		 * Link/module state change message.
 		 */
-		const struct fw_port_cmd *port_cmd = (void *)rpl;
+		const struct fw_port_cmd *port_cmd = (const void *)rpl;
 		u32 word;
 		int action, port_id, link_ok, speed, fc, pidx;
 
-- 
1.7.0.4

