From: varkabhadram@gmail.com
Subject: [PATCH net-next v3 2/2] ethernet: realtek: use pci_device_id
Date: Wed, 23 Jul 2014 09:19:49 +0530
Message-ID: <1406087389-4436-3-git-send-email-varkabhadram@gmail.com>
References: <1406087389-4436-1-git-send-email-varkabhadram@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406087389-4436-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch use the struct pci_device_id instead of using macro
DEFINE_PCI_DEVICE_TABLE which is deprecated and should not be used.
And also moves these ids after probe and remove functionalities.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/realtek/8139cp.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index be101ca..75b1693 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -382,13 +382,6 @@ static int cp_get_eeprom(struct net_device *dev,
 static int cp_set_eeprom(struct net_device *dev,
 			 struct ethtool_eeprom *eeprom, u8 *data);
 
-static DEFINE_PCI_DEVICE_TABLE(cp_pci_tbl) = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	PCI_DEVICE_ID_REALTEK_8139), },
-	{ PCI_DEVICE(PCI_VENDOR_ID_TTTECH,	PCI_DEVICE_ID_TTTECH_MC322), },
-	{ },
-};
-MODULE_DEVICE_TABLE(pci, cp_pci_tbl);
-
 static struct {
 	const char str[ETH_GSTRING_LEN];
 } ethtool_stats_keys[] = {
@@ -2106,6 +2099,13 @@ static int cp_resume (struct pci_dev *pdev)
 }
 #endif /* CONFIG_PM */
 
+static const struct pci_device_id cp_pci_tbl[] = {
+        { PCI_DEVICE(PCI_VENDOR_ID_REALTEK,     PCI_DEVICE_ID_REALTEK_8139), },
+        { PCI_DEVICE(PCI_VENDOR_ID_TTTECH,      PCI_DEVICE_ID_TTTECH_MC322), },
+        { },
+};
+MODULE_DEVICE_TABLE(pci, cp_pci_tbl);
+
 static struct pci_driver cp_driver = {
 	.name         = DRV_NAME,
 	.id_table     = cp_pci_tbl,
-- 
1.7.9.5
