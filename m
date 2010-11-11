From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next-26 1/5] cxgb4vf: minor comment/symbolic name cleanup.
Date: Thu, 11 Nov 2010 11:30:40 -0800
Message-ID: <1289503844-18059-2-git-send-email-leedom@chelsio.com>
References: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22113 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716Ab0KKTau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:30:50 -0500
In-Reply-To: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor cleanup of comments and symbolic constant names for clarity.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/adapter.h      |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c |   11 ++++-------
 drivers/net/cxgb4vf/sge.c          |    9 ++++++---
 drivers/net/cxgb4vf/t4vf_hw.c      |    5 +++--
 4 files changed, 14 insertions(+), 13 deletions(-)

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
index c3449bb..6235719 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -280,9 +280,7 @@ static void name_msix_vecs(struct adapter *adapter)
 		const struct port_info *pi = netdev_priv(dev);
 		int qs, msi;
 
-		for (qs = 0, msi = MSIX_NIQFLINT;
-		     qs < pi->nqsets;
-		     qs++, msi++) {
+		for (qs = 0, msi = MSIX_IQFLINT; qs < pi->nqsets; qs++, msi++) {
 			snprintf(adapter->msix_info[msi].desc, namelen,
 				 "%s-%d", dev->name, qs);
 			adapter->msix_info[msi].desc[namelen] = 0;
@@ -309,7 +307,7 @@ static int request_msix_queue_irqs(struct adapter *adapter)
 	/*
 	 * Ethernet queues.
 	 */
-	msi = MSIX_NIQFLINT;
+	msi = MSIX_IQFLINT;
 	for_each_ethrxq(s, rxq) {
 		err = request_irq(adapter->msix_info[msi].vec,
 				  t4vf_sge_intr_msix, 0,
@@ -337,7 +335,7 @@ static void free_msix_queue_irqs(struct adapter *adapter)
 	int rxq, msi;
 
 	free_irq(adapter->msix_info[MSIX_FW].vec, &s->fw_evtq);
-	msi = MSIX_NIQFLINT;
+	msi = MSIX_IQFLINT;
 	for_each_ethrxq(s, rxq)
 		free_irq(adapter->msix_info[msi++].vec,
 			 &s->ethrxq[rxq].rspq);
@@ -527,7 +525,7 @@ static int setup_sge_queues(struct adapter *adapter)
 	 * brought up at which point lots of things get nailed down
 	 * permanently ...
 	 */
-	msix = MSIX_NIQFLINT;
+	msix = MSIX_IQFLINT;
 	for_each_port(adapter, pidx) {
 		struct net_device *dev = adapter->port[pidx];
 		struct port_info *pi = netdev_priv(dev);
@@ -2470,7 +2468,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		version_printed = 1;
 	}
 
-
 	/*
 	 * Initialize generic PCI device state.
 	 */
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index ecf0770..e0b3d1b 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1568,6 +1568,9 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	} else
 		skb_checksum_none_assert(skb);
 
+	/*
+	 * Deliver the packet to the stack.
+	 */
 	if (unlikely(pkt->vlan_ex)) {
 		struct vlan_group *grp = pi->vlan_grp;
 
@@ -2143,7 +2146,7 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 
 		/*
 		 * Calculate the size of the hardware free list ring plus
-		 * status page (which the SGE will place at the end of the
+		 * Status Page (which the SGE will place after the end of the
 		 * free list ring) in Egress Queue Units.
 		 */
 		flsz = (fl->size / FL_PER_EQ_UNIT +
@@ -2240,8 +2243,8 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	struct port_info *pi = netdev_priv(dev);
 
 	/*
-	 * Calculate the size of the hardware TX Queue (including the
-	 * status age on the end) in units of TX Descriptors.
+	 * Calculate the size of the hardware TX Queue (including the Status
+	 * Page on the end of the TX Queue) in units of TX Descriptors.
 	 */
 	nentries = txq->q.size + STAT_LEN / sizeof(struct tx_desc);
 
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index e306c20..f7d7f97 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -1276,7 +1276,7 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
  */
 int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 {
-	struct fw_cmd_hdr *cmd_hdr = (struct fw_cmd_hdr *)rpl;
+	const struct fw_cmd_hdr *cmd_hdr = (const struct fw_cmd_hdr *)rpl;
 	u8 opcode = FW_CMD_OP_GET(be32_to_cpu(cmd_hdr->hi));
 
 	switch (opcode) {
@@ -1284,7 +1284,8 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		/*
 		 * Link/module state change message.
 		 */
-		const struct fw_port_cmd *port_cmd = (void *)rpl;
+		const struct fw_port_cmd *port_cmd =
+			(const struct fw_port_cmd *)rpl;
 		u32 word;
 		int action, port_id, link_ok, speed, fc, pidx;
 
-- 
1.7.0.4

