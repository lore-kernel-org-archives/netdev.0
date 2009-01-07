From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/4] r6040: warn about MAC address being unset
Date: Wed, 7 Jan 2009 17:40:41 +0100
Message-ID: <200901071740.42130.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:62317 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZAGQr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:47:56 -0500
Received: by bwz14 with SMTP id 14so25811688bwz.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 08:47:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/4] r6040: warn about MAC address being unset

Some bootloader/BIOSes do not set the MAC
address, warn about that.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index a59efbd..ce619d3 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1127,6 +1127,11 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	adrp[1] = ioread16(ioaddr + MID_0M);
 	adrp[2] = ioread16(ioaddr + MID_0H);
 
+	/* Some bootloader/BIOSes do not initialize
+	 * MAC address, warn about that */
+	if (!(adrp[0] || adrp[1] || adrp[2]))
+		printk(KERN_WARNING DRV_NAME ": MAC address not initialized\n");
+
 	/* Link new device into r6040_root_dev */
 	lp->pdev = pdev;
 	lp->dev = dev;
