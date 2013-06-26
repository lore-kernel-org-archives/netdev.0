From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] e1000e: Remove duplicate assignment of default rx/tx ring size
Date: Wed, 26 Jun 2013 03:55:22 -0700
Message-ID: <1372244122-17664-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014Ab3FZKzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:31 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>

tx_ring/rx_ring size is assigned in function e1000_alloc_queues(), which is
called by e1000_sw_init() in the early stage of e1000_probe().

This patch just remove the duplicate assignment of this default ring size
value.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Da Yu Qiu <qiudayu@cn.ibm.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5475cf4..40e6232 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6725,10 +6725,6 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->hw.fc.current_mode = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
 
-	/* ring size defaults */
-	adapter->rx_ring->count = E1000_DEFAULT_RXD;
-	adapter->tx_ring->count = E1000_DEFAULT_TXD;
-
 	/* Initial Wake on LAN setting - If APM wake is enabled in
 	 * the EEPROM, enable the ACPI Magic Packet filter
 	 */
-- 
1.7.11.7
