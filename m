From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] ieee1394: convert to net_device_ops
Date: Tue, 6 Jan 2009 14:54:56 -0800
Message-ID: <20090106145456.37ecedaa@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: krh@redhat.com, stefanr@s5r6.in-berlin.de,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50015 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbZAFW4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 17:56:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
My goal is to have all drivers found using make allmodconfig using net_device_ops
by 2.6.28-rc2

--- a/drivers/ieee1394/eth1394.c	2009-01-03 20:19:30.123514679 -0800
+++ b/drivers/ieee1394/eth1394.c	2009-01-03 20:21:51.018766544 -0800
@@ -516,16 +516,20 @@ static const struct header_ops ether1394
 	.parse		= ether1394_header_parse,
 };
 
+static const struct net_device_ops ether1394_netdev_ops = {
+	.ndo_open	= ether1394_open,
+	.ndo_stop	= ether1394_stop,
+	.ndo_start_xmit	= ether1394_tx,
+	.ndo_get_stats	= ether1394_stats,
+	.ndo_tx_timeout	= ether1394_tx_timeout,
+	.ndo_change_mtu	= ether1394_change_mtu,
+};
+
 static void ether1394_init_dev(struct net_device *dev)
 {
-	dev->open		= ether1394_open;
-	dev->stop		= ether1394_stop;
-	dev->hard_start_xmit	= ether1394_tx;
-	dev->get_stats		= ether1394_stats;
-	dev->tx_timeout		= ether1394_tx_timeout;
-	dev->change_mtu		= ether1394_change_mtu;
 
 	dev->header_ops		= &ether1394_header_ops;
+	dev->netdev_ops		= &ether1394_netdev_ops;
 
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
