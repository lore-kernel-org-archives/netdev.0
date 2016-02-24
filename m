From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/20] igb: enable WoL for OEM devices regardless of EEPROM setting
Date: Tue, 23 Feb 2016 20:26:17 -0800
Message-ID: <1456287984-10459-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757411AbcBXE0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:34 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 0f7805c..cd3708b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2584,6 +2584,26 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
