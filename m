From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] declance: Remove a dangling spin_unlock_irq() thingy
Date: Mon, 21 May 2007 14:33:21 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0705211414540.8263@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:2019 "EHLO
	pollux.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbXEUN4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 09:56:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The spin_unlock_irq() invocation in lance_start_xmit() has no matching 
locking request.  The call is already protected by netif_tx_lock, so 
remove the statement.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply.

  Maciej

patch-mips-2.6.18-20060920-declance-lock-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/declance.c linux-mips-2.6.18-20060920/drivers/net/declance.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/declance.c	2006-09-20 20:50:22.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/declance.c	2007-05-19 21:14:36.000000000 +0000
@@ -915,8 +915,6 @@ static int lance_start_xmit(struct sk_bu
 	/* Kick the lance: transmit now */
 	writereg(&ll->rdp, LE_C0_INEA | LE_C0_TDMD);
 
-	spin_unlock_irq(&lp->lock);
-
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
