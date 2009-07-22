From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] ethtool: device independent rx_csum and
 get_flags routines
Date: Wed, 22 Jul 2009 16:38:22 -0700
Message-ID: <1248305902.1061.84.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:58209 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619AbZGVXjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 19:39:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6MNWdZ5012884
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 19:32:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6MNcNtK251758
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 19:38:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6MNZkS0000912
	for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 19:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6] ethtool: add device independent rx_csum and get_flags routines

This helps avoid error messages with ethtool -k on devices that
don't provide device specific routines.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

------------------------------------------------------------------

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d9d5160..cf36ff4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -30,6 +30,11 @@ u32 ethtool_op_get_link(struct net_device *dev)
 	return netif_carrier_ok(dev) ? 1 : 0;
 }
 
+u32 ethtool_op_get_rx_csum(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_ALL_CSUM) != 0;
+}
+
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_ALL_CSUM) != 0;
@@ -1004,7 +1009,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		break;
 	case ETHTOOL_GRXCSUM:
 		rc = ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_rx_csum);
+				       (dev->ethtool_ops->get_rx_csum ?
+					dev->ethtool_ops->get_rx_csum :
+					ethtool_op_get_rx_csum));
 		break;
 	case ETHTOOL_SRXCSUM:
 		rc = ethtool_set_rx_csum(dev, useraddr);
@@ -1068,7 +1075,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		break;
 	case ETHTOOL_GFLAGS:
 		rc = ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_flags);
+				       (dev->ethtool_ops->get_flags ?
+					dev->ethtool_ops->get_flags :
+					ethtool_op_get_flags));
 		break;
 	case ETHTOOL_SFLAGS:
 		rc = ethtool_set_value(dev, useraddr,


