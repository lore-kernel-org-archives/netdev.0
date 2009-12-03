From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.32 1/3] net: Fix ks8851 snl NULL pointer dereference Oops
Date: Thu, 3 Dec 2009 13:06:42 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A40@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Ben Dooks" <ben@simtec.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755727AbZLCVOO@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

This fixes the NULL pointer dereference Oops in the ks8851 snl network driver during transmission.  All socket buffers from the queue are processed inside the loop, but new workqueues have been scheduled to run.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
diff -urpN linux-2.6.32.old/drivers/net/ks8851.c linux-2.6.32.new/drivers/net/ks8851.c
--- linux-2.6.32.old/drivers/net/ks8851.c	2009-11-03 11:37:49.000000000 -0800
+++ linux-2.6.32.new/drivers/net/ks8851.c	2009-12-02 15:31:39.000000000 -0800
@@ -1,4 +1,4 @@
-/* drivers/net/ks8651.c
+/* drivers/net/ks8851.c
  *
  * Copyright 2009 Simtec Electronics
  *	http://www.simtec.co.uk/
@@ -714,7 +714,7 @@ static void ks8851_tx_work(struct work_s
 {
 	struct ks8851_net *ks = container_of(work, struct ks8851_net, tx_work);
 	struct sk_buff *txb;
-	bool last = false;
+	bool last = skb_queue_empty(&ks->txq);
 
 	mutex_lock(&ks->lock);
 
