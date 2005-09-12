From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 10/16] ne2k-pci: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:57 -0400
Message-ID: <09122005104857.32349@bilbo.tuxdriver.com>
References: <09122005104856.32285@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751347AbVILPFZ@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104856.32285@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to ne2k-pci.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/ne2k-pci.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -372,6 +372,7 @@ static int __devinit ne2k_pci_init_one (
 		printk("%2.2X%s", SA_prom[i], i == 5 ? ".\n": ":");
 		dev->dev_addr[i] = SA_prom[i];
 	}
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	return 0;
 
@@ -637,6 +638,7 @@ static struct ethtool_ops ne2k_pci_ethto
 	.get_drvinfo		= ne2k_pci_get_drvinfo,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static void __devexit ne2k_pci_remove_one (struct pci_dev *pdev)
