From: varkabhadram@gmail.com
Subject: [PATCH net-next 2/2] ethernet: realtek: use pci_device_id
Date: Tue, 22 Jul 2014 11:28:48 +0530
Message-ID: <1406008728-22604-3-git-send-email-varkabhadram@gmail.com>
References: <1406008728-22604-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:61171 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbaGVGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 02:00:24 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so11162680pab.26
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 23:00:24 -0700 (PDT)
In-Reply-To: <1406008728-22604-1-git-send-email-varkabhadram@gmail.com>
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
index 9025fba..a2a2ac6 100644
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
@@ -2110,6 +2103,13 @@ static int cp_resume (struct pci_dev *pdev)
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
