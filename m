From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH REPOST] PCI: Disable MSI for MCP55 on P5N32-E SLI
Date: Sun, 16 May 2010 02:28:49 +0100
Message-ID: <1273973329.2564.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-pci <linux-pci@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60974 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370Ab0EPB2x convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 May 2010 21:28:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported in <http://bugs.debian.org/552299>, MSI appears to be
broken for this on-board device.  We already have a quirk for the
P5N32-SLI Premium; extend it to cover both variants of the board.

Reported-by: Romain DEGEZ <romain.degez@smartjog.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: stable@kernel.org
---
 drivers/pci/quirks.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 27c0e6e..4807825 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -2218,15 +2218,16 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_SERVERWORKS,
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_8132_BRIDGE,
 			 ht_enable_msi_mapping);
 
-/* The P5N32-SLI Premium motherboard from Asus has a problem with msi
+/* The P5N32-SLI motherboards from Asus have a problem with msi
  * for the MCP55 NIC. It is not yet determined whether the msi problem
  * also affects other devices. As for now, turn off msi for this device.
  */
 static void __devinit nvenet_msi_disable(struct pci_dev *dev)
 {
-	if (dmi_name_in_vendors("P5N32-SLI PREMIUM")) {
+	if (dmi_name_in_vendors("P5N32-SLI PREMIUM") ||
+	    dmi_name_in_vendors("P5N32-E SLI")) {
 		dev_info(&dev->dev,
-			 "Disabling msi for MCP55 NIC on P5N32-SLI Premium\n");
+			 "Disabling msi for MCP55 NIC on P5N32-SLI\n");
 		dev->no_msi = 1;
 	}
 }
-- 
1.7.0.3



