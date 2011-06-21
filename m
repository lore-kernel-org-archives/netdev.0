From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 2/7] igb: use netdev_irqname
Date: Tue, 21 Jun 2011 10:05:43 -0700
Message-ID: <20110621170658.485641406@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49489 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756963Ab1FURHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:23 -0400
Content-Disposition: inline; filename=igb-use-irq-name.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an example of usage of netdev_irqname to create standard
IRQ names.  There is a change of behavior, the driver will now skip
unused IRQ vectors (similar to ixgbe).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/igb/igb_main.c	2011-06-21 09:12:49.567952849 -0700
+++ b/drivers/net/igb/igb_main.c	2011-06-21 09:29:48.211952277 -0700
@@ -920,16 +920,20 @@ static int igb_request_msix(struct igb_a
 		q_vector->itr_register = hw->hw_addr + E1000_EITR(vector);
 
 		if (q_vector->rx_ring && q_vector->tx_ring)
-			sprintf(q_vector->name, "%s-TxRx-%u", netdev->name,
-			        q_vector->rx_ring->queue_index);
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev,  NETIF_IRQ_TXRX,
+				       q_vector->rx_ring->queue_index);
 		else if (q_vector->tx_ring)
-			sprintf(q_vector->name, "%s-tx-%u", netdev->name,
-			        q_vector->tx_ring->queue_index);
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev,  NETIF_IRQ_TX,
+				       q_vector->tx_ring->queue_index);
 		else if (q_vector->rx_ring)
-			sprintf(q_vector->name, "%s-rx-%u", netdev->name,
-			        q_vector->rx_ring->queue_index);
-		else
-			sprintf(q_vector->name, "%s-unused", netdev->name);
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev,  NETIF_IRQ_RX,
+				       q_vector->rx_ring->queue_index);
+		else 	/* skip this unused q_vector */
+			continue;
+
 
 		err = request_irq(adapter->msix_entries[vector].vector,
 		                  igb_msix_ring, 0, q_vector->name,


