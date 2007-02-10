From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/5]: spidernet: compile break.
Date: Fri, 9 Feb 2007 18:14:02 -0600
Message-ID: <20070210001402.GA2396@austin.ibm.com>
References: <20070210000128.GJ5616@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:40493 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946784AbXBJAOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 19:14:08 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1A0E4Tu006338
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:14:04 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1A0E40V224420
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:14:04 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1A0E3kR009265
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:14:04 -0500
Content-Disposition: inline
In-Reply-To: <20070210000128.GJ5616@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



As of 2.6.20-git4, the spider_net driver does not compile. 
This appears to be due to some archaic usage involving kobjects.

It also fixes a nasty double-free during ifdown of interface.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Cc: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

----
 drivers/net/spider_net.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6.20-git4/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git4.orig/drivers/net/spider_net.c	2007-02-09 17:22:35.000000000 -0600
+++ linux-2.6.20-git4/drivers/net/spider_net.c	2007-02-09 17:24:04.000000000 -0600
@@ -1906,8 +1906,7 @@ spider_net_stop(struct net_device *netde
 	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
 
-	/* free_irq(netdev->irq, netdev);*/
-	free_irq(to_pci_dev(netdev->class_dev.dev)->irq, netdev);
+	free_irq(netdev->irq, netdev);
 
 	spider_net_write_reg(card, SPIDER_NET_GDTDMACCNTR,
 			     SPIDER_NET_DMA_TX_FEND_VALUE);
@@ -1919,8 +1918,6 @@ spider_net_stop(struct net_device *netde
 	spider_net_release_tx_chain(card, 1);
 	spider_net_free_rx_chain_contents(card);
 
-	spider_net_free_rx_chain_contents(card);
-
 	spider_net_free_chain(card, &card->tx_chain);
 	spider_net_free_chain(card, &card->rx_chain);
 
