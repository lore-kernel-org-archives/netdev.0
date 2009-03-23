From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4]: sunqe: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 13:47:23 -0700 (PDT)
Message-ID: <20090323.134723.74602942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38536
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757803AbZCWUrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 16:47:35 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 54DA4C8D98A
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 13:47:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sunqe.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index fe0c3f2..dd4757d 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -829,6 +829,14 @@ fail:
 	return NULL;
 }
 
+static const struct net_device_ops qec_ops = {
+	.ndo_open		= qe_open,
+	.ndo_stop		= qe_close,
+	.ndo_start_xmit		= qe_start_xmit,
+	.ndo_set_multicast_list	= qe_set_multicast,
+	.ndo_tx_timeout		= qe_tx_timeout,
+};
+
 static int __devinit qec_ether_init(struct of_device *op)
 {
 	static unsigned version_printed;
@@ -893,15 +901,11 @@ static int __devinit qec_ether_init(struct of_device *op)
 
 	SET_NETDEV_DEV(dev, &op->dev);
 
-	dev->open = qe_open;
-	dev->stop = qe_close;
-	dev->hard_start_xmit = qe_start_xmit;
-	dev->set_multicast_list = qe_set_multicast;
-	dev->tx_timeout = qe_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
 	dev->irq = op->irqs[0];
 	dev->dma = 0;
 	dev->ethtool_ops = &qe_ethtool_ops;
+	dev->netdev_ops = &qec_ops;
 
 	res = register_netdev(dev);
 	if (res)
-- 
1.6.2.1.222.g570cc

