From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 6/10] bnx2x: Update vlan_features
Date: Tue, 21 Jul 2009 18:47:43 +0300
Message-ID: <1248191263.18195.49.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gerlitz <ogerlitz@Voltaire.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2395 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755470AbZGUPr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted by Or Gerlitz <ogerlitz@Voltaire.com>, the vlan_features was not
updated

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 18c3803..b404a9b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9310,9 +9310,17 @@ static int bnx2x_set_tso(struct net_device *dev, u32 data)
 	if (data) {
 		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 		dev->features |= NETIF_F_TSO6;
+#ifdef BCM_VLAN
+		dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->vlan_features |= NETIF_F_TSO6;
+#endif
 	} else {
 		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
 		dev->features &= ~NETIF_F_TSO6;
+#ifdef BCM_VLAN
+		dev->vlan_features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->vlan_features &= ~NETIF_F_TSO6;
+#endif
 	}

 	return 0;
@@ -11143,12 +11151,19 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->features |= NETIF_F_HW_CSUM;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
+	dev->features |= NETIF_F_TSO6;
 #ifdef BCM_VLAN
 	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 	bp->flags |= (HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
+
+	dev->vlan_features |= NETIF_F_SG;
+	dev->vlan_features |= NETIF_F_HW_CSUM;
+	if (bp->flags & USING_DAC_FLAG)
+		dev->vlan_features |= NETIF_F_HIGHDMA;
+	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
+	dev->vlan_features |= NETIF_F_TSO6;
 #endif
-	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
-	dev->features |= NETIF_F_TSO6;

 	return 0;

--
1.5.4.3




