From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v11 2/5] PCI: Disable Relaxed Ordering for some Intel processors
Date: Tue, 15 Aug 2017 11:23:24 +0800
Message-ID: <1502767407-6812-3-git-send-email-dingtianhong@huawei.com>
References: <1502767407-6812-1-git-send-email-dingtianhong@huawei.com>
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1502767407-6812-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the Intel spec section 3.9.1 said:

    3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
          and Toward MMIO Regions (P2P)

    In order to maximize performance for PCIe devices in the processors
    listed in Table 3-6 below, the soft- ware should determine whether the
    accesses are toward coherent memory (system memory) or toward MMIO
    regions (P2P access to other devices). If the access is toward MMIO
    region, then software can command HW to set the RO bit in the TLP
    header, as this would allow hardware to achieve maximum throughput for
    these types of accesses. For accesses toward coherent memory, software
    can command HW to clear the RO bit in the TLP header (no RO), as this
    would allow hardware to achieve maximum throughput for these types of
    accesses.

    Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
               PCIe Performance

    Processor                            CPU RP Device IDs

    Intel Xeon processors based on       6F01H-6F0EH
    Broadwell microarchitecture

    Intel Xeon processors based on       2F01H-2F0EH
    Haswell microarchitecture

It means some Intel processors has performance issue when use the Relaxed
Ordering Attribute, so disable Relaxed Ordering for these root port.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Ashok Raj <ashok.raj@intel.com>
---
 drivers/pci/quirks.c | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 61b59bf..1272f7e 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4027,6 +4027,68 @@ static void quirk_relaxedordering_disable(struct pci_dev *dev)
 }
 
 /*
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
  * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
  * values for the Attribute as were supplied in the header of the
  * corresponding Request, except as explicitly allowed when IDO is used."
-- 
1.8.3.1
