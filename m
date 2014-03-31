From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] pci: Use designated initialization in PCI_VDEVICE
Date: Mon, 31 Mar 2014 14:58:39 -0700
Message-ID: <1396303119-16766-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57637 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbaCaV7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 17:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

By using designated initialization in PCI_VDEVICE, like other
similar macros, many "missing initializer" warnings that appear
when compiling with W=2 can be silenced.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/pci.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index fb57c89..49455f9 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -680,8 +680,8 @@ struct pci_driver {
 
 /**
  * PCI_VDEVICE - macro used to describe a specific pci device in short form
- * @vendor: the vendor name
- * @device: the 16 bit PCI Device ID
+ * @vend: the vendor name
+ * @dev: the 16 bit PCI Device ID
  *
  * This macro is used to create a struct pci_device_id that matches a
  * specific PCI device.  The subvendor, and subdevice fields will be set
@@ -689,9 +689,9 @@ struct pci_driver {
  * private data.
  */
 
-#define PCI_VDEVICE(vendor, device)		\
-	PCI_VENDOR_ID_##vendor, (device),	\
-	PCI_ANY_ID, PCI_ANY_ID, 0, 0
+#define PCI_VDEVICE(vend, dev) \
+	.vendor = PCI_VENDOR_ID_##vend, .device = (dev), \
+	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID, 0, 0
 
 /* these external functions are only available when PCI support is enabled */
 #ifdef CONFIG_PCI
-- 
1.9.0
