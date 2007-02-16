From: akpm@linux-foundation.org
Subject: [patch 1/2] atm: Use ARRAY_SIZE macro when appropriate
Date: Fri, 16 Feb 2007 01:42:23 -0800
Message-ID: <200702160942.l1G9gNPY026487@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	darwish.07@gmail.com, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36999 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423521AbXBPJrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 04:47:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ahmed S. Darwish" <darwish.07@gmail.com>

Use ARRAY_SIZE macro already defined in kernel.h for ATM
drivers.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/he.c         |    2 +-
 drivers/atm/idt77252.c   |    8 ++++----
 drivers/atm/nicstarmac.c |    4 +++-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff -puN drivers/atm/he.c~atm-use-array_size-macro-when-appropriate drivers/atm/he.c
--- a/drivers/atm/he.c~atm-use-array_size-macro-when-appropriate
+++ a/drivers/atm/he.c
@@ -3017,7 +3017,7 @@ read_prom_byte(struct he_dev *he_dev, in
 	he_writel(he_dev, val, HOST_CNTL);
        
 	/* Send READ instruction */
-	for (i = 0; i < sizeof(readtab)/sizeof(readtab[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(readtab); i++) {
 		he_writel(he_dev, val | readtab[i], HOST_CNTL);
 		udelay(EEPROM_DELAY);
 	}
diff -puN drivers/atm/idt77252.c~atm-use-array_size-macro-when-appropriate drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c~atm-use-array_size-macro-when-appropriate
+++ a/drivers/atm/idt77252.c
@@ -388,7 +388,7 @@ idt77252_eeprom_read_status(struct idt77
 
 	gp = idt77252_read_gp(card) & ~(SAR_GP_EESCLK|SAR_GP_EECS|SAR_GP_EEDO);
 
-	for (i = 0; i < sizeof(rdsrtab)/sizeof(rdsrtab[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(rdsrtab); i++) {
 		idt77252_write_gp(card, gp | rdsrtab[i]);
 		udelay(5);
 	}
@@ -422,7 +422,7 @@ idt77252_eeprom_read_byte(struct idt7725
 
 	gp = idt77252_read_gp(card) & ~(SAR_GP_EESCLK|SAR_GP_EECS|SAR_GP_EEDO);
 
-	for (i = 0; i < sizeof(rdtab)/sizeof(rdtab[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(rdtab); i++) {
 		idt77252_write_gp(card, gp | rdtab[i]);
 		udelay(5);
 	}
@@ -469,14 +469,14 @@ idt77252_eeprom_write_byte(struct idt772
 
 	gp = idt77252_read_gp(card) & ~(SAR_GP_EESCLK|SAR_GP_EECS|SAR_GP_EEDO);
 
-	for (i = 0; i < sizeof(wrentab)/sizeof(wrentab[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(wrentab); i++) {
 		idt77252_write_gp(card, gp | wrentab[i]);
 		udelay(5);
 	}
 	idt77252_write_gp(card, gp | SAR_GP_EECS);
 	udelay(5);
 
-	for (i = 0; i < sizeof(wrtab)/sizeof(wrtab[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(wrtab); i++) {
 		idt77252_write_gp(card, gp | wrtab[i]);
 		udelay(5);
 	}
diff -puN drivers/atm/nicstarmac.c~atm-use-array_size-macro-when-appropriate drivers/atm/nicstarmac.c
--- a/drivers/atm/nicstarmac.c~atm-use-array_size-macro-when-appropriate
+++ a/drivers/atm/nicstarmac.c
@@ -7,6 +7,8 @@
  * Read this ForeRunner's MAC address from eprom/eeprom
  */
 
+#include <linux/kernel.h>
+
 typedef void __iomem *virt_addr_t;
 
 #define CYCLE_DELAY 5
@@ -176,7 +178,7 @@ read_eprom_byte(virt_addr_t base, u_int8
    val = NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE ) & 0xFFFFFFF0;
 
    /* Send READ instruction */
-   for (i=0; i<sizeof readtab/sizeof readtab[0]; i++)
+   for (i=0; i<ARRAY_SIZE(readtab); i++)
    {
 	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
 		(val | readtab[i]) );
_
