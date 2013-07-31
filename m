From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/15] PCI: move enum pcie_link_width into pci.h
Date: Wed, 31 Jul 2013 02:59:31 -0700
Message-ID: <1375264777-13595-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24036 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759162Ab3GaJ7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:59:46 -0400
In-Reply-To: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

pcie_link_width is the enum used to define the link width values for a pcie
device. This enum should not be contained solely in pci_hotplug.h, and this
patch moves it next to pci_bus_speed in pci.h

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/pci.h         | 13 +++++++++++++
 include/linux/pci_hotplug.h | 13 -------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 0fd1f15..a0bf22d 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -183,6 +183,19 @@ enum pci_bus_flags {
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
