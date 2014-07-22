From: varkabhadram@gmail.com
Subject: [PATCH net-next v2 2/2] ethernet: realtek: use pci_device_id
Date: Tue, 22 Jul 2014 12:50:22 +0530
Message-ID: <1406013622-27869-3-git-send-email-varkabhadram@gmail.com>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:51390 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaGVHWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 03:22:09 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so10966779pab.0
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 00:22:09 -0700 (PDT)
In-Reply-To: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch use the struct pci_device_id instead of using macro
DEFINE_PCI_DEVICE_TABLE which is deprecated and should not be used.
And also moves these ids after probe and remove functionalities.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/realtek/8139cp.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 9fb68b9..6873122 100644
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
