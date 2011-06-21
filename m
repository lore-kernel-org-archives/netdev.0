From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 7/7] netxen: use netdev_irqname
Date: Tue, 21 Jun 2011 10:05:48 -0700
Message-ID: <20110621170658.981179979@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49492 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756989Ab1FURHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:24 -0400
Content-Disposition: inline; filename=netxen-use-irqname.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new netdev_irqname to cause network device interrupts to
be named according to the standard convention of "ethX-N".

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/netxen/netxen_nic_main.c	2011-06-21 10:00:10.223951255 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2011-06-21 10:02:46.695951169 -0700
@@ -955,7 +955,8 @@ netxen_nic_request_irq(struct netxen_ada
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
+		netdev_irqname(sds_ring->name, sizeof(sds_ring->name),
+			       netdev, NETIF_IRQ_TXRX, ring);
 		err = request_irq(sds_ring->irq, handler,
 				  flags, sds_ring->name, sds_ring);
 		if (err)


