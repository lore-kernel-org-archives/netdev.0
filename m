From: Patrick McHardy <kaber@trash.net>
Subject: vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
Date: Fri, 17 Apr 2009 18:05:32 +0200
Message-ID: <49E8A8CC.8060305@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507000306080402030401"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56859 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757747AbZDQQFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060507000306080402030401
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060507000306080402030401
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit c9bfff86b3c8e39df7ddd34e1eac238edc5bf810
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Apr 17 18:04:43 2009 +0200

    vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
    
    Check whether the underlying device provides a set of ethtool ops before
    checking for individual handlers to avoid NULL pointer dereferences.
    
    Reported-by: Art van Breemen <ard@telegraafnet.nl>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 70d3ef4..214a8cf 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -376,7 +376,8 @@ static u32 macvlan_ethtool_get_rx_csum(struct net_device *dev)
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (lowerdev->ethtool_ops->get_rx_csum == NULL)
+	if (lowerdev->ethtool_ops == NULL ||
+	    lowerdev->ethtool_ops->get_rx_csum == NULL)
 		return 0;
 	return lowerdev->ethtool_ops->get_rx_csum(lowerdev);
 }
@@ -387,7 +388,8 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (!lowerdev->ethtool_ops->get_settings)
+	if (!lowerdev->ethtool_ops ||
+	    !lowerdev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
 	return lowerdev->ethtool_ops->get_settings(lowerdev, cmd);
@@ -398,7 +400,8 @@ static u32 macvlan_ethtool_get_flags(struct net_device *dev)
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (!lowerdev->ethtool_ops->get_flags)
+	if (!lowerdev->ethtool_ops ||
+	    !lowerdev->ethtool_ops->get_flags)
 		return 0;
 	return lowerdev->ethtool_ops->get_flags(lowerdev);
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1b34135..6b09213 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -668,7 +668,8 @@ static int vlan_ethtool_get_settings(struct net_device *dev,
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 
-	if (!real_dev->ethtool_ops->get_settings)
+	if (!real_dev->ethtool_ops ||
+	    !real_dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
 	return real_dev->ethtool_ops->get_settings(real_dev, cmd);

--------------060507000306080402030401--
