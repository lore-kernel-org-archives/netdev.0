From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] igb: remove ASPM L0s workaround
Date: Tue, 03 Mar 2009 18:03:35 -0800
Message-ID: <20090304020335.15176.89368.stgit@lost.foo-projects.org>
References: <20090304020308.15176.40527.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:45810
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752722AbZCDCDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 21:03:54 -0500
In-Reply-To: <20090304020308.15176.40527.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The L0s workaround should be moved into a pci quirk and so it is not
necessary in the driver.  This update removes the L0s workaround from the
igb driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 78558f8..1adc7d2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1126,11 +1126,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
-	struct pci_dev *us_dev;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int err, pci_using_dac, pos;
-	u16 eeprom_data = 0, state = 0;
+	int err, pci_using_dac;
+	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 
@@ -1156,27 +1155,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
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
 	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
 	                                   IORESOURCE_MEM),
 	                                   igb_driver_name);

