From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] r6040: check PHY status when bringing interface up
Date: Wed, 7 Jan 2009 17:40:37 +0100
Message-ID: <200901071740.38060.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:56379 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbZAGQko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:40:44 -0500
Received: by fk-out-0910.google.com with SMTP id 18so4220704fkq.5
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 08:40:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4] r6040: check PHY status when bringing interface up

This patch makes the driver properly initialize the PHY
status if not correctly set by the bootloader/BIOS.
It prevents some boards to bring up the link on boot.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 3e685d7..a59efbd 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1107,6 +1107,10 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 		err = -EIO;
 		goto err_out_free_res;
 	}
+	/* If PHY status change register is still set to zero it means the
+	 * bootloader didn't initialize it */
+	if (ioread16(ioaddr + PHY_CC) == 0)
+		iowrite16(0x9f07, ioaddr + PHY_CC);
 
 	/* Init system & device */
 	lp->base = ioaddr;
