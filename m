From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] r6040: fix wrong logic in mdio code
Date: Fri, 19 Dec 2008 11:02:05 +0100
Message-ID: <200812191102.05810.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Joe Chou <Joe.Chou@rdc.com.tw>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:49589 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbYLSKCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 05:02:09 -0500
Received: by mu-out-0910.google.com with SMTP id g7so402099muf.1
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 02:02:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David, Jeff,

Those patches should be applied to -stable as well.
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] r6040: fix wrong logic in mdio code

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] r6040: fix wrong logic in mdio code

This patch fixes a reverse logic in the MDIO code.

Signed-off-by: Joe Chou <Joe.Chou@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 34fe7ef..c2e8ac1 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -214,7 +214,7 @@ static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 	/* Wait for the read bit to be cleared */
 	while (limit--) {
 		cmd = ioread16(ioaddr + MMDIO);
-		if (cmd & MDIO_READ)
+		if (!(cmd & MDIO_READ))
 			break;
 	}
 
@@ -233,7 +233,7 @@ static void r6040_phy_write(void __iomem *ioaddr, int phy_addr, int reg, u16 val
 	/* Wait for the write bit to be cleared */
 	while (limit--) {
 		cmd = ioread16(ioaddr + MMDIO);
-		if (cmd & MDIO_WRITE)
+		if (!(cmd & MDIO_WRITE))
 			break;
 	}
 }
