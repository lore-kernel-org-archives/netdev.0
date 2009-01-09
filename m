From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] r6040: generate random ethernet MAC address when not initialized
Date: Fri, 9 Jan 2009 02:04:45 +0100
Message-ID: <200901090204.45766.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:32932 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759715AbZAIBEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 20:04:51 -0500
Received: by bwz14 with SMTP id 14so28273359bwz.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 17:04:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] r6040: generate random ethernet MAC address when not initialized

This patch makes the ethernet driver assign a random ethernet
MAC address when the bootloader does not set it.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6b8bc6d..21d830b 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1138,8 +1138,10 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	/* Some bootloader/BIOSes do not initialize
 	 * MAC address, warn about that */
-	if (!(adrp[0] || adrp[1] || adrp[2]))
-		printk(KERN_WARNING DRV_NAME ": MAC address not initialized\n");
+	if (!(adrp[0] || adrp[1] || adrp[2])) {
+		printk(KERN_WARNING DRV_NAME ": MAC address not initialized, generating random\n");
+		random_ether_addr(dev->dev_addr);
+	}
 
 	/* Link new device into r6040_root_dev */
 	lp->pdev = pdev;
