From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169:Avoid to use I/O Space access on new design and others
Date: Thu, 20 Aug 2015 15:28:32 +0300
Message-ID: <1440073712-26826-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34871 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbHTM2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 08:28:45 -0400
Received: by wicne3 with SMTP id ne3so144877588wic.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 05:28:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid to use on pci express interface I/O Space access   
 and do not enable Bus Master is set on BIOS.   Warning: Do not apply this
 patch must   apply previously patch  first.
To: netdev@vger.kernel.org

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b1fb54f..6cd7226 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8171,6 +8171,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_is_pcie(pdev))
 		pci_intx(pdev, 0);
 
+	if (pci_is_pcie(pdev))
+		pci_write_config_word(pdev, PCI_COMMAND, ~PCI_COMMAND_IO);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
@@ -8183,8 +8186,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
-
-	pci_set_master(pdev);
+	if (!pci_is_pcie(pdev))
+	 	pci_set_master(pdev);
 
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
-- 
2.1.4
