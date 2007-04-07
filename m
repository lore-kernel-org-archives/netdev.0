From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] skge: turn carrier off when down
Date: Sat, 07 Apr 2007 16:02:25 -0700
Message-ID: <20070407230325.470129283@linux-foundation.org>
References: <20070407230224.486666854@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36285 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbXDGXnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:43:09 -0400
Content-Disposition: inline; filename=skge-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver needs to turn off carrier when down, otherwise it can
confuse bonding and bridging and looks like carrier is on immediately
when it is brought back up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- netdev-2.6.orig/drivers/net/skge.c	2007-04-07 15:09:13.000000000 -0700
+++ netdev-2.6/drivers/net/skge.c	2007-04-07 15:09:58.000000000 -0700
@@ -2535,6 +2535,7 @@
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 

--

