From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag, PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Sat, 5 Aug 2017 15:15:10 +0800
Message-ID: <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Casey Leedom <leedom@chelsio.com>

The patch adds a new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING to indicate that
Relaxed Ordering (RO) attribute should not be used for Transaction Layer
Packets (TLP) targetted towards these affected root complexes. Current list
of affected parts include some Intel Xeon processors root complex which suffers from
flow control credits that result in performance issues. On these affected
parts RO can still be used for peer-2-peer traffic. AMD A1100 ARM ("SEATTLE")
Root complexes don't obey PCIe 3.0 ordering rules, hence could lead to
data-corruption.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Ashok Raj <ashok.raj@intel.com>
---
 drivers/pci/quirks.c | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h  |  2 ++
 2 files changed, 90 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 6967c6b..5c9e125 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4016,6 +4016,94 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
 			      quirk_tw686x_class);
 
 /*
+ * Some devices have problems with Transaction Layer Packets with the Relaxed
+ * Ordering Attribute set.  Such devices should mark themselves and other
+ * Device Drivers should check before sending TLPs with RO set.
+ */
+static void quirk_relaxedordering_disable(struct pci_dev *dev)
+{
+	dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
+}
+
+/*
+ * Intel Xeon processors based on Broadwell/Haswell microarchitecture Root
+ * Complex has a Flow Control Credit issue which can cause performance
+ * problems with Upstream Transaction Layer Packets with Relaxed Ordering set.
+ */
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f01, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f02, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f03, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f04, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f05, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f06, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f07, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f08, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f09, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f0a, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f0b, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f0c, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f0d, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f0e, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f01, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f02, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f03, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f04, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f05, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f06, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f07, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f08, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f09, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f0a, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f0b, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f0c, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f0d, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x2f0e, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+
+/*
+ * The AMD ARM A1100 (AKA "SEATTLE") SoC has a bug in its PCIe Root Complex
+ * where Upstream Transaction Layer Packets with the Relaxed Ordering
+ * Attribute clear are allowed to bypass earlier TLPs with Relaxed Ordering
+ * set.  This is a violation of the PCIe 3.0 Transaction Ordering Rules
+ * outlined in Section 2.4.1 (PCI Express(r) Base Specification Revision 3.0
+ * November 10, 2010).  As a result, on this platform we can't use Relaxed
+ * Ordering for Upstream TLPs.
+ */
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a00, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a01, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a02, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+
+/*
  * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
  * values for the Attribute as were supplied in the header of the
  * corresponding Request, except as explicitly allowed when IDO is used."
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 4869e66..412ec1c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -188,6 +188,8 @@ enum pci_dev_flags {
 	 * the direct_complete optimization.
 	 */
 	PCI_DEV_FLAGS_NEEDS_RESUME = (__force pci_dev_flags_t) (1 << 11),
+	/* Don't use Relaxed Ordering for TLPs directed at this device */
+	PCI_DEV_FLAGS_NO_RELAXED_ORDERING = (__force pci_dev_flags_t) (1 << 12),
 };
 
 enum pci_irq_reroute_variant {
-- 
1.8.3.1
