From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/10] sky2: Refactor sky2_down into two functions
Date: Fri, 12 Feb 2010 08:58:05 -0800
Message-ID: <20100212165938.074245846@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49510 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757444Ab0BLRIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:32 -0500
Content-Disposition: inline; filename=sky2-mike4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Create a sky2_hw_down that brings the hardware down.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminber <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

--- a/drivers/net/sky2.c	2010-02-11 15:33:44.579670361 -0800
+++ b/drivers/net/sky2.c	2010-02-11 15:46:45.651858252 -0800
@@ -1908,21 +1908,12 @@ static void sky2_tx_reset(struct sky2_hw
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 }
 
-/* Network shutdown */
-static int sky2_down(struct net_device *dev)
+static void sky2_hw_down(struct sky2_port *sky2)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u16 ctrl;
 	u32 imask;
-
-	/* Never really got started! */
-	if (!sky2->tx_le)
-		return 0;
-
-	if (netif_msg_ifdown(sky2))
-		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+	u16 ctrl;
 
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
@@ -1972,6 +1963,21 @@ static int sky2_down(struct net_device *
 
 	/* Free any pending frames stuck in HW queue */
 	sky2_tx_complete(sky2, sky2->tx_prod);
+}
+
+/* Network shutdown */
+static int sky2_down(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+
+	/* Never really got started! */
+	if (!sky2->tx_le)
+		return 0;
+
+	if (netif_msg_ifdown(sky2))
+		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+
+	sky2_hw_down(sky2);
 
 	sky2_free_buffers(sky2);
 

-- 

