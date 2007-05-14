From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] sky2: remove Gigabyte 88e8056 restriction
Date: Mon, 14 May 2007 12:38:10 -0700
Message-ID: <20070514193945.532045147@linux-foundation.org>
References: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:57341 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754259AbXENTmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:42:46 -0400
Content-Disposition: inline; filename=sky2-no-dmi.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The problems with Gigabyte motherboards are system configuration dependent.
Since it works fine for some users, it doesn't make sense to deprive
them.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   30 ------------------------------
 1 file changed, 30 deletions(-)

--- 2.6.21-rc1.orig/drivers/net/sky2.c	2007-05-14 12:06:07.000000000 -0700
+++ 2.6.21-rc1/drivers/net/sky2.c	2007-05-14 12:06:25.000000000 -0700
@@ -40,7 +40,6 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
-#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -151,8 +150,6 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
-static int dmi_blacklisted;
-
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -2534,17 +2531,6 @@ static int __devinit sky2_init(struct sk
 		return -EOPNOTSUPP;
 	}
 
-
-	/* Some Gigabyte motherboards have 88e8056 but cause problems
-	 * There is some unresolved hardware related problem that causes
-	 * descriptor errors and receive data corruption.
-	 */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && dmi_blacklisted) {
-		dev_err(&hw->pdev->dev,
-			"88E8056 on this motherboard not supported\n");
-		return -EOPNOTSUPP;
-	}
-
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -3910,24 +3896,8 @@ static struct pci_driver sky2_driver = {
 	.shutdown = sky2_shutdown,
 };
 
-static struct dmi_system_id __initdata broken_dmi_table[] = {
-	{
-		.ident = "Gigabyte 965P-S3",
-		.matches = {
-			DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., Ltd."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
-
-		},
-	},
-	{ }
-};
-
 static int __init sky2_init_module(void)
 {
-	/* Look for sick motherboards */
-	if (dmi_check_system(broken_dmi_table))
-		dmi_blacklisted = 1;
-
 	return pci_register_driver(&sky2_driver);
 }
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

