From: Amit Uttamchandani <auttamchandani@logicube.com>
Subject: [PATCH 1/1] net/velocity: add poll controller function for velocity nic
Date: Thu, 18 Jul 2013 17:45:22 -0700
Message-ID: <1374194722-6051-1-git-send-email-auttamchandani@logicube.com>
Cc: linux-kernel@vger.kernel.org,
	Amit Uttamchandani <auttamchandani@logicube.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o148.mxlogic.net ([208.65.144.71]:40222 "EHLO
	p01c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933632Ab3GSAxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 20:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add poll controller function for velocity nic.

Signed-off-by: Amit Uttamchandani <auttamchandani@logicube.com>
---
 drivers/net/ethernet/via/via-velocity.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 1d6dc41..ef77631 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2376,6 +2376,23 @@ out_0:
 	return ret;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ *  velocity_poll_controller		-	Velocity Poll controller function
+ *  @dev: network device
+ *
+ *
+ *  Used by NETCONSOLE and other diagnostic tools to allow network I/P
+ *  with interrupts disabled.
+ */
+static void velocity_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	velocity_intr(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
 /**
  *	velocity_mii_ioctl		-	MII ioctl handler
  *	@dev: network device
@@ -2641,6 +2658,9 @@ static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_do_ioctl		= velocity_ioctl,
 	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= velocity_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = velocity_poll_controller,
+#endif
 };
 
 /**
-- 
1.8.0.rc0
