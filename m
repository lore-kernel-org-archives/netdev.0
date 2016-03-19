From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 1/2 net-next v3.16]r8169:  Disable latency timer on pci express
Date: Sat, 19 Mar 2016 15:10:26 +0200
Message-ID: <1458393027-1927-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:35359 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754514AbcCSNia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 09:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On pci express interface not support latency timer.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 61623e9..2594bbb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3757,8 +3757,8 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
 	}
-
-	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
+	if (!tp->pci_dev->pcie_cap)
+		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
 		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
-- 
2.1.4
