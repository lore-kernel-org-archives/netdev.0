From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v3.16]r8169: Remove unsupported command on pci express
Date: Fri, 11 Mar 2016 17:06:33 +0200
Message-ID: <1457708793-1805-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-231-11.residential.rdsnet.ro ([5.14.231.11]:51941 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454AbcCKPaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 10:30:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On pci express not support latency timer.For more info read file /drivers/pci/pci.c
 on pcibios_set_master function.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 41750df..02aec96 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -753,6 +753,7 @@ struct rtl8169_private {
 	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
 	u16 cp_cmd;
+	bool pcie;
 
 	u16 event_slow;
 
@@ -3757,8 +3758,8 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
 	}
-
-	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
+	if (tp->pcie == 0)
+		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
 		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
@@ -7083,8 +7084,11 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	tp->mmio_addr = ioaddr;
 
-	if (!pci_is_pcie(pdev))
+	if (!pci_is_pcie(pdev)) {
 		netif_info(tp, probe, dev, "not PCI Express\n");
+		tp->pcie = 0;
+	} else
+		tp->pcie = 1;
 
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
-- 
2.1.4
