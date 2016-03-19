From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v31.16]r8169:  Consolided dev->features bedore adding netdev ethtool operations
Date: Sat, 19 Mar 2016 17:16:41 +0200
Message-ID: <1458400601-1666-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:36304 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbcCSPRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 11:17:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Consolide dev->features before adding netdev, ethtool operations
 on  driver-private

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c798349..a57b650 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3757,6 +3757,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
 	}
+
 	if (!tp->pci_dev->pcie_cap)
 		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 
@@ -7151,17 +7152,18 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 
+        /* don't enable SG, IP_CSUM and TSO by default - it might not work
+         * properly for all devices */
+        dev->features |= NETIF_F_RXCSUM |
+                NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
+
+
 	dev->netdev_ops = &rtl_netdev_ops;
 	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
-	/* don't enable SG, IP_CSUM and TSO by default - it might not work
-	 * properly for all devices */
-	dev->features |= NETIF_F_RXCSUM |
-		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
-
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_TX |
 		NETIF_F_HW_VLAN_CTAG_RX;
-- 
2.1.4
