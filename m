From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] au1000_eth: remove useless check
Date: Mon, 12 May 2008 18:44:21 +0200
Message-ID: <20080512164421.GB22190@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0805121537320.3694@ask.diku.dk> <20080512161734.GA22190@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0805121852510.16384@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60380 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbYELRHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:07:08 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805121852510.16384@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lifespan of the device covers the request_irq .. free_irq interval.

The cast of a void * pointer is not needed either.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 3634b5f..7023d77 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1239,12 +1239,7 @@ static int au1000_rx(struct net_device *dev)
  */
 static irqreturn_t au1000_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
-		return IRQ_RETVAL(1);
-	}
+	struct net_device *dev = dev_id;
 
 	/* Handle RX interrupts first to minimize chance of overrun */
 
