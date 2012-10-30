From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] vlan: use IS_ENABLED()
Date: Tue, 30 Oct 2012 11:22:28 +0800
Message-ID: <1351567348-15229-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769Ab2J3DWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 23:22:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

#if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)

can be replaced by

#if IS_ENABLED(CONFIG_FOO)

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ee07072..30ee4bc 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -294,7 +294,7 @@ static void vlan_transfer_features(struct net_device *dev,
 	else
 		vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
 
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4024424..6da96d4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -409,7 +409,7 @@ static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
 	return err;
 }
 
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 static int vlan_dev_fcoe_ddp_setup(struct net_device *dev, u16 xid,
 				   struct scatterlist *sgl, unsigned int sgc)
 {
@@ -564,7 +564,7 @@ static int vlan_dev_init(struct net_device *dev)
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 	dev->fcoe_ddp_xid = real_dev->fcoe_ddp_xid;
 #endif
 
@@ -741,7 +741,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
 	.ndo_get_stats64	= vlan_dev_get_stats64,
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
 	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
