From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 9/10] spidernet: service TX later.
Date: Wed, 16 May 2007 17:21:47 -0500
Message-ID: <20070516222147.GI4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57289 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711AbXEPWVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 18:21:52 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GMLovL025635
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:21:50 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GMLmVG250026
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:21:50 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GMLlZG025926
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 16:21:47 -0600
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-16 17:20:36.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-16 17:20:44.000000000 -0500
@@ -1212,7 +1212,6 @@ spider_net_poll(struct net_device *netde
 	int packets_to_do, packets_done = 0;
 	int no_more_packets = 0;
 
-	spider_net_cleanup_tx_ring(card);
 	packets_to_do = min(*budget, netdev->quota);
 
 	while (packets_to_do) {
@@ -1231,6 +1230,8 @@ spider_net_poll(struct net_device *netde
 	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxdmac(card);
 
+	spider_net_cleanup_tx_ring(card);
+
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (no_more_packets) {
