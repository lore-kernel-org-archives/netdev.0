From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/15] drivers/net: delete the 3Com 3c505/3c507 intel i825xx support
Date: Mon, 21 Jan 2013 20:46:12 -0500
Message-ID: <1358819182-28032-6-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45333 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab3AVBqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:37 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For those of us who were around in the early to mid 1990's, we
will remember that the i825xx ethernet support was not something
that was considered sufficiently vetted for 24/7 use.

Folks might be inclined to use *functional* ISA hardware on some
near expired P3 ISA machines for dedicated workhorse applications,
but the odds of using (and relying on) one of these old/experimental
drivers is essentially nil.  So lets remove them.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                  |    8 -
 drivers/net/ethernet/i825xx/3c505.c  | 1672 ----------------------------------
 drivers/net/ethernet/i825xx/3c505.h  |  292 ------
 drivers/net/ethernet/i825xx/3c507.c  |  939 -------------------
 drivers/net/ethernet/i825xx/Kconfig  |   23 -
 drivers/net/ethernet/i825xx/Makefile |    2 -
 6 files changed, 2936 deletions(-)
 delete mode 100644 drivers/net/ethernet/i825xx/3c505.c
 delete mode 100644 drivers/net/ethernet/i825xx/3c505.h
 delete mode 100644 drivers/net/ethernet/i825xx/3c507.c

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index d487127..ac66a6a 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -51,8 +51,6 @@ extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
-extern struct net_device *el16_probe(int unit);
-extern struct net_device *elplus_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
@@ -164,12 +162,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_EL16		/* 3c507 */
-	{el16_probe, 0},
-#endif
-#ifdef CONFIG_ELPLUS		/* 3c505 */
-	{elplus_probe, 0},
-#endif
 #ifdef CONFIG_NI5010
 	{ni5010_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/i825xx/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
deleted file mode 100644
index 6d000d6..0000000
diff --git a/drivers/net/ethernet/i825xx/3c505.h b/drivers/net/ethernet/i825xx/3c505.h
deleted file mode 100644
index 04df2a9..0000000
diff --git a/drivers/net/ethernet/i825xx/3c507.c b/drivers/net/ethernet/i825xx/3c507.c
deleted file mode 100644
index 13983ee..0000000
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 46edb81..b800a94 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -20,29 +20,6 @@ config NET_VENDOR_I825XX
 
 if NET_VENDOR_I825XX
 
-config ELPLUS
-	tristate "3c505 \"EtherLink Plus\" support"
-	depends on ISA && ISA_DMA_API
-	---help---
-	  Information about this network (Ethernet) card can be found in
-	  <file:Documentation/networking/3c505.txt>.  If you have a card of
-	  this type, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c505.
-
-config EL16
-	tristate "3c507 \"EtherLink 16\" support (EXPERIMENTAL)"
-	depends on ISA && EXPERIMENTAL
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c507.
-
 config ARM_ETHER1
 	tristate "Acorn Ether1 support"
 	depends on ARM && ARCH_ACORN
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index 4f01584..bc81e14 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -5,8 +5,6 @@
 obj-$(CONFIG_ARM_ETHER1) += ether1.o
 obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
-obj-$(CONFIG_ELPLUS) += 3c505.o
-obj-$(CONFIG_EL16) += 3c507.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_ZNET) += znet.o
-- 
1.8.1
