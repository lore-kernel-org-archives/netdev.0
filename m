From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/08]: vlan: ethtool ->get_flags support
Date: Wed,  9 Jul 2008 14:09:52 +0200 (MEST)
Message-ID: <20080709120952.11669.81887.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbYGIMJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:53 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: ethtool ->get_flags support

Allow to query LRO settings of underlying device when VLAN RX
acceleration is used.

Suggested by Ben Hutchings <bhutchings@solarflare.com>.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b7ed86e1c799275adf2d36b8801abe91ffe66aec
tree 7374b192f8b6b88df2e2a9f6d92764423a14df9f
parent 1e655d00db6762d05f8d99912a70f58fe4c4f977
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:00 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:00 +0200

 net/8021q/vlan_dev.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8efa399..48617c1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -709,9 +709,22 @@ static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
 	return real_dev->ethtool_ops->get_rx_csum(real_dev);
 }
 
+static u32 vlan_ethtool_get_flags(struct net_device *dev)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct net_device *real_dev = vlan->real_dev;
+
+	if (!(real_dev->features & NETIF_F_HW_VLAN_RX) ||
+	    real_dev->ethtool_ops == NULL ||
+	    real_dev->ethtool_ops->get_flags == NULL)
+		return 0;
+	return real_dev->ethtool_ops->get_flags(real_dev);
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= vlan_ethtool_get_rx_csum,
+	.get_flags		= vlan_ethtool_get_flags,
 };
 
 void vlan_setup(struct net_device *dev)
