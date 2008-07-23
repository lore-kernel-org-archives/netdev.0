From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: don't stop queue on shutdown
Date: Tue, 22 Jul 2008 21:50:42 -0700
Message-ID: <20080722215042.310ef2f3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41877 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbYGWEue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 00:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is unnecessary, to stop queue and turn off carrier in shutdown
routine. With new netdev_queue this causes warnings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-07-22 15:00:19.000000000 -0700
+++ b/drivers/net/sky2.c	2008-07-22 16:16:53.000000000 -0700
@@ -1829,9 +1829,6 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	/* Stop more packets from being queued */
-	netif_stop_queue(dev);
-
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
@@ -1887,8 +1884,6 @@ static int sky2_down(struct net_device *
 
 	sky2_phy_power_down(hw, port);
 
-	netif_carrier_off(dev);
-
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
