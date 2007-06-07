From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 10/18] spidernet: service TX later.
Date: Thu, 7 Jun 2007 14:41:30 -0500
Message-ID: <20070607194130.GJ16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54936 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762770AbXFGTlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 15:41:31 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JgZHk032621
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:42:35 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JfVIx516114
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:41:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JfU2F002835
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:41:31 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When entering the netdev poll routine, empty out the RX
chain first, before cleaning up the TX chain. This should
help avoid RX buffer overflows.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:52:17.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:52:20.000000000 -0500
@@ -1224,7 +1224,6 @@ spider_net_poll(struct net_device *netde
 	int packets_to_do, packets_done = 0;
 	int no_more_packets = 0;
 
-	spider_net_cleanup_tx_ring(card);
 	packets_to_do = min(*budget, netdev->quota);
 
 	while (packets_to_do) {
@@ -1243,6 +1242,8 @@ spider_net_poll(struct net_device *netde
 	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxdmac(card);
 
+	spider_net_cleanup_tx_ring(card);
+
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (no_more_packets) {
