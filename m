From: David Miller <davem@davemloft.net>
Subject: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 00:52:05 -0700 (PDT)
Message-ID: <20090320.005205.65922171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750782AbZCTHwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 03:52:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 75EADC8D985
	for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 00:52:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Committed to net-next-2.6...

sunvnet: Convert to net_device_ops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sunvnet.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index 611230f..a82fb2a 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1012,6 +1012,16 @@ err_out:
 static LIST_HEAD(vnet_list);
 static DEFINE_MUTEX(vnet_list_mutex);
 
+static const struct net_device_ops vnet_ops = {
+	.ndo_open		= vnet_open,
+	.ndo_stop		= vnet_close,
+	.ndo_set_multicast_list	= vnet_set_rx_mode,
+	.ndo_set_mac_address	= vnet_set_mac_addr,
+	.ndo_tx_timeout		= vnet_tx_timeout,
+	.ndo_change_mtu		= vnet_change_mtu,
+	.ndo_start_xmit		= vnet_start_xmit,
+};
+
 static struct vnet * __devinit vnet_new(const u64 *local_mac)
 {
 	struct net_device *dev;
@@ -1040,15 +1050,9 @@ static struct vnet * __devinit vnet_new(const u64 *local_mac)
 	INIT_LIST_HEAD(&vp->list);
 	vp->local_mac = *local_mac;
 
-	dev->open = vnet_open;
-	dev->stop = vnet_close;
-	dev->set_multicast_list = vnet_set_rx_mode;
-	dev->set_mac_address = vnet_set_mac_addr;
-	dev->tx_timeout = vnet_tx_timeout;
+	dev->netdev_ops = &vnet_ops;
 	dev->ethtool_ops = &vnet_ethtool_ops;
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
-	dev->change_mtu = vnet_change_mtu;
-	dev->hard_start_xmit = vnet_start_xmit;
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.6.2.1.222.g570cc

