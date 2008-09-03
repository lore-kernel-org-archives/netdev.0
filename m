From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH resend] r6040: fix bad usage of udelay
Date: Wed, 3 Sep 2008 16:50:03 +0200
Message-ID: <200809031650.03513.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:52963 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbYICOv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:51:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois, Jeff,

This patch applies to the patch sent previously entitled :
[PATCH] r6040: remove unused includes.

Thanks.
--
From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH resend] r6040: fix bad usage of udelay

This patch fixes the bad usage of udelay(5000), which in turns is a
mdelay(5). It causes compilation for ARM where udelay maximum value
is checked.

Reported-by: Martin Michlmayr <tbm@cyrius.com>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d453987..d837bef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -364,7 +364,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	/* Reset internal state machine */
 	iowrite16(2, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
 
 	/* MAC Bus Control Register */
 	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
@@ -800,7 +800,7 @@ static void r6040_mac_address(struct net_device *dev)
 	iowrite16(0x01, ioaddr + MCR1); /* Reset MAC */
 	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
 
 	/* Restore MAC Address */
 	adrp = (u16 *) dev->dev_addr;
