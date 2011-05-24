From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/2] net: add passthrough ethtool commands for get/set flags to vlan dev
Date: Tue, 24 May 2011 13:15:14 -0400
Message-ID: <1306257314-3925-3-git-send-email-nhorman@tuxdriver.com>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55852 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab1EXRPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:15:32 -0400
In-Reply-To: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool command to the vlan driver so that when dev_disable_lro is called on
a vlan device, the disablement can be correctly passed down to the underlying
hardware

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net
---
 net/8021q/vlan_dev.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f247f5b..611839b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -648,10 +648,24 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 	return stats;
 }
 
+static u32 vlan_ethtool_get_flags (struct net_device *vdev)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(vdev);
+	return dev_ethtool_get_flags(vlan->real_dev);
+}
+
+static int vlan_ethtool_set_flags(struct net_device *vdev, u32 flags)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(vdev);
+	return dev_ethtool_set_flags(vlan->real_dev, flags);
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_flags		= vlan_ethtool_get_flags,
+	.set_flags		= vlan_ethtool_set_flags,
 };
 
 static const struct net_device_ops vlan_netdev_ops = {
-- 
1.7.5.1

