From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/11] e1000e: do not suggest the driver supports Wake-on-ARP
Date: Fri, 11 Mar 2011 03:06:29 -0800
Message-ID: <1299841590-30676-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38925 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754482Ab1CKLGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:53 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The driver doesn't support Wake-on-ARP, so don't advertise through ethtool
that it does.

Cleanup some coding style issues in the same functions.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8e276dc..07f09e9 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1799,8 +1799,7 @@ static void e1000_get_wol(struct net_device *netdev,
 		return;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
-	                 WAKE_BCAST | WAKE_MAGIC |
-	                 WAKE_PHY | WAKE_ARP;
+	    WAKE_BCAST | WAKE_MAGIC | WAKE_PHY;
 
 	/* apply any specific unsupported masks here */
 	if (adapter->flags & FLAG_NO_WAKE_UCAST) {
@@ -1821,19 +1820,16 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_MAGIC;
 	if (adapter->wol & E1000_WUFC_LNKC)
 		wol->wolopts |= WAKE_PHY;
-	if (adapter->wol & E1000_WUFC_ARP)
-		wol->wolopts |= WAKE_ARP;
 }
 
-static int e1000_set_wol(struct net_device *netdev,
-			 struct ethtool_wolinfo *wol)
+static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	if (!(adapter->flags & FLAG_HAS_WOL) ||
 	    !device_can_wakeup(&adapter->pdev->dev) ||
 	    (wol->wolopts & ~(WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
-	                      WAKE_MAGIC | WAKE_PHY | WAKE_ARP)))
+			      WAKE_MAGIC | WAKE_PHY)))
 		return -EOPNOTSUPP;
 
 	/* these settings will always override what we currently have */
@@ -1849,8 +1845,6 @@ static int e1000_set_wol(struct net_device *netdev,
 		adapter->wol |= E1000_WUFC_MAG;
 	if (wol->wolopts & WAKE_PHY)
 		adapter->wol |= E1000_WUFC_LNKC;
-	if (wol->wolopts & WAKE_ARP)
-		adapter->wol |= E1000_WUFC_ARP;
 
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
-- 
1.7.4

