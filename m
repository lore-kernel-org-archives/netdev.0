From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 20/20] xen: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:25 -0700
Message-ID: <1302050665-10460-21-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
 <1302050665-10460-12-git-send-email-maheshb@google.com>
 <1302050665-10460-13-git-send-email-maheshb@google.com>
 <1302050665-10460-14-git-send-email-maheshb@google.com>
 <1302050665-10460-15-git-send-email-maheshb@google.com>
 <1302050665-10460-16-git-send-email-maheshb@google.com>
 <1302050665-10460-17-git-send-email-maheshb@google.com>
 <1302050665-10460-18-git-send-email-maheshb@google.com>
 <1302050665-10460-19-git-send-email-maheshb@google.com>
 <1302050665-10460-20-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28073 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab1DFAo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:56 -0400
In-Reply-To: <1302050665-10460-20-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/xen-netfront.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index db9a763..2b7e5b1 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -193,7 +193,7 @@ static void xennet_sysfs_delif(struct net_device *netdev);
 
 static int xennet_can_sg(struct net_device *dev)
 {
-	return dev->features & NETIF_F_SG;
+	return dev->legacy_features & NETIF_F_SG;
 }
 
 
@@ -1247,9 +1247,9 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	netdev->netdev_ops	= &xennet_netdev_ops;
 
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
-	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	netdev->legacy_features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 				  NETIF_F_GSO_ROBUST;
-	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
+	netdev->legacy_hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
 
 	/*
          * Assume that all hw features are available for now. This set
@@ -1257,7 +1257,7 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
          * xennet_connect() which is the earliest point where we can
          * negotiate with the backend regarding supported features.
          */
-	netdev->features |= netdev->hw_features;
+	netdev->legacy_features |= netdev->legacy_hw_features;
 
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
-- 
1.7.3.1

