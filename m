From: Dan Carpenter <error27@gmail.com>
Subject: [patch] rrunner: fix buffer overflow
Date: Sat, 2 Jan 2010 16:08:46 +0200
Message-ID: <20100102140846.GA5076@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:35370 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab0ABOJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 09:09:34 -0500
Received: by fxm25 with SMTP id 25so7654326fxm.21
        for <netdev@vger.kernel.org>; Sat, 02 Jan 2010 06:09:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_skbuff is define as:
        struct sk_buff          *tx_skbuff[TX_RING_ENTRIES];

EVT_RING_ENTRIES is 64 and TX_RING_ENTRIES is 32.

This function is in a error path so that's why it wasn't noticed.

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/rrunner.c	2010-01-02 09:25:56.000000000 +0200
+++ devel/drivers/net/rrunner.c	2010-01-02 09:35:13.000000000 +0200
@@ -1293,7 +1293,7 @@ static void rr_dump(struct net_device *d
 
 	printk("Error code 0x%x\n", readl(&regs->Fail1));
 
-	index = (((readl(&regs->EvtPrd) >> 8) & 0xff ) - 1) % EVT_RING_ENTRIES;
+	index = (((readl(&regs->EvtPrd) >> 8) & 0xff) - 1) % TX_RING_ENTRIES;
 	cons = rrpriv->dirty_tx;
 	printk("TX ring index %i, TX consumer %i\n",
 	       index, cons);
