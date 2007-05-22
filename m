From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 3/10] spidernet: move a block of code around
Date: Tue, 22 May 2007 18:21:15 -0500
Message-ID: <20070522232115.GB2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:57019 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760892AbXEVXVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 19:21:19 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MMJDGA000324
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:19:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNLGsg531268
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:21:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNLGQP027273
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:21:16 -0400
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Put the enable and disable routines next to one-another, 
as this makes verifying thier symmetry that much easier.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:24.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:30.000000000 -0500
@@ -506,6 +506,20 @@ spider_net_enable_rxdmac(struct spider_n
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
@@ -657,20 +671,6 @@ write_hash:
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
