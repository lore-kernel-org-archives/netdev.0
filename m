From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/18] spidernet: move a block of code around
Date: Thu, 7 Jun 2007 14:25:43 -0500
Message-ID: <20070607192543.GD16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:57873 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757522AbXFGTZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 15:25:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JPlSS026404
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:25:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JPlJE259548
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:25:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JPk4T027452
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 13:25:47 -0600
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Put the enable and disable routines next to one-another, 
as this makes verifying thier symmetry that much easier.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:51:47.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:51:48.000000000 -0500
@@ -505,6 +505,20 @@ spider_net_enable_rxdmac(struct spider_n
 }
 
 /**
+ * spider_net_disable_rxdmac - disables the receive DMA controller
+ * @card: card structure
+ *
+ * spider_net_disable_rxdmac terminates processing on the DMA controller
+ * by turing off the DMA controller, with the force-end flag set.
+ */
+static inline void
+spider_net_disable_rxdmac(struct spider_net_card *card)
+{
+	spider_net_write_reg(card, SPIDER_NET_GDADMACCNTR,
+			     SPIDER_NET_DMA_RX_FEND_VALUE);
+}
+
+/**
  * spider_net_refill_rx_chain - refills descriptors/skbs in the rx chains
  * @card: card structure
  *
@@ -656,20 +670,6 @@ write_hash:
 }
 
 /**
- * spider_net_disable_rxdmac - disables the receive DMA controller
- * @card: card structure
- *
- * spider_net_disable_rxdmac terminates processing on the DMA controller by
- * turing off DMA and issueing a force end
- */
-static void
-spider_net_disable_rxdmac(struct spider_net_card *card)
-{
-	spider_net_write_reg(card, SPIDER_NET_GDADMACCNTR,
-			     SPIDER_NET_DMA_RX_FEND_VALUE);
-}
-
-/**
  * spider_net_prepare_tx_descr - fill tx descriptor with skb data
  * @card: card structure
  * @descr: descriptor structure to fill out
