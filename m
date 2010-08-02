From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 5/9] cxgb4: advertise NETIF_F_TSO_ECN
Date: Mon,  2 Aug 2010 16:19:20 -0700
Message-ID: <1280791164-14181-6-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
 <1280791164-14181-5-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15546 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJPTQ025635
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-5-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device supports TSO+ECN.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 47e8936..e80d4a5 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1808,12 +1808,14 @@ static int set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	return err;
 }
 
+#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+
 static int set_tso(struct net_device *dev, u32 value)
 {
 	if (value)
-		dev->features |= NETIF_F_TSO | NETIF_F_TSO6;
+		dev->features |= TSO_FLAGS;
 	else
-		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+		dev->features &= ~TSO_FLAGS;
 	return 0;
 }
 
@@ -3539,7 +3541,7 @@ static void free_some_resources(struct adapter *adapter)
 		t4_fw_bye(adapter, 0);
 }
 
-#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO | NETIF_F_TSO6 |\
+#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 
 static int __devinit init_one(struct pci_dev *pdev,
@@ -3645,7 +3647,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netif_tx_stop_all_queues(netdev);
 		netdev->irq = pdev->irq;
 
-		netdev->features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6;
+		netdev->features |= NETIF_F_SG | TSO_FLAGS;
 		netdev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 		netdev->features |= NETIF_F_GRO | NETIF_F_RXHASH | highdma;
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-- 
1.5.4

