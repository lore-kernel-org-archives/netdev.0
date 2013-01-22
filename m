From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/15] drivers/net: delete intel i825xx based znet notebook driver
Date: Mon, 21 Jan 2013 20:46:14 -0500
Message-ID: <1358819182-28032-8-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45343 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab3AVBqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:38 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver supported early to mid 1990's Zenith laptops, of the
2" thick variety.  The driver was already dead 10+ years ago, but
we see this in the source:

 ----------------
 /* 10/2002

 [...]

   Tested on a vintage Zenith Z-Note 433Lnp+. Probably broken on
   anything else. Testers (and detailed bug reports) are welcome :-).
 ----------------

To clarify, a 433 translates into a 486 at 33MHz, and a system with
a default of 4MB RAM.  I can't fault the noble effort to keep things
working a decade ago, but at this point in time, there is no valid
justification to continue carrying this driver along.

Note that there is no associated Space.c cleanup here since this
driver was using module_init to hook itself in.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/i825xx/Kconfig  |  10 -
 drivers/net/ethernet/i825xx/Makefile |   1 -
 drivers/net/ethernet/i825xx/znet.c   | 928 -----------------------------------
 3 files changed, 939 deletions(-)
 delete mode 100644 drivers/net/ethernet/i825xx/znet.c

diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 16b14a9..c3cfa57 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -79,14 +79,4 @@ config SUN3_82586
 	  that this driver does not support 82586-based adapters on additional
 	  VME boards.
 
-config ZNET
-	tristate "Zenith Z-Note support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && ISA_DMA_API && X86
-	---help---
-	  The Zenith Z-Note notebook computer has a built-in network
-	  (Ethernet) card, and this is the Linux driver for it. Note that the
-	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
-	  by this driver. Read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
 endif # NET_VENDOR_I825XX
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index 4267ae7..df9e2ec 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -5,7 +5,6 @@
 obj-$(CONFIG_ARM_ETHER1) += ether1.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
-obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_MVME16x_NET) += 82596.o
diff --git a/drivers/net/ethernet/i825xx/znet.c b/drivers/net/ethernet/i825xx/znet.c
deleted file mode 100644
index c9479e0..0000000
-- 
1.8.1
