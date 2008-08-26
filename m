From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 09/13] ixgbe: should not use HW_CSUM,
	should use IP* flags
Date: Tue, 26 Aug 2008 04:27:18 -0700
Message-ID: <20080826112718.15787.29008.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:39276 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbYHZL1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:19 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099820rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:19 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

as mentioned by Herbert, our hardware supports IP offloads, not full
checksum offloads for any protocol in existence (even though the
hardware just provides generic csum support over any range of bytes)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c    |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3efe5dd..61c000e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -233,15 +233,15 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
 
 static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 {
-	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+	return (netdev->features & NETIF_F_IP_CSUM) != 0;
 }
 
 static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
-		netdev->features |= NETIF_F_HW_CSUM;
+		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 	else
-		netdev->features &= ~NETIF_F_HW_CSUM;
+		netdev->features &= ~NETIF_F_IP_CSUM;
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b578099..b6973ee 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3593,7 +3593,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_HW_CSUM |
+			   NETIF_F_IP_CSUM |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
@@ -3604,7 +3604,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_IP_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)

