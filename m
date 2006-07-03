From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH 2/2] ATM: add+use poison defines
Date: Sun, 2 Jul 2006 18:21:38 -0700
Message-ID: <20060702182138.f29d484b.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@osdl.org>, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:65152 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750980AbWGCBSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 21:18:53 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 2 Jul 2006 18:18:51 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

ATM: add and use POISON define values.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/atm/ambassador.c |    3 ++-
 drivers/atm/idt77252.c   |    3 ++-
 include/linux/poison.h   |    1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

--- linux-2617-g20.orig/drivers/atm/ambassador.c
+++ linux-2617-g20/drivers/atm/ambassador.c
@@ -31,6 +31,7 @@
 #include <linux/atmdev.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
+#include <linux/poison.h>
 
 #include <asm/atomic.h>
 #include <asm/io.h>
@@ -1995,7 +1996,7 @@ static int __devinit ucode_init (loader_
     }
     i += 1;
   }
-  if (*pointer == 0xdeadbeef) {
+  if (*pointer == ATM_POISON) {
     return loader_start (lb, dev, ucode_start);
   } else {
     // cast needed as there is no %? for pointer differnces
--- linux-2617-g20.orig/drivers/atm/idt77252.c
+++ linux-2617-g20/drivers/atm/idt77252.c
@@ -35,6 +35,7 @@ static char const rcsid[] =
 
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/poison.h>
 #include <linux/skbuff.h>
 #include <linux/kernel.h>
 #include <linux/vmalloc.h>
@@ -3657,7 +3658,7 @@ probe_sram(struct idt77252_dev *card)
 	writel(SAR_CMD_WRITE_SRAM | (0 << 2), SAR_REG_CMD);
 
 	for (addr = 0x4000; addr < 0x80000; addr += 0x4000) {
-		writel(0xdeadbeef, SAR_REG_DR0);
+		writel(ATM_POISON, SAR_REG_DR0);
 		writel(SAR_CMD_WRITE_SRAM | (addr << 2), SAR_REG_CMD);
 
 		writel(SAR_CMD_READ_SRAM | (0 << 2), SAR_REG_CMD);
--- linux-2617-g20.orig/include/linux/poison.h
+++ linux-2617-g20/include/linux/poison.h
@@ -44,6 +44,7 @@
 
 /********** drivers/atm/ **********/
 #define ATM_POISON_FREE		0x12
+#define ATM_POISON		0xdeadbeef
 
 /********** net/ **********/
 #define NEIGHBOR_DEAD		0xdeadbeef
