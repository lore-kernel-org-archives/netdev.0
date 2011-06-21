From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 6/7] niu: use netdev_irqname
Date: Tue, 21 Jun 2011 10:05:47 -0700
Message-ID: <20110621170658.885992666@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49493 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756842Ab1FURHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:23 -0400
Content-Disposition: inline; filename=niu-use-irqname.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device also has some other IRQ's unrelated to rings
which are named with another convention.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/niu.c	2011-06-21 09:57:00.739951363 -0700
+++ b/drivers/net/niu.c	2011-06-21 09:59:22.683951282 -0700
@@ -6048,11 +6048,12 @@ static void niu_set_irq_name(struct niu
 
 	for (i = 0; i < np->num_ldg - j; i++) {
 		if (i < np->num_rx_rings)
-			sprintf(np->irq_name[i+j], "%s-rx-%d",
-				np->dev->name, i);
+			netdev_irqname(np->irq_name[i+j], IFNAMSIZ+6,
+				       np->dev, NETIF_IRQ_RX, i);
 		else if (i < np->num_tx_rings + np->num_rx_rings)
-			sprintf(np->irq_name[i+j], "%s-tx-%d", np->dev->name,
-				i - np->num_rx_rings);
+			netdev_irqname(np->irq_name[i+j], IFNAMSIZ+6,
+				       np->dev, NETIF_IRQ_TX,
+				       i - np->num_rx_rings);
 	}
 }
 


