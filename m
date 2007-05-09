From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 05/17] pci: advanced error reporting stub return values
Date: Tue, 08 May 2007 20:49:54 -0700
Message-ID: <20070509035028.751938921@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:58499 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033215AbXEIEEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:24 -0400
Cc: Greg KH <greg@kroah.com>
Cc: Tom Long Nguyen <tom.l.nguyen@intel.com>
Cc: Zhang Yanmin <yanmin.zhang@intel.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz
Content-Disposition: inline; filename=aer-fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stubs for advanced PCI error reporting are wrong. They don't
match the function return values. This breaks compilation for any
driver that tries to use these functions (that's the next sky2 patch).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2.orig/include/linux/aer.h	2007-05-08 20:36:21.000000000 -0700
+++ sky2/include/linux/aer.h	2007-05-08 20:38:04.000000000 -0700
@@ -14,10 +14,10 @@
 extern int pci_disable_pcie_error_reporting(struct pci_dev *dev);
 extern int pci_cleanup_aer_uncorrect_error_status(struct pci_dev *dev);
 #else
-#define pci_enable_pcie_error_reporting(dev)		do { } while (0)
-#define pci_find_aer_capability(dev)			do { } while (0)
-#define pci_disable_pcie_error_reporting(dev)		do { } while (0)
-#define pci_cleanup_aer_uncorrect_error_status(dev)	do { } while (0)
+#define pci_enable_pcie_error_reporting(dev)		(-EINVAL)
+#define pci_find_aer_capability(dev)			(0)
+#define pci_disable_pcie_error_reporting(dev)		(-EINVAL)
+#define pci_cleanup_aer_uncorrect_error_status(dev)	(-EINVAL)
 #endif
 
 #endif //_AER_H_

--

