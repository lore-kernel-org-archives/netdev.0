From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] pci: move enum pcie_link_width into pci.h
Date: Mon, 29 Jul 2013 05:52:05 -0700
Message-ID: <1375102331-23905-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22772 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783Ab3G2Mwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 08:52:31 -0400
In-Reply-To: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

pcie_link_width is the enum used to define the link width values for a pcie
device. This enum should not be contained solely in pci_hotplug.h, and this
patch moves it next to pci_bus_speed in pci.h

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/pci.h         | 13 +++++++++++++
 include/linux/pci_hotplug.h | 13 -------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 95ff993..fc2d1fb 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -186,6 +186,19 @@ enum pci_bus_flags {
 	PCI_BUS_FLAGS_NO_MMRBC = (__force pci_bus_flags_t) 2,
 };
 
+/* These values come from the PCI Express Spec */
+enum pcie_link_width {
+	PCIE_LNK_WIDTH_RESRV	= 0x00,
+	PCIE_LNK_X1		= 0x01,
+	PCIE_LNK_X2		= 0x02,
+	PCIE_LNK_X4		= 0x04,
+	PCIE_LNK_X8		= 0x08,
+	PCIE_LNK_X12		= 0x0C,
+	PCIE_LNK_X16		= 0x10,
+	PCIE_LNK_X32		= 0x20,
+	PCIE_LNK_WIDTH_UNKNOWN  = 0xFF,
+};
+
 /* Based on the PCI Hotplug Spec, but some values are made up by us */
 enum pci_bus_speed {
 	PCI_SPEED_33MHz			= 0x00,
diff --git a/include/linux/pci_hotplug.h b/include/linux/pci_hotplug.h
index 8db71dc..64e61e0 100644
--- a/include/linux/pci_hotplug.h
+++ b/include/linux/pci_hotplug.h
@@ -28,19 +28,6 @@
 #ifndef _PCI_HOTPLUG_H
 #define _PCI_HOTPLUG_H
 
-/* These values come from the PCI Express Spec */
-enum pcie_link_width {
-	PCIE_LNK_WIDTH_RESRV	= 0x00,
-	PCIE_LNK_X1		= 0x01,
-	PCIE_LNK_X2		= 0x02,
-	PCIE_LNK_X4		= 0x04,
-	PCIE_LNK_X8		= 0x08,
-	PCIE_LNK_X12		= 0x0C,
-	PCIE_LNK_X16		= 0x10,
-	PCIE_LNK_X32		= 0x20,
-	PCIE_LNK_WIDTH_UNKNOWN  = 0xFF,
-};
-
 /**
  * struct hotplug_slot_ops -the callbacks that the hotplug pci core can use
  * @owner: The module owner of this structure
-- 
1.7.11.7
