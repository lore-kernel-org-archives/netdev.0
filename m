From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/15] drivers/net: delete old x86 variant of the seeq8005 driver
Date: Mon, 21 Jan 2013 20:46:22 -0500
Message-ID: <1358819182-28032-16-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45379 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab3AVBqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:42 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last update to the Ethernet HowTo (over 10 years ago) listed this:

 ------------------------
   SEEQ 8005

   Status: Obsolete, Driver Name: seeq8005

   There is little information about the card included in the driver,
   and hence little information to be put here. If you have a question,
   you are probably best trying to e-mail the driver author as listed
   in the source.

   It was marked obsolete as of the 2.4 series kernels.
 ------------------------

If it was obsolete over a decade ago, the situation can not have
improved with the passage of time, so let us act on that.  Even with
today's improved search engines, I was unable to locate any real
meaningful information on the ISA implementation of this rare chip.

There are ARM and SGI variants of the driver in tree, but they do
not depend on the original x86 driver source or header file.  We
leave those non-x86 drivers to be deleted by the arch maintainers
when they decide to expire those legacy platforms as a whole.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                  |   4 -
 drivers/net/ethernet/seeq/Kconfig    |  11 -
 drivers/net/ethernet/seeq/Makefile   |   1 -
 drivers/net/ethernet/seeq/seeq8005.c | 749 -----------------------------------
 drivers/net/ethernet/seeq/seeq8005.h | 156 --------
 5 files changed, 921 deletions(-)
 delete mode 100644 drivers/net/ethernet/seeq/seeq8005.c
 delete mode 100644 drivers/net/ethernet/seeq/seeq8005.h

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 9c30ea4..3a8c753 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -45,7 +45,6 @@ extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
-extern struct net_device *seeq8005_probe(int unit);
 extern struct net_device *smc_init(int unit);
 extern struct net_device *atarilance_probe(int unit);
 extern struct net_device *sun3lance_probe(int unit);
@@ -113,9 +112,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_SMC9194
 	{smc_init, 0},
 #endif
-#ifdef CONFIG_SEEQ8005
-	{seeq8005_probe, 0},
-#endif
 #ifdef CONFIG_CS89x0
 #ifndef CONFIG_CS89x0_PLATFORM
  	{cs89x0_probe, 0},
diff --git a/drivers/net/ethernet/seeq/Kconfig b/drivers/net/ethernet/seeq/Kconfig
index 29f1853..a71e1ec 100644
--- a/drivers/net/ethernet/seeq/Kconfig
+++ b/drivers/net/ethernet/seeq/Kconfig
@@ -26,17 +26,6 @@ config ARM_ETHER3
 	  If you have an Acorn system with one of these network cards, you
 	  should say Y to this option if you wish to use it with Linux.
 
-config SEEQ8005
-	tristate "SEEQ8005 support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
-	---help---
-	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
-	  is for you, read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called seeq8005.
-
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
 	depends on SGI_HAS_SEEQ
diff --git a/drivers/net/ethernet/seeq/Makefile b/drivers/net/ethernet/seeq/Makefile
index 3e258a5..0488e99 100644
--- a/drivers/net/ethernet/seeq/Makefile
+++ b/drivers/net/ethernet/seeq/Makefile
@@ -3,5 +3,4 @@
 #
 
 obj-$(CONFIG_ARM_ETHER3) += ether3.o
-obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
diff --git a/drivers/net/ethernet/seeq/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
deleted file mode 100644
index d6e50de..0000000
diff --git a/drivers/net/ethernet/seeq/seeq8005.h b/drivers/net/ethernet/seeq/seeq8005.h
deleted file mode 100644
index 5dfb009..0000000
-- 
1.8.1
