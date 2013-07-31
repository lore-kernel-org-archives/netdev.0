From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] PCI: expose pcie_link_speed and pcix_bus_speed arrays
Date: Wed, 31 Jul 2013 02:59:30 -0700
Message-ID: <1375264777-13595-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43699 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759124Ab3GaJ7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:59:46 -0400
In-Reply-To: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

pcie_link_speed and pcix_bus_speed are arrays used by probe.c to correctly
convert lnksta register values into the pci_bus_speed enum. These static arrays
are useful outside probe for this purpose. This patch makes these defines into
conist arrays and exposes them with an extern header in drivers/pci/pci.h

-v2-
* move extern declarations to drivers/pci/pci.h

CC: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/pci/pci.h   | 3 +++
 drivers/pci/probe.c | 4 ++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index d1182c4..948d1a0 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -6,6 +6,9 @@
 #define PCI_CFG_SPACE_SIZE	256
 #define PCI_CFG_SPACE_EXP_SIZE	4096
 
+extern const unsigned char pcix_bus_speed[];
+extern const unsigned char pcie_link_speed[];
+
 /* Functions internal to the PCI core code */
 
 int pci_create_sysfs_dev_files(struct pci_dev *pdev);
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 46ada5c..496c5b0 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -513,7 +513,7 @@ static struct pci_host_bridge *pci_alloc_host_bridge(struct pci_bus *b)
 	return bridge;
 }
 
-static unsigned char pcix_bus_speed[] = {
+const unsigned char pcix_bus_speed[] = {
 	PCI_SPEED_UNKNOWN,		/* 0 */
 	PCI_SPEED_66MHz_PCIX,		/* 1 */
 	PCI_SPEED_100MHz_PCIX,		/* 2 */
@@ -532,7 +532,7 @@ static unsigned char pcix_bus_speed[] = {
 	PCI_SPEED_133MHz_PCIX_533	/* F */
 };
 
-static unsigned char pcie_link_speed[] = {
+const unsigned char pcie_link_speed[] = {
 	PCI_SPEED_UNKNOWN,		/* 0 */
 	PCIE_SPEED_2_5GT,		/* 1 */
 	PCIE_SPEED_5_0GT,		/* 2 */
-- 
1.7.11.7
