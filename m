From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next v2] Add ethtool -g support to 8139cp
Date: Fri,  7 Oct 2011 09:42:21 -0700 (PDT)
Message-ID: <20111007164221.90163290054F@tardy>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:14678 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab1JGQmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:42:23 -0400
Received: from g4t0018.houston.hp.com (g4t0018.houston.hp.com [16.234.32.27])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id 407011432E
	for <netdev@vger.kernel.org>; Fri,  7 Oct 2011 16:42:22 +0000 (UTC)
Received: from tardy (tardy.cup.hp.com [16.89.244.213])
	by g4t0018.houston.hp.com (Postfix) with ESMTP id 1C37410083
	for <netdev@vger.kernel.org>; Fri,  7 Oct 2011 16:42:22 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Add support for reporting ring sizes via ethtool -g to the 8139cp driver.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index c77d5af..5dcd5be 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1324,6 +1324,15 @@ static void cp_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info
 	strcpy (info->bus_info, pci_name(cp->pdev));
 }
 
+static void cp_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *ring)
+{
+	ring->rx_max_pending = CP_RX_RING_SIZE;
+	ring->tx_max_pending = CP_TX_RING_SIZE;
+	ring->rx_pending = CP_RX_RING_SIZE;
+	ring->tx_pending = CP_TX_RING_SIZE;
+}
+
 static int cp_get_regs_len(struct net_device *dev)
 {
 	return CP_REGS_SIZE;
@@ -1525,6 +1534,7 @@ static const struct ethtool_ops cp_ethtool_ops = {
 	.get_eeprom_len		= cp_get_eeprom_len,
 	.get_eeprom		= cp_get_eeprom,
 	.set_eeprom		= cp_set_eeprom,
+	.get_ringparam		= cp_get_ringparam,
 };
 
 static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
