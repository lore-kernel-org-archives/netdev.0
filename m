From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 3/7] ixgbe: use netdev_irqname
Date: Tue, 21 Jun 2011 10:05:44 -0700
Message-ID: <20110621170658.597977868@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49486 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756823Ab1FURHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:22 -0400
Content-Disposition: inline; filename=ixgbe-use-irq-name.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New standard function for generating irq names.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ixgbe/ixgbe_main.c	2011-06-21 09:30:35.327952251 -0700
+++ b/drivers/net/ixgbe/ixgbe_main.c	2011-06-21 09:32:33.483952184 -0700
@@ -2352,20 +2352,19 @@ static int ixgbe_request_msix_irqs(struc
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
 		handler = SET_HANDLER(q_vector);
 
-		if (handler == &ixgbe_msix_clean_rx) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "rx", ri++);
-		} else if (handler == &ixgbe_msix_clean_tx) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "tx", ti++);
-		} else if (handler == &ixgbe_msix_clean_many) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "TxRx", ri++);
+		if (handler == &ixgbe_msix_clean_rx)
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev, NETIF_IRQ_RX, ri++);
+		else if (handler == &ixgbe_msix_clean_tx)
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev, NETIF_IRQ_TX, ti++);
+		else if (handler == &ixgbe_msix_clean_many) {
+			netdev_irqname(q_vector->name, sizeof(q_vector->name),
+				       netdev, NETIF_IRQ_TXRX, ri++);
 			ti++;
-		} else {
-			/* skip this unused q_vector */
+		} else /* skip this unused q_vector */
 			continue;
-		}
+
 		err = request_irq(adapter->msix_entries[vector].vector,
 				  handler, 0, q_vector->name,
 				  q_vector);


