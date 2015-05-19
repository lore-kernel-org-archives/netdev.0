From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH] pci: Limit VPD reads for all Intel Ethernet devices
Date: Mon, 18 May 2015 17:00:42 -0700
Message-ID: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To save boot time and some memory, limit VPD size to the maximum
possible for all Intel Ethernet devices that have VPD, which is 1K.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/pci/quirks.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index c6dc1dfd25d5..4fabbeda964a 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1903,12 +1903,15 @@ static void quirk_netmos(struct pci_dev *dev)
 DECLARE_PCI_FIXUP_CLASS_HEADER(PCI_VENDOR_ID_NETMOS, PCI_ANY_ID,
 			 PCI_CLASS_COMMUNICATION_SERIAL, 8, quirk_netmos);
 
-static void quirk_e100_interrupt(struct pci_dev *dev)
+static void quirk_intel_enet(struct pci_dev *dev)
 {
 	u16 command, pmcsr;
 	u8 __iomem *csr;
 	u8 cmd_hi;
 
+	if (dev->vpd)
+		dev->vpd->len = 0x400;
+
 	switch (dev->device) {
 	/* PCI IDs taken from drivers/net/e100.c */
 	case 0x1029:
@@ -1967,7 +1970,7 @@ static void quirk_e100_interrupt(struct pci_dev *dev)
 	iounmap(csr);
 }
 DECLARE_PCI_FIXUP_CLASS_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
-			PCI_CLASS_NETWORK_ETHERNET, 8, quirk_e100_interrupt);
+			      PCI_CLASS_NETWORK_ETHERNET, 8, quirk_intel_enet);
 
 /*
  * The 82575 and 82598 may experience data corruption issues when transitioning
