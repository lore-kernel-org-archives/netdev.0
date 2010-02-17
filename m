From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/18] igb: add support for wake-on-link
Date: Wed, 17 Feb 2010 03:01:01 -0800
Message-ID: <20100217110100.17723.30799.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:53017 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753435Ab0BQLBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:01:19 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This adds support for wake-on-link/phy activity to the ethtool
interface.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index f771a6c..145a8eb 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1812,7 +1812,8 @@ static void igb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
-			 WAKE_BCAST | WAKE_MAGIC;
+	                 WAKE_BCAST | WAKE_MAGIC |
+	                 WAKE_PHY;
 	wol->wolopts = 0;
 
 	/* this function will set ->supported = 0 and return 1 if wol is not
@@ -1835,15 +1836,15 @@ static void igb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & E1000_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
-
-	return;
+	if (adapter->wol & E1000_WUFC_LNKC)
+		wol->wolopts |= WAKE_PHY;
 }
 
 static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 
 	if (igb_wol_exclusion(adapter, wol) ||
@@ -1861,6 +1862,8 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 		adapter->wol |= E1000_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
+	if (wol->wolopts & WAKE_PHY)
+		adapter->wol |= E1000_WUFC_LNKC;
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	return 0;

