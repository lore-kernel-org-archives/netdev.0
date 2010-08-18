From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 1/2] s2io: remove lro parameter
Date: Wed, 18 Aug 2010 03:51:09 -0400
Message-ID: <20100818075530.5926.67960.sendpatchset@localhost.localdomain>
Cc: bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com,
	sgruszka@redhat.com, Amerigo Wang <amwang@redhat.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15102 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903Ab0HRHvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 03:51:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As suggested by David, this parameter can die, we can use ethtool
to turn LRO on/off. Compile tests only.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 18bc5b7..b981fa9 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -496,8 +496,6 @@ S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 2);
 /* Large receive offload feature */
-static unsigned int lro_enable = 1;
-module_param_named(lro, lro_enable, uint, 0);
 
 /* Max pkts to be aggregated by LRO at one time. If not specified,
  * aggregation happens until we hit max IP pkt size(64K)
@@ -6735,13 +6733,10 @@ static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
 		return -EINVAL;
 
 	if (data & ETH_FLAG_LRO) {
-		if (lro_enable) {
-			if (!(dev->features & NETIF_F_LRO)) {
-				dev->features |= NETIF_F_LRO;
-				changed = 1;
-			}
-		} else
-			rc = -EINVAL;
+		if (!(dev->features & NETIF_F_LRO)) {
+			dev->features |= NETIF_F_LRO;
+			changed = 1;
+		}
 	} else if (dev->features & NETIF_F_LRO) {
 		dev->features &= ~NETIF_F_LRO;
 		changed = 1;
@@ -7911,7 +7906,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	else
 		sp->device_type = XFRAME_I_DEVICE;
 
-	sp->lro = lro_enable;
+	sp->lro = 1;
 
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
@@ -8047,8 +8042,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	dev->netdev_ops = &s2io_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	if (lro_enable)
-		dev->features |= NETIF_F_LRO;
+	dev->features |= NETIF_F_LRO;
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == true)
 		dev->features |= NETIF_F_HIGHDMA;
