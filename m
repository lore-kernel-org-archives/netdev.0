From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] igb: use dev_printk instead of printk
Date: Mon, 17 Nov 2008 18:06:35 -0800
Message-ID: <20081118020635.10966.83143.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:53058 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752047AbYKRCGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 21:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Use dev_printk() instead of printk() to give a little more context
and use consistent format.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b1530be..b52626a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1019,10 +1019,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			state &= ~PCIE_LINK_STATE_L0S;
 			pci_write_config_word(us_dev, pos + PCI_EXP_LNKCTL,
 			                      state);
-			printk(KERN_INFO "Disabling ASPM L0s upstream switch "
-			       "port %x:%x.%x\n", us_dev->bus->number,
-			       PCI_SLOT(us_dev->devfn),
-			       PCI_FUNC(us_dev->devfn));
+			dev_info(&pdev->dev,
+				 "Disabling ASPM L0s upstream switch port %s\n",
+				 pci_name(us_dev));
 		}
 	default:
 		break;

