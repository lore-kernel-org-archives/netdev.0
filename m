From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169:  On RTL 8101 series bit SYSErr is reserved.
Date: Mon, 24 Aug 2015 21:12:53 +0300
Message-ID: <1440439973-7400-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34788 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbbHXSNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 14:13:07 -0400
Received: by widdq5 with SMTP id dq5so58064719wid.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 11:13:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On RTL 8101 series bit SYSErr is reserved.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5693e65..32d2072 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8256,6 +8256,14 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));*/
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_13:
+	case RTL_GIGA_MAC_VER_16:
+		pci_write_config_word(pdev, PCI_COMMAND, ~PCI_COMMAND_SERR); 
+		break;
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_35:
 	case RTL_GIGA_MAC_VER_36:
-- 
2.1.4
