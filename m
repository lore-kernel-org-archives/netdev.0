From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4]: myri_sbus: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 13:47:10 -0700 (PDT)
Message-ID: <20090323.134710.03831489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756528AbZCWUrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 16:47:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 506F7C8D98A
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 13:47:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/myri_sbus.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 88b5288..4ced27f 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -896,6 +896,15 @@ static const struct header_ops myri_header_ops = {
 	.cache_update	= myri_header_cache_update,
 };
 
+static const struct net_device_ops myri_ops = {
+	.ndo_open		= myri_open,
+	.ndo_stop		= myri_close,
+	.ndo_start_xmit		= myri_start_xmit,
+	.ndo_set_multicast_list	= myri_set_multicast,
+	.ndo_tx_timeout		= myri_tx_timeout,
+	.ndo_change_mtu		= myri_change_mtu,
+};
+
 static int __devinit myri_sbus_probe(struct of_device *op, const struct of_device_id *match)
 {
 	struct device_node *dp = op->node;
@@ -1048,13 +1057,9 @@ static int __devinit myri_sbus_probe(struct of_device *op, const struct of_devic
 	sbus_writel((1 << i), mp->cregs + MYRICTRL_IRQLVL);
 
 	mp->dev = dev;
-	dev->open = &myri_open;
-	dev->stop = &myri_close;
-	dev->hard_start_xmit = &myri_start_xmit;
-	dev->tx_timeout = &myri_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->set_multicast_list = &myri_set_multicast;
 	dev->irq = op->irqs[0];
+	dev->netdev_ops = &myri_ops;
 
 	/* Register interrupt handler now. */
 	DET(("Requesting MYRIcom IRQ line.\n"));
@@ -1065,7 +1070,6 @@ static int __devinit myri_sbus_probe(struct of_device *op, const struct of_devic
 	}
 
 	dev->mtu		= MYRINET_MTU;
-	dev->change_mtu		= myri_change_mtu;
 	dev->header_ops		= &myri_header_ops;
 
 	dev->hard_header_len	= (ETH_HLEN + MYRI_PAD_LEN);
-- 
1.6.2.1.222.g570cc

