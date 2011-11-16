From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] sky2: rename up/down functions
Date: Wed, 16 Nov 2011 15:42:57 -0800
Message-ID: <20111116234344.717497342@vyatta.com>
References: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48426 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754501Ab1KPXwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:52:33 -0500
Content-Disposition: inline; filename=sky2-open-stop-rename.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is clearer if the up/down functions are renamed to
open/close like other drivers.  Purely syntax change.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:38.282631277 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:39.518659262 -0800
@@ -1728,7 +1728,7 @@ static int sky2_setup_irq(struct sky2_hw
 
 
 /* Bring up network interface. */
-static int sky2_up(struct net_device *dev)
+static int sky2_open(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
@@ -2098,7 +2098,7 @@ static void sky2_hw_down(struct sky2_por
 }
 
 /* Network shutdown */
-static int sky2_down(struct net_device *dev)
+static int sky2_close(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
@@ -2601,7 +2601,7 @@ static inline void sky2_tx_done(struct n
 	if (netif_running(dev)) {
 		sky2_tx_complete(sky2, last);
 
-		/* Wake unless it's detached, and called e.g. from sky2_down() */
+		/* Wake unless it's detached, and called e.g. from sky2_close() */
 		if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 			netif_wake_queue(dev);
 	}
@@ -3391,7 +3391,7 @@ static void sky2_detach(struct net_devic
 		netif_tx_lock(dev);
 		netif_device_detach(dev);	/* stop txq */
 		netif_tx_unlock(dev);
-		sky2_down(dev);
+		sky2_close(dev);
 	}
 }
 
@@ -3401,7 +3401,7 @@ static int sky2_reattach(struct net_devi
 	int err = 0;
 
 	if (netif_running(dev)) {
-		err = sky2_up(dev);
+		err = sky2_open(dev);
 		if (err) {
 			netdev_info(dev, "could not restart %d\n", err);
 			dev_close(dev);
@@ -4570,7 +4570,7 @@ static int sky2_device_event(struct noti
 	struct net_device *dev = ptr;
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (dev->netdev_ops->ndo_open != sky2_up || !sky2_debug)
+	if (dev->netdev_ops->ndo_open != sky2_open || !sky2_debug)
 		return NOTIFY_DONE;
 
 	switch (event) {
@@ -4635,8 +4635,8 @@ static __exit void sky2_debug_cleanup(vo
    not allowing netpoll on second port */
 static const struct net_device_ops sky2_netdev_ops[2] = {
   {
-	.ndo_open		= sky2_up,
-	.ndo_stop		= sky2_down,
+	.ndo_open		= sky2_open,
+	.ndo_stop		= sky2_close,
 	.ndo_start_xmit		= sky2_xmit_frame,
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -4652,8 +4652,8 @@ static const struct net_device_ops sky2_
 #endif
   },
   {
-	.ndo_open		= sky2_up,
-	.ndo_stop		= sky2_down,
+	.ndo_open		= sky2_open,
+	.ndo_stop		= sky2_close,
 	.ndo_start_xmit		= sky2_xmit_frame,
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
