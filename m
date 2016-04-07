From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] igb: allow setting MAC address on i211 using a device tree blob
Date: Wed,  6 Apr 2016 21:37:28 -0700
Message-ID: <1460003853-133949-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Holland <jotihojr@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7189 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbcDGEhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:36 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Holland <jotihojr@gmail.com>

The Intel i211 LOM PCIe Ethernet controllers' iNVM operates as an OTP
and has no external EEPROM interface [1]. The following allows the
driver to pickup the MAC address from a device tree blob when CONFIG_OF
has been enabled.

[1]
http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html

Signed-off-by: John Holland <jotihojr@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e40983c..ff0476c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -50,6 +50,7 @@
 #include <linux/aer.h>
 #include <linux/prefetch.h>
 #include <linux/pm_runtime.h>
+#include <linux/etherdevice.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
@@ -2442,9 +2443,11 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	/* copy the MAC address out of the NVM */
-	if (hw->mac.ops.read_mac_addr(hw))
-		dev_err(&pdev->dev, "NVM Read Error\n");
+	if (eth_platform_get_mac_address(&pdev->dev, hw->mac.addr)) {
+		/* copy the MAC address out of the NVM */
+		if (hw->mac.ops.read_mac_addr(hw))
+			dev_err(&pdev->dev, "NVM Read Error\n");
+	}
 
 	memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
 
-- 
2.5.5
