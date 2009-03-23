From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4]: sunlance: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 13:47:19 -0700 (PDT)
Message-ID: <20090323.134719.234362924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbZCWUrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 16:47:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 85C03C8D98A
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 13:47:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sunlance.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 16c528d..3a2bb96 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1311,6 +1311,14 @@ static const struct ethtool_ops sparc_lance_ethtool_ops = {
 	.get_link		= sparc_lance_get_link,
 };
 
+static const struct net_device_ops sparc_lance_ops = {
+	.ndo_open		= lance_open,
+	.ndo_stop		= lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_tx_timeout		= lance_tx_timeout,
+};
+
 static int __devinit sparc_lance_probe_one(struct of_device *op,
 					   struct of_device *ledma,
 					   struct of_device *lebuffer)
@@ -1462,13 +1470,9 @@ no_link_test:
 
 	lp->dev = dev;
 	SET_NETDEV_DEV(dev, &op->dev);
-	dev->open = &lance_open;
-	dev->stop = &lance_close;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->tx_timeout = &lance_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->set_multicast_list = &lance_set_multicast;
 	dev->ethtool_ops = &sparc_lance_ethtool_ops;
+	dev->netdev_ops = &sparc_lance_ops;
 
 	dev->irq = op->irqs[0];
 
-- 
1.6.2.1.222.g570cc

