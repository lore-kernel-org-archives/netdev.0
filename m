From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] r8169: use pci_dev->subsystem_{vendor|device}
Date: Fri, 22 Jul 2011 19:37:24 +0400
Message-ID: <201107221937.24383.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:60941 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754524Ab1GVPjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 11:39:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver reads PCI subsystem IDs from the PCI configuration registers while
they are already stored by the PCI subsystem in the 'subsystem_{vendor|device}'
fields of 'struct pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/net/r8169.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/r8169.c
===================================================================
--- linux-2.6.orig/drivers/net/r8169.c
+++ linux-2.6/drivers/net/r8169.c
@@ -1982,12 +1982,9 @@ static void rtl8169sb_hw_phy_config(stru
 static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp)
 {
 	struct pci_dev *pdev = tp->pci_dev;
-	u16 vendor_id, device_id;
 
-	pci_read_config_word(pdev, PCI_SUBSYSTEM_VENDOR_ID, &vendor_id);
-	pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &device_id);
-
-	if ((vendor_id != PCI_VENDOR_ID_GIGABYTE) || (device_id != 0xe000))
+	if ((pdev->subsystem_vendor != PCI_VENDOR_ID_GIGABYTE) ||
+	    (pdev->subsystem_device != 0xe000))
 		return;
 
 	rtl_writephy(tp, 0x1f, 0x0001);
