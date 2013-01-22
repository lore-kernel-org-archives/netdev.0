From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/15] drivers/net: delete ISA intel eexpress and eepro i825xx drivers
Date: Mon, 21 Jan 2013 20:46:13 -0500
Message-ID: <1358819182-28032-7-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45338 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab3AVBqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:38 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These old drivers should not be confused with the very common PCI
cards that are supported by e100.c -- these older 10Mbit ISA only
drivers were not as commonly used as some of the other ISA drivers,
simply due to hardware availability and pricing.

Given the rarity of the hardware, and the subsequent less extensive
use of the drivers, it makes sense to obsolete them at this point
in time, along with other rare/experimental ISA drivers.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                    |    8 -
 drivers/net/ethernet/i825xx/Kconfig    |   27 -
 drivers/net/ethernet/i825xx/Makefile   |    2 -
 drivers/net/ethernet/i825xx/eepro.c    | 1822 --------------------------------
 drivers/net/ethernet/i825xx/eexpress.c | 1661 -----------------------------
 drivers/net/ethernet/i825xx/eexpress.h |  179 ----
 6 files changed, 3699 deletions(-)
 delete mode 100644 drivers/net/ethernet/i825xx/eepro.c
 delete mode 100644 drivers/net/ethernet/i825xx/eexpress.c
 delete mode 100644 drivers/net/ethernet/i825xx/eexpress.h

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index ac66a6a..726b17b 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -44,8 +44,6 @@ extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
 extern struct net_device *hp_probe(int unit);
 extern struct net_device *hp_plus_probe(int unit);
-extern struct net_device *express_probe(int unit);
-extern struct net_device *eepro_probe(int unit);
 extern struct net_device *at1700_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
@@ -150,12 +148,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_ETH16I
 	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
 #endif
-#ifdef CONFIG_EEXPRESS		/* Intel EtherExpress */
-	{express_probe, 0},
-#endif
-#ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
-	{eepro_probe, 0},
-#endif
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index b800a94..16b14a9 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -36,33 +36,6 @@ config BVME6000_NET
 	  in your kernel.
 	  To compile this driver as a module, choose M here.
 
-config EEXPRESS
-	tristate "EtherExpress 16 support"
-	depends on ISA
-	---help---
-	  If you have an EtherExpress16 network (Ethernet) card, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that the Intel
-	  EtherExpress16 card used to be regarded as a very poor choice
-	  because the driver was very unreliable. We now have a new driver
-	  that should do better.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eexpress.
-
-config EEXPRESS_PRO
-	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y. This
-	  driver supports Intel i82595{FX,TX} based boards. Note however
-	  that the EtherExpress PRO/100 Ethernet card has its own separate
-	  driver.  Please read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eepro.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index bc81e14..4267ae7 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -3,8 +3,6 @@
 #
 
 obj-$(CONFIG_ARM_ETHER1) += ether1.o
-obj-$(CONFIG_EEXPRESS) += eexpress.o
-obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_ZNET) += znet.o
diff --git a/drivers/net/ethernet/i825xx/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
deleted file mode 100644
index 7f49fd5..0000000
diff --git a/drivers/net/ethernet/i825xx/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
deleted file mode 100644
index 7a6a2f0..0000000
diff --git a/drivers/net/ethernet/i825xx/eexpress.h b/drivers/net/ethernet/i825xx/eexpress.h
deleted file mode 100644
index dc9c6ea..0000000
-- 
1.8.1
