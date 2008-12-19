From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: convert driver to use net_device_ops
Date: Fri, 19 Dec 2008 14:24:05 +0000
Message-ID: <1229696646-13666-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60624 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752896AbYLSOYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:24:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index cd70c49..9e33d9f 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1732,6 +1732,19 @@ static struct ethtool_ops smsc911x_ethtool_ops = {
 	.set_eeprom = smsc911x_ethtool_set_eeprom,
 };
 
+static const struct net_device_ops smsc911x_netdev_ops = {
+	.ndo_open		= smsc911x_open,
+	.ndo_stop		= smsc911x_stop,
+	.ndo_start_xmit		= smsc911x_hard_start_xmit,
+	.ndo_get_stats		= smsc911x_get_stats,
+	.ndo_set_multicast_list	= smsc911x_set_multicast_list,
+	.ndo_do_ioctl		= smsc911x_do_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= smsc911x_poll_controller,
+#endif
+};
+
 /* Initializing private device structures, only called from probe */
 static int __devinit smsc911x_init(struct net_device *dev)
 {
@@ -1827,20 +1840,11 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	smsc911x_reg_write(pdata, INT_EN, 0);
 
 	ether_setup(dev);
-	dev->open = smsc911x_open;
-	dev->stop = smsc911x_stop;
-	dev->hard_start_xmit = smsc911x_hard_start_xmit;
-	dev->get_stats = smsc911x_get_stats;
-	dev->set_multicast_list = smsc911x_set_multicast_list;
 	dev->flags |= IFF_MULTICAST;
-	dev->do_ioctl = smsc911x_do_ioctl;
 	netif_napi_add(dev, &pdata->napi, smsc911x_poll, SMSC_NAPI_WEIGHT);
+	dev->netdev_ops = &smsc911x_netdev_ops;
 	dev->ethtool_ops = &smsc911x_ethtool_ops;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = smsc911x_poll_controller;
-#endif				/* CONFIG_NET_POLL_CONTROLLER */
-
 	return 0;
 }
 
-- 
1.6.0.4

