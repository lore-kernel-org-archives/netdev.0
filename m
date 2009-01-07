From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] vlan: add neigh_setup
Date: Wed, 07 Jan 2009 13:15:51 +0100
Message-ID: <20090107121659.385897000@de.ibm.com>
References: <20090107121550.878339000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:48071 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784AbZAGMRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:17:53 -0500
Content-Disposition: inline; filename=vlan_neigh_setup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case the real device has a neigh_setup function, this
neigh_setup function should be used for the vlan device.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/8021q/vlan_dev.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: git_linus/net/8021q/vlan_dev.c
===================================================================
--- git_linus.orig/net/8021q/vlan_dev.c
+++ git_linus/net/8021q/vlan_dev.c
@@ -546,6 +546,18 @@ static int vlan_dev_ioctl(struct net_dev
 	return err;
 }
 
+static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int err = 0;
+
+	if (netif_device_present(real_dev) && ops->ndo_neigh_setup)
+		err = ops->ndo_neigh_setup(dev, pa);
+
+	return err;
+}
+
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
@@ -713,6 +725,7 @@ static const struct net_device_ops vlan_
 	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
+	.ndo_neigh_setup	= vlan_dev_neigh_setup,
 };
 
 static const struct net_device_ops vlan_netdev_accel_ops = {
@@ -728,6 +741,7 @@ static const struct net_device_ops vlan_
 	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
+	.ndo_neigh_setup	= vlan_dev_neigh_setup,
 };
 
 void vlan_setup(struct net_device *dev)

-- 
