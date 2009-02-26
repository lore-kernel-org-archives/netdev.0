From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] [net-next] qlge: Reduce debug print output.
Date: Thu, 26 Feb 2009 12:08:36 -0800
Message-ID: <1235678916-2856-5-git-send-email-ron.mercer@qlogic.com>
References: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10180 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbZBZULz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:11:55 -0500
In-Reply-To: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of some noise that is for debug only.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d1d8f05..b4c6fd7 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -58,8 +58,8 @@ static const u32 default_msg =
     NETIF_MSG_IFUP |
     NETIF_MSG_RX_ERR |
     NETIF_MSG_TX_ERR |
-    NETIF_MSG_TX_QUEUED |
-    NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS |
+/*  NETIF_MSG_TX_QUEUED | */
+/*  NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS | */
 /* NETIF_MSG_PKTDATA | */
     NETIF_MSG_HW | NETIF_MSG_WOL | 0;
 
@@ -327,7 +327,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			    (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
 			    (addr[5]);
 
-			QPRINTK(qdev, IFUP, INFO,
+			QPRINTK(qdev, IFUP, DEBUG,
 				"Adding %s address %pM"
 				" at index %d in the CAM.\n",
 				((type ==
@@ -2552,7 +2552,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		QPRINTK(qdev, IFUP, DEBUG, "Invalid rx_ring->type = %d.\n",
 			rx_ring->type);
 	}
-	QPRINTK(qdev, IFUP, INFO, "Initializing rx work queue.\n");
+	QPRINTK(qdev, IFUP, DEBUG, "Initializing rx work queue.\n");
 	err = ql_write_cfg(qdev, cqicb, sizeof(struct cqicb),
 			   CFG_LCQ, rx_ring->cq_id);
 	if (err) {
@@ -2605,7 +2605,7 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 		QPRINTK(qdev, IFUP, ERR, "Failed to load tx_ring.\n");
 		return err;
 	}
-	QPRINTK(qdev, IFUP, INFO, "Successfully loaded WQICB.\n");
+	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded WQICB.\n");
 	return err;
 }
 
@@ -2647,7 +2647,7 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 		    (qdev->pdev, qdev->msi_x_entry, qdev->rx_ring_count)) {
 			set_bit(QL_MSIX_ENABLED, &qdev->flags);
 			qdev->intr_count = qdev->rx_ring_count;
-			QPRINTK(qdev, IFUP, INFO,
+			QPRINTK(qdev, IFUP, DEBUG,
 				"MSI-X Enabled, got %d vectors.\n",
 				qdev->intr_count);
 			return;
@@ -2774,11 +2774,11 @@ static void ql_free_irq(struct ql_adapter *qdev)
 			if (test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
 				free_irq(qdev->msi_x_entry[i].vector,
 					 &qdev->rx_ring[i]);
-				QPRINTK(qdev, IFDOWN, ERR,
+				QPRINTK(qdev, IFDOWN, DEBUG,
 					"freeing msix interrupt %d.\n", i);
 			} else {
 				free_irq(qdev->pdev->irq, &qdev->rx_ring[0]);
-				QPRINTK(qdev, IFDOWN, ERR,
+				QPRINTK(qdev, IFDOWN, DEBUG,
 					"freeing msi interrupt %d.\n", i);
 			}
 		}
@@ -2809,7 +2809,7 @@ static int ql_request_irq(struct ql_adapter *qdev)
 					i);
 				goto err_irq;
 			} else {
-				QPRINTK(qdev, IFUP, INFO,
+				QPRINTK(qdev, IFUP, DEBUG,
 					"Hooked intr %d, queue type %s%s%s, with name %s.\n",
 					i,
 					qdev->rx_ring[i].type ==
@@ -2884,14 +2884,14 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	get_random_bytes((void *)&ricb->ipv6_hash_key[0], 40);
 	get_random_bytes((void *)&ricb->ipv4_hash_key[0], 16);
 
-	QPRINTK(qdev, IFUP, INFO, "Initializing RSS.\n");
+	QPRINTK(qdev, IFUP, DEBUG, "Initializing RSS.\n");
 
 	status = ql_write_cfg(qdev, ricb, sizeof(ricb), CFG_LR, 0);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to load RICB.\n");
 		return status;
 	}
-	QPRINTK(qdev, IFUP, INFO, "Successfully loaded RICB.\n");
+	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded RICB.\n");
 	return status;
 }
 
@@ -3053,7 +3053,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 
 	/* Start NAPI for the RSS queues. */
 	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++) {
-		QPRINTK(qdev, IFUP, INFO, "Enabling NAPI for rx_ring[%d].\n",
+		QPRINTK(qdev, IFUP, DEBUG, "Enabling NAPI for rx_ring[%d].\n",
 			i);
 		napi_enable(&qdev->rx_ring[i].napi);
 	}
-- 
1.6.0.2

