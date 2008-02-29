From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: Add pcibios_enable_device() return value check
Date: Fri, 29 Feb 2008 11:09:31 +0100
Message-ID: <200802291109.31824.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:45463 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbYB2KLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 05:11:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

This patch has added pcibios_enable_device() return value check.

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/ssb/driver_pcicore.c linux/drivers/ssb/driver_pcicore.c
--- linux-orig/drivers/ssb/driver_pcicore.c	2008-02-29 09:39:39.355620210 +0900
+++ linux/drivers/ssb/driver_pcicore.c	2008-02-29 10:59:18.649231996 +0900
@@ -111,7 +111,10 @@ static void __init ssb_fixup_pcibridge(s
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
-	pcibios_enable_device(dev, ~0);
+	if (pcibios_enable_device(dev, ~0) < 0) {
+		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
+		return;
+	}
 
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);


-- 
Greetings Michael.
