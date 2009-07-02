From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 8/8] qlge: Fix sizeof usage.
Date: Thu,  2 Jul 2009 09:06:13 -0700
Message-ID: <1246550773-18417-8-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbZGBQLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:35 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some usage was only sizing a pointer rather than the data type.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_ethtool.c |    4 ++--
 drivers/net/qlge/qlge_main.c    |   14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 37c99fe..eb6a9ee 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -59,7 +59,7 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 			cqicb->pkt_delay =
 			    cpu_to_le16(qdev->tx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
-			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
+			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
 				QPRINTK(qdev, IFUP, ERR,
@@ -82,7 +82,7 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 			cqicb->pkt_delay =
 			    cpu_to_le16(qdev->rx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
-			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
+			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
 				QPRINTK(qdev, IFUP, ERR,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 35ba95a..5768af1 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2156,7 +2156,7 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	}
 	tx_ring_desc = &tx_ring->q[tx_ring->prod_idx];
 	mac_iocb_ptr = tx_ring_desc->queue_entry;
-	memset((void *)mac_iocb_ptr, 0, sizeof(mac_iocb_ptr));
+	memset((void *)mac_iocb_ptr, 0, sizeof(*mac_iocb_ptr));
 
 	mac_iocb_ptr->opcode = OPCODE_OB_MAC_IOCB;
 	mac_iocb_ptr->tid = tx_ring_desc->index;
@@ -2795,7 +2795,7 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 
 	ql_init_tx_ring(qdev, tx_ring);
 
-	err = ql_write_cfg(qdev, wqicb, sizeof(wqicb), CFG_LRQ,
+	err = ql_write_cfg(qdev, wqicb, sizeof(*wqicb), CFG_LRQ,
 			   (u16) tx_ring->wq_id);
 	if (err) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to load tx_ring.\n");
@@ -3060,7 +3060,7 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	int i;
 	u8 *hash_id = (u8 *) ricb->hash_cq_id;
 
-	memset((void *)ricb, 0, sizeof(ricb));
+	memset((void *)ricb, 0, sizeof(*ricb));
 
 	ricb->base_cq = qdev->rss_ring_first_cq_id | RSS_L4K;
 	ricb->flags =
@@ -3082,7 +3082,7 @@ static int ql_start_rss(struct ql_adapter *qdev)
 
 	QPRINTK(qdev, IFUP, DEBUG, "Initializing RSS.\n");
 
-	status = ql_write_cfg(qdev, ricb, sizeof(ricb), CFG_LR, 0);
+	status = ql_write_cfg(qdev, ricb, sizeof(*ricb), CFG_LR, 0);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to load RICB.\n");
 		return status;
@@ -3489,7 +3489,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
-		memset((void *)tx_ring, 0, sizeof(tx_ring));
+		memset((void *)tx_ring, 0, sizeof(*tx_ring));
 		tx_ring->qdev = qdev;
 		tx_ring->wq_id = i;
 		tx_ring->wq_len = qdev->tx_ring_size;
@@ -3505,7 +3505,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
 		rx_ring = &qdev->rx_ring[i];
-		memset((void *)rx_ring, 0, sizeof(rx_ring));
+		memset((void *)rx_ring, 0, sizeof(*rx_ring));
 		rx_ring->qdev = qdev;
 		rx_ring->cq_id = i;
 		rx_ring->cpu = i % cpu_cnt;	/* CPU to run handler on. */
@@ -3864,7 +3864,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	int pos, err = 0;
 	u16 val16;
 
-	memset((void *)qdev, 0, sizeof(qdev));
+	memset((void *)qdev, 0, sizeof(*qdev));
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "PCI device enable failed.\n");
-- 
1.6.0.2

