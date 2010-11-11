From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 08/10] cxgb4vf: Advertise NETIF_F_TSO_ECN.
Date: Wed, 10 Nov 2010 18:04:10 -0800
Message-ID: <1289441052-4925-8-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18200 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274Ab0KKCEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:22 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advertise NETIF_F_TSO_ECN.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 2d09e83..15b14ef 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1536,14 +1536,19 @@ static void cxgb4vf_get_wol(struct net_device *dev,
 }
 
 /*
+ * TCP Segmentation Offload flags which we support.
+ */
+#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+
+/*
  * Set TCP Segmentation Offloading feature capabilities.
  */
 static int cxgb4vf_set_tso(struct net_device *dev, u32 tso)
 {
 	if (tso)
-		dev->features |= NETIF_F_TSO | NETIF_F_TSO6;
+		dev->features |= TSO_FLAGS;
 	else
-		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+		dev->features &= ~TSO_FLAGS;
 	return 0;
 }
 
@@ -2596,7 +2601,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		netif_carrier_off(netdev);
 		netdev->irq = pdev->irq;
 
-		netdev->features = (NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
+		netdev->features = (NETIF_F_SG | TSO_FLAGS |
 				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 				    NETIF_F_GRO);
-- 
1.7.0.4

