From: Patrick McHardy <kaber@trash.net>
Subject: vlan 03/07: Add ethtool support
Date: Mon,  7 Jul 2008 14:36:02 +0200 (MEST)
Message-ID: <20080707123601.23947.96915.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59276 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbYGGMgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:04 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Add ethtool support

Add ethtool support for querying the device for offload settings.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0dba2d1f208d01290f0ea2d19a201f06da80dded
tree 568a86a3ccd0e587675607caa2f5d66fd526eaa3
parent 5d835c9df8f14434867d206073316f771cfaac48
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:43 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:43 +0200

 net/8021q/vlan_dev.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 88f318a..722697d 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -28,6 +28,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <net/datalink.h>
 #include <net/p8022.h>
 #include <net/arp.h>
@@ -716,6 +717,22 @@ static void vlan_dev_uninit(struct net_device *dev)
 	}
 }
 
+static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct net_device *real_dev = vlan->real_dev;
+
+	if (real_dev->ethtool_ops == NULL ||
+	    real_dev->ethtool_ops->get_rx_csum == NULL)
+		return 0;
+	return real_dev->ethtool_ops->get_rx_csum(real_dev);
+}
+
+static const struct ethtool_ops vlan_ethtool_ops = {
+	.get_link		= ethtool_op_get_link,
+	.get_rx_csum		= vlan_ethtool_get_rx_csum,
+};
+
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -734,6 +751,7 @@ void vlan_setup(struct net_device *dev)
 	dev->change_rx_flags	= vlan_dev_change_rx_flags;
 	dev->do_ioctl		= vlan_dev_ioctl;
 	dev->destructor		= free_netdev;
+	dev->ethtool_ops	= &vlan_ethtool_ops;
 
 	memset(dev->broadcast, 0, ETH_ALEN);
 }
