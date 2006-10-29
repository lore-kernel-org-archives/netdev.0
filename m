From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/3] ep93xx_eth: don't report RX FIFO overrun errors
Date: Sun, 29 Oct 2006 14:06:49 +0100
Message-ID: <20061029130649.GD6900@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:62124 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S965191AbWJ2NGv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 08:06:51 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Flooding the console with an RX FIFO overrun error for every single
dropped packet isn't very sensible.  The hardware is very underpowered
according to today's standards, and RX FIFO overrun errors can be
triggered quite easily, so don't report them at all.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
===================================================================
--- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
+++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
@@ -230,8 +230,9 @@ static int ep93xx_rx(struct net_device *
 					 " %.8x %.8x\n", rstat0, rstat1);
 
 		if (!(rstat0 & RSTAT0_RWE)) {
-			printk(KERN_NOTICE "ep93xx_rx: receive error "
-					 " %.8x %.8x\n", rstat0, rstat1);
+			if (!(rstat0 & RSTAT_OE))
+				printk(KERN_NOTICE "ep93xx_rx: receive error "
+				       " %.8x %.8x\n", rstat0, rstat1);
 
 			ep->stats.rx_errors++;
 			if (rstat0 & RSTAT0_OE)
