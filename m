From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] smc91x: struct net_device_ops
Date: Mon, 26 Jan 2009 15:55:18 +0900
Message-ID: <20090126065518.16879.7531.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, nico@cam.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:47111 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbZAZG5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 01:57:19 -0500
Received: by rv-out-0506.google.com with SMTP id k40so5726627rvb.1
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2009 22:57:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

Convert the smc91x driver to use struct net_device_ops.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.c |   22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

--- 0001/drivers/net/smc91x.c
+++ work/drivers/net/smc91x.c	2009-01-26 12:31:04.000000000 +0900
@@ -1768,6 +1768,19 @@ static const struct ethtool_ops smc_etht
 	.set_eeprom	= smc_ethtool_seteeprom,
 };
 
+static const struct net_device_ops smc_netdev_ops = {
+	.ndo_open		= smc_open,
+	.ndo_stop		= smc_close,
+	.ndo_start_xmit		= smc_hard_start_xmit,
+	.ndo_tx_timeout		= smc_timeout,
+	.ndo_set_multicast_list	= smc_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= smc_poll_controller,
+#endif
+};
+
 /*
  * smc_findirq
  *
@@ -1977,16 +1990,9 @@ static int __devinit smc_probe(struct ne
 	/* Fill in the fields of the device structure with ethernet values. */
 	ether_setup(dev);
 
-	dev->open = smc_open;
-	dev->stop = smc_close;
-	dev->hard_start_xmit = smc_hard_start_xmit;
-	dev->tx_timeout = smc_timeout;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	dev->set_multicast_list = smc_set_multicast_list;
+	dev->netdev_ops = &smc_netdev_ops;
 	dev->ethtool_ops = &smc_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = smc_poll_controller;
-#endif
 
 	tasklet_init(&lp->tx_task, smc_hardware_send_pkt, (unsigned long)dev);
 	INIT_WORK(&lp->phy_configure, smc_phy_configure);
