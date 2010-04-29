From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 08/13] KSZ8851-SNL: Fix EEPROM access problem
Date: Fri, 30 Apr 2010 00:16:29 +0100
Message-ID: <20100429231740.358390546@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932466Ab0D3Vsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:30 -0400
Content-Disposition: inline; filename=thirdparty/micrel/ksz8851-fix-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@micrel.com>

Accessing the EEPROM when the device is receiving sometimes hangs the
system as the hardware is not locked down.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
[ben@simtec.co.uk: fix description text]
Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
---
 drivers/net/ks8851.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 01:22:42.667052653 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 01:22:47.779528264 +0900
@@ -1181,7 +1181,6 @@ static void ks8851_eeprom_regwrite(struc
 	if (ee->reg_chip_select)
 		val |= EEPCR_EECS;
 
-	printk(KERN_INFO "%s: wr %04x\n", __func__, val);
 	ks8851_wrreg16(ks, KS_EEPCR, val);
 }
 
@@ -1197,6 +1196,8 @@ static int ks8851_eeprom_claim(struct ks
 	if (!(ks->rc_ccr & CCR_EEPROM))
 		return -ENOENT;
 
+	mutex_lock(&ks->lock);
+
 	/* start with clock low, cs high */
 	ks8851_wrreg16(ks, KS_EEPCR, EEPCR_EESA | EEPCR_EECS);
 	return 0;
@@ -1213,6 +1214,7 @@ static void ks8851_eeprom_release(struct
 	unsigned val = ks8851_rdreg16(ks,KS_EEPCR);
 
 	ks8851_wrreg16(ks, KS_EEPCR, val & ~EEPCR_EESA);
+	mutex_unlock(&ks->lock);
 }
 
 #define KS_EEPROM_MAGIC (0x00008851)

