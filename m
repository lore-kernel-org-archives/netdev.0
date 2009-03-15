From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: remove ASPM L0s workaround
Date: Sat, 14 Mar 2009 18:38:52 -0700
Message-ID: <20090315013846.23201.71757.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:60282 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbZCOBjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 21:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The L0s workaround should be moved into a pci quirk and so it is not
necessary in the driver.  This update removes the L0s workaround from the
igb driver.

This was the second half of the PCI quirk patch that Matthew Wilcox did
not pick up when he picked up the quirk patch.

This patch applies to the net-2.6 tree. :)

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a50db53..9dd13ad 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1023,11 +1023,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
-	struct pci_dev *us_dev;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int i, err, pci_using_dac, pos;
-	u16 eeprom_data = 0, state = 0;
+	int i, err, pci_using_dac;
+	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 	int bars, need_ioport;
@@ -1062,27 +1061,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		}
 	}
 
-	/* 82575 requires that the pci-e link partner disable the L0s state */
-	switch (pdev->device) {
-	case E1000_DEV_ID_82575EB_COPPER:
-	case E1000_DEV_ID_82575EB_FIBER_SERDES:
-	case E1000_DEV_ID_82575GB_QUAD_COPPER:
-		us_dev = pdev->bus->self;
-		pos = pci_find_capability(us_dev, PCI_CAP_ID_EXP);
-		if (pos) {
-			pci_read_config_word(us_dev, pos + PCI_EXP_LNKCTL,
-			                     &state);
-			state &= ~PCIE_LINK_STATE_L0S;
-			pci_write_config_word(us_dev, pos + PCI_EXP_LNKCTL,
-			                      state);
-			dev_info(&pdev->dev,
-				 "Disabling ASPM L0s upstream switch port %s\n",
-				 pci_name(us_dev));
-		}
-	default:
-		break;
-	}
-
 	err = pci_request_selected_regions(pdev, bars, igb_driver_name);
 	if (err)
 		goto err_pci_reg;

