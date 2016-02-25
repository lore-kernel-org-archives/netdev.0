From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] igb: enable WoL for OEM devices regardless of EEPROM setting
Date: Wed, 24 Feb 2016 18:14:55 -0800
Message-ID: <1456366502-132841-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58931 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759361AbcBYC0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:02 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Override EEPROM settings for specific OEM devices.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1aa0180..4238f3e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2538,6 +2538,26 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->wol = 0;
 	}
 
+	/* Some vendors want the ability to Use the EEPROM setting as
+	 * enable/disable only, and not for capability
+	 */
+	if (((hw->mac.type == e1000_i350) ||
+	     (hw->mac.type == e1000_i354)) &&
+	    (pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)) {
+		adapter->flags |= IGB_FLAG_WOL_SUPPORTED;
+		adapter->wol = 0;
+	}
+	if (hw->mac.type == e1000_i350) {
+		if (((pdev->subsystem_device == 0x5001) ||
+		     (pdev->subsystem_device == 0x5002)) &&
+				(hw->bus.func == 0)) {
+			adapter->flags |= IGB_FLAG_WOL_SUPPORTED;
+			adapter->wol = 0;
+		}
+		if (pdev->subsystem_device == 0x1F52)
+			adapter->flags |= IGB_FLAG_WOL_SUPPORTED;
+	}
+
 	device_set_wakeup_enable(&adapter->pdev->dev,
 				 adapter->flags & IGB_FLAG_WOL_SUPPORTED);
 
-- 
2.5.0
