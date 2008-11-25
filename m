From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] Naming interrupt vectors/ixgbe
Date: Tue, 25 Nov 2008 16:49:07 +0100
Message-ID: <18732.7795.484291.202338@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:55659 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbYKYPtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 10:49:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Same syntax for ixgbe driver.

Cheers
				--ro

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7548fb7..88717e6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1187,6 +1187,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	irqreturn_t (*handler)(int, void *);
 	int i, vector, q_vectors, err;
+	int ri=0, ti=0;
 
 	/* Decrement for Other and TCP Timer vectors */
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
@@ -1201,10 +1202,19 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
                          &ixgbe_msix_clean_many)
 	for (vector = 0; vector < q_vectors; vector++) {
 		handler = SET_HANDLER(&adapter->q_vector[vector]);
-		sprintf(adapter->name[vector], "%s:v%d-%s",
-		        netdev->name, vector,
-		        (handler == &ixgbe_msix_clean_rx) ? "Rx" :
-		         ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
+
+		if(handler == &ixgbe_msix_clean_rx) {
+			sprintf(adapter->name[vector], "%s-%s-%d",
+				netdev->name, "rx", ri++);
+		}
+		else if(handler == &ixgbe_msix_clean_tx) {
+			sprintf(adapter->name[vector], "%s-%s-%d",
+				netdev->name, "tx", ti++);
+		}
+		else 
+			sprintf(adapter->name[vector], "%s-%s-%d",
+				netdev->name, "TxRx", vector);	
+
 		err = request_irq(adapter->msix_entries[vector].vector,
 		                  handler, 0, adapter->name[vector],
 		                  &(adapter->q_vector[vector]));
