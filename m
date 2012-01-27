From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] e1000e: convert final strncpy() to strlcpy()
Date: Thu, 26 Jan 2012 19:08:45 -0800
Message-ID: <1327633729-14086-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12673 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361Ab2A0DI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:56 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Convert the last instances of strncpy() to the preferred strlcpy().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 49b5ded..d6b451f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5947,7 +5947,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	ret_val = e1000_read_pba_string_generic(hw, pba_str,
 						E1000_PBANUM_LENGTH);
 	if (ret_val)
-		strncpy((char *)pba_str, "Unknown", sizeof(pba_str) - 1);
+		strlcpy((char *)pba_str, "Unknown", sizeof(pba_str));
 	e_info("MAC: %d, PHY: %d, PBA No: %s\n",
 	       hw->mac.type, hw->phy.type, pba_str);
 }
@@ -6139,7 +6139,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	e1000e_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo		= 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
-	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
+	strlcpy(netdev->name, pci_name(pdev), sizeof(netdev->name));
 
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
@@ -6321,7 +6321,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000e_get_hw_control(adapter);
 
-	strncpy(netdev->name, "eth%d", sizeof(netdev->name) - 1);
+	strlcpy(netdev->name, "eth%d", sizeof(netdev->name));
 	err = register_netdev(netdev);
 	if (err)
 		goto err_register;
-- 
1.7.7.6
