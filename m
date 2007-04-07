From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] skge: turn carrier off when down
Date: Sat, 07 Apr 2007 16:42:06 -0700
Message-ID: <20070407234235.566060329@linux-foundation.org>
References: <20070407234205.348565140@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36304 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965994AbXDGXoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:44:25 -0400
Content-Disposition: inline; filename=skge-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver needs to turn off carrier when down, otherwise it can
confuse bonding and bridging and looks like carrier is on immediately
when it is brought back up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- linux-2.6.20.y.orig/drivers/net/skge.c	2007-04-07 15:36:05.000000000 -0700
+++ linux-2.6.20.y/drivers/net/skge.c	2007-04-07 15:54:36.000000000 -0700
@@ -2462,6 +2462,7 @@
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		cancel_rearming_delayed_work(&skge->link_thread);
 

--

