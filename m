From: varkabhadram@gmail.com
Subject: [PATCH net-next 5/8] ethernet: amd: move pci device ids
Date: Fri, 11 Jul 2014 13:05:07 +0530
Message-ID: <1405064110-22579-6-git-send-email-varkabhadram@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

Normally any device ids will be above the corresponding device driver
structure. This patch moves the pci device ids and MODULE_DEVICE_TABLE()
above the pci driver structure.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index e2fb9e2..c47019d 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -101,7 +101,6 @@ Revision History:
 MODULE_AUTHOR("Advanced Micro Devices, Inc.");
 MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version "MODULE_VERS);
 MODULE_LICENSE("GPL");
-MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 module_param_array(speed_duplex, int, NULL, 0);
 MODULE_PARM_DESC(speed_duplex, "Set device speed and duplex modes, 0: Auto Negotiate, 1: 10Mbps Half Duplex, 2: 10Mbps Full Duplex, 3: 100Mbps Half Duplex, 4: 100Mbps Full Duplex");
 module_param_array(coalesce, bool, NULL, 0);
@@ -109,14 +108,6 @@ MODULE_PARM_DESC(coalesce, "Enable or Disable interrupt coalescing, 1: Enable, 0
 module_param_array(dynamic_ipg, bool, NULL, 0);
 MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disable");
 
-static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
-
-	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
-	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ 0, }
-
-};
-
 /* This function will read the PHY registers. */
 static int amd8111e_read_phy(struct amd8111e_priv* lp, int phy_id, int reg, u32* val)
 {
@@ -1953,6 +1944,13 @@ static void amd8111e_remove_one(struct pci_dev *pdev)
 	}
 }
 
+static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
+	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
+
 static struct pci_driver amd8111e_driver = {
 	.name   	= MODULE_NAME,
 	.id_table	= amd8111e_pci_tbl,
-- 
1.7.9.5
