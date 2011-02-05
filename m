From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 2/5] enic: Bug Fix: Fix return values of
	enic_add/del_station_addr routines
Date: Fri, 04 Feb 2011 18:17:10 -0800
Message-ID: <20110205021710.8510.44761.stgit@savbu-pc100.cisco.com>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:31097 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab1BECRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 21:17:11 -0500
In-Reply-To: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Fix enic_add/del_station_addr routines to return appropriate error code when an invalid address is added or deleted.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h     |    2 +-
 drivers/net/enic/enic_dev.c |   26 ++++++++++++++------------
 2 files changed, 15 insertions(+), 13 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 1385a60..f38ad63 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.3"
+#define DRV_VERSION		"2.1.1.4"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_dev.c b/drivers/net/enic/enic_dev.c
index a52dbd2..3826266 100644
--- a/drivers/net/enic/enic_dev.c
+++ b/drivers/net/enic/enic_dev.c
@@ -49,26 +49,28 @@ int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats)
 
 int enic_dev_add_station_addr(struct enic *enic)
 {
-	int err = 0;
+	int err;
+
+	if (!is_valid_ether_addr(enic->netdev->dev_addr))
+		return -EADDRNOTAVAIL;
 
-	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
-		spin_lock(&enic->devcmd_lock);
-		err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
-		spin_unlock(&enic->devcmd_lock);
-	}
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
+	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }
 
 int enic_dev_del_station_addr(struct enic *enic)
 {
-	int err = 0;
+	int err;
+
+	if (!is_valid_ether_addr(enic->netdev->dev_addr))
+		return -EADDRNOTAVAIL;
 
-	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
-		spin_lock(&enic->devcmd_lock);
-		err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
-		spin_unlock(&enic->devcmd_lock);
-	}
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
+	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }

