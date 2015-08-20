From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169: Disable some bits on pcie
Date: Thu, 20 Aug 2015 13:12:33 +0300
Message-ID: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36741 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbHTKMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 06:12:46 -0400
Received: by wicja10 with SMTP id ja10so141229409wic.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 03:12:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable legacy interrupt on pci express interface use msi 
 disable some bits from pci express interface wich is not   need on this nic.


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6d16de3..b1fb54f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8164,6 +8164,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pci_is_pcie(pdev))
 		netif_info(tp, probe, dev, "not PCI Express\n");
 
+	if (pci_is_pcie(pdev))
+		pci_write_config_word(pdev, PCI_COMMAND, ~(PCI_COMMAND_FAST_BACK | PCI_COMMAND_WAIT |
+					PCI_COMMAND_VGA_PALETTE | PCI_COMMAND_INVALIDATE | PCI_COMMAND_SPECIAL));
+
+	if (pci_is_pcie(pdev))
+		pci_intx(pdev, 0);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
-- 
2.1.4
