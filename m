From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] sis190: Rx filter init is needed for MAC address change.
Date: Thu, 28 Jul 2011 09:11:23 +0200
Message-ID: <20110728071123.GA11286@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Klement Fish <klement2@azet.sk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49959 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab1G1H1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:27:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=34552

Signed-off-by: Klement Fish <klement2@azet.sk>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 8ad7bfb..3c0f131 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1825,6 +1825,16 @@ static int sis190_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		generic_mii_ioctl(&tp->mii_if, if_mii(ifr), cmd, NULL);
 }
 
+static int sis190_mac_addr(struct net_device  *dev, void *p)
+{
+	int rc;
+
+	rc = eth_mac_addr(dev, p);
+	if (!rc)
+		sis190_init_rxfilter(dev);
+	return rc;
+}
+
 static const struct net_device_ops sis190_netdev_ops = {
 	.ndo_open		= sis190_open,
 	.ndo_stop		= sis190_close,
@@ -1833,7 +1843,7 @@ static const struct net_device_ops sis190_netdev_ops = {
 	.ndo_tx_timeout		= sis190_tx_timeout,
 	.ndo_set_multicast_list = sis190_set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= sis190_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	 = sis190_netpoll,
-- 
1.7.4.4

