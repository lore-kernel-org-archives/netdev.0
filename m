From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH 2/2] pci: Add VPD quirk for Intel Ethernet devices
Date: Tue, 02 Jun 2015 10:04:19 -0700
Message-ID: <20150602170419.6252.84014.stgit@mdrustad-wks.jf.intel.com>
References: <20150602165706.6252.76253.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57130 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759317AbbFBREv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 13:04:51 -0400
In-Reply-To: <20150602165706.6252.76253.stgit@mdrustad-wks.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This quirk sets the PCI_DEV_FLAGS_VPD_REF_F0 flag on all Intel
Ethernet device functions other than function 0.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
---
 drivers/pci/quirks.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index c6dc1dfd25d5..9ddf6a533f4f 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1903,6 +1903,15 @@ static void quirk_netmos(struct pci_dev *dev)
 DECLARE_PCI_FIXUP_CLASS_HEADER(PCI_VENDOR_ID_NETMOS, PCI_ANY_ID,
 			 PCI_CLASS_COMMUNICATION_SERIAL, 8, quirk_netmos);
 
+static void quirk_f0_vpd_link(struct pci_dev *dev)
+{
+	if (!PCI_FUNC(dev->devfn))
+		return;
+	dev->dev_flags |= PCI_DEV_FLAGS_VPD_REF_F0;
+}
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID,
+			      PCI_CLASS_NETWORK_ETHERNET, 8, quirk_f0_vpd_link);
+
 static void quirk_e100_interrupt(struct pci_dev *dev)
 {
 	u16 command, pmcsr;
