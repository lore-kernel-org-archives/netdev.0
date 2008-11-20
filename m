From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] ipmr: convert ipmr virtual interface to net_device_ops
Date: Thu, 20 Nov 2008 09:59:16 -0800
Message-ID: <20081120175933.753991540@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53070 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbYKTSEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:12 -0500
Content-Disposition: inline; filename=ipmr-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ipmr.c	2008-11-20 09:14:09.000000000 -0800
+++ b/net/ipv4/ipmr.c	2008-11-20 09:15:27.000000000 -0800
@@ -222,12 +222,16 @@ static int reg_vif_xmit(struct sk_buff *
 	return 0;
 }
 
+static const struct net_device_ops reg_vif_netdev_ops = {
+	.ndo_start_xmit	= reg_vif_xmit,
+};
+
 static void reg_vif_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 8;
 	dev->flags		= IFF_NOARP;
-	dev->hard_start_xmit	= reg_vif_xmit;
+	dev->netdev_ops		= &reg_vif_netdev_ops,
 	dev->destructor		= free_netdev;
 }
 
--- a/net/ipv6/ip6mr.c	2008-11-20 09:14:08.000000000 -0800
+++ b/net/ipv6/ip6mr.c	2008-11-20 09:15:27.000000000 -0800
@@ -416,12 +416,16 @@ static int reg_vif_xmit(struct sk_buff *
 	return 0;
 }
 
+static const struct net_device_ops reg_vif_netdev_ops = {
+	.ndo_start_xmit	= reg_vif_xmit,
+};
+
 static void reg_vif_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= 1500 - sizeof(struct ipv6hdr) - 8;
 	dev->flags		= IFF_NOARP;
-	dev->hard_start_xmit	= reg_vif_xmit;
+	dev->netdev_ops		= &reg_vif_netdev_ops;
 	dev->destructor		= free_netdev;
 }
 

-- 

