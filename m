From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5] tg3: Add tg3_netif_stop() in vlan functions
Date: Thu, 29 Jun 2006 18:29:06 -0700
Message-ID: <1151630947.21798.17.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:22289 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750737AbWF3B2A
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:28:00 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add tg3_netif_stop() when changing the vlgrp (vlan group) pointer. It
is necessary to quiesce the device before changing that pointer.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 35f9316..2447fa3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8738,6 +8738,9 @@ static void tg3_vlan_rx_register(struct 
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (netif_running(dev))
+		tg3_netif_stop(tp);
+
 	tg3_full_lock(tp, 0);
 
 	tp->vlgrp = grp;
@@ -8746,16 +8749,25 @@ static void tg3_vlan_rx_register(struct 
 	__tg3_set_rx_mode(dev);
 
 	tg3_full_unlock(tp);
+
+	if (netif_running(dev))
+		tg3_netif_start(tp);
 }
 
 static void tg3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (netif_running(dev))
+		tg3_netif_stop(tp);
+
 	tg3_full_lock(tp, 0);
 	if (tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
 	tg3_full_unlock(tp);
+
+	if (netif_running(dev))
+		tg3_netif_start(tp);
 }
 #endif
 


