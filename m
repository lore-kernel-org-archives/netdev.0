From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/acenic.c: fix check-after-use
Date: Mon, 23 Jul 2007 10:02:32 +0200
Message-ID: <20070723080232.GF26212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-acenic@sunsite.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jes@trained-monkey.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:41714 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763008AbXGWIDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 04:03:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker noted that we've already dereferenced "dev" when we 
check whether it's NULL.

Since it's impossible that "dev" is NULL at this place this patch 
removes the NULL check.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/drivers/net/acenic.c.old	2007-07-23 04:06:05.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/net/acenic.c	2007-07-23 04:08:11.000000000 +0200
@@ -3124,20 +3124,14 @@ static int __devinit read_eeprom_byte(st
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 	unsigned long flags;
 	u32 local;
 	int result = 0;
 	short i;
 
-	if (!dev) {
-		printk(KERN_ERR "No device!\n");
-		result = -ENODEV;
-		goto out;
-	}
-
 	/*
 	 * Don't take interrupts on this CPU will bit banging
 	 * the %#%#@$ I2C device
 	 */
 	local_irq_save(flags);
 
 	eeprom_start(regs);

