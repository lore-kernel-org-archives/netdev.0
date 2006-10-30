From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,try3 3/3] ep93xx_eth: don't report RX errors
Date: Mon, 30 Oct 2006 19:54:08 +0100
Message-ID: <20061030185408.GD14805@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:49331 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1161356AbWJ3SyJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:54:09 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Flooding the console with error messages for every RX FIFO overrun,
checksum error and framing error isn't very sensible.  Each of these
errors can occur during normal operation, so stop printk'ing error
messages for RX errors at all.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
===================================================================
--- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
+++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
@@ -230,9 +230,6 @@ static int ep93xx_rx(struct net_device *
 					 " %.8x %.8x\n", rstat0, rstat1);
 
 		if (!(rstat0 & RSTAT0_RWE)) {
-			printk(KERN_NOTICE "ep93xx_rx: receive error "
-					 " %.8x %.8x\n", rstat0, rstat1);
-
 			ep->stats.rx_errors++;
 			if (rstat0 & RSTAT0_OE)
 				ep->stats.rx_fifo_errors++;
