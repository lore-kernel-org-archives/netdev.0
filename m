From: Roland Dreier <roland@kernel.org>
Subject: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Thu, 20 Jul 2017 14:41:01 -0700
Message-ID: <20170720214101.7449-1-roland@kernel.org>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland@purestorage.com>

Add one more variant of the 82599 plus the device IDs for X540 and X550
variants.  Intel has confirmed that none of these devices does peer-to-peer
between functions.  The X540 and X550 have added ACS capabilities in their
PCI config space, but the ACS control register is hard-wired to 0 for both
devices, so we still need the quirk for IOMMU grouping to allow assignment
of individual SR-IOV functions.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/pci/quirks.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 6967c6b4cf6b..b939db671326 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4335,12 +4335,33 @@ static const struct pci_dev_acs_enabled {
 	{ PCI_VENDOR_ID_INTEL, 0x1507, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x1514, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x151C, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x1528, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x1529, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x154A, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x152A, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x154D, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x154F, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x1551, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x1558, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x1560, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x1563, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AA, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AB, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AC, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AD, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AE, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15B0, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15AB, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C2, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C3, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C4, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C6, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C7, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15C8, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15CE, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15E4, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15E5, pci_quirk_mf_endpoint_acs },
+	{ PCI_VENDOR_ID_INTEL, 0x15D1, pci_quirk_mf_endpoint_acs },
 	/* 82580 */
 	{ PCI_VENDOR_ID_INTEL, 0x1509, pci_quirk_mf_endpoint_acs },
 	{ PCI_VENDOR_ID_INTEL, 0x150E, pci_quirk_mf_endpoint_acs },
-- 
2.11.0
