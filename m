From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4]: sunbmac: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 13:47:12 -0700 (PDT)
Message-ID: <20090323.134712.47671318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757246AbZCWUrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 16:47:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B8270C8D98A
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 13:47:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sunbmac.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 7f69c7f..70d96b7 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1074,6 +1074,15 @@ static const struct ethtool_ops bigmac_ethtool_ops = {
 	.get_link		= bigmac_get_link,
 };
 
+static const struct net_device_ops bigmac_ops = {
+	.ndo_open		= bigmac_open,
+	.ndo_stop		= bigmac_close,
+	.ndo_start_xmit		= bigmac_start_xmit,
+	.ndo_get_stats		= bigmac_get_stats,
+	.ndo_set_multicast_list	= bigmac_set_multicast,
+	.ndo_tx_timeout		= bigmac_tx_timeout,
+};
+
 static int __devinit bigmac_ether_init(struct of_device *op,
 				       struct of_device *qec_op)
 {
@@ -1187,16 +1196,8 @@ static int __devinit bigmac_ether_init(struct of_device *op,
 	bp->dev = dev;
 
 	/* Set links to our BigMAC open and close routines. */
-	dev->open = &bigmac_open;
-	dev->stop = &bigmac_close;
-	dev->hard_start_xmit = &bigmac_start_xmit;
 	dev->ethtool_ops = &bigmac_ethtool_ops;
-
-	/* Set links to BigMAC statistic and multi-cast loading code. */
-	dev->get_stats = &bigmac_get_stats;
-	dev->set_multicast_list = &bigmac_set_multicast;
-
-	dev->tx_timeout = &bigmac_tx_timeout;
+	dev->netdev_ops = &bigmac_ops;
 	dev->watchdog_timeo = 5*HZ;
 
 	/* Finish net device registration. */
-- 
1.6.2.1.222.g570cc

