From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] E1000: Do not allow requeue of freed skb
Date: Fri, 21 Sep 2007 10:30:43 +0530
Message-ID: <20070921050043.9603.76335.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47762 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974AbXIUE60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 00:58:26 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8L4wPfY006032
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:58:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8L4wPlN688710
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:58:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8L4wOvw001064
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Returning BUSY will make qdisc_restart enqueue the skb which was already
freed. The bad skb was correctly freed and we should return NETDEV_TX_OK.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
--- a/drivers/net/e1000e/netdev.c	2007-09-21 10:23:29.000000000 +0530
+++ b/drivers/net/e1000e/netdev.c	2007-09-21 10:24:20.000000000 +0530
@@ -3531,7 +3531,7 @@ static int e1000_xmit_frame(struct sk_bu
 		/* handle pci_map_single() error in e1000_tx_map */
 		dev_kfree_skb_any(skb);
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
-		return NETDEV_TX_BUSY;
+		return NETDEV_TX_OK;
 	}
 
 	e1000_tx_queue(adapter, tx_flags, count);
