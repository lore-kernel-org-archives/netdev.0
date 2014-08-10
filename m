From: Michael Schmitz <schmitzmic@gmail.com>
Subject: (unknown)
Date: Sun, 10 Aug 2014 14:02:33 +1200
Message-ID: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>
Cc: geert@linux-m68k.org, debian-68k@lists.debian.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, Michael Schmitz <schmitz@debian.org>
To: linux-m68k@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:53549 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbaHJCCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 22:02:47 -0400
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

new version of the patch adding Atari EtherNEC (IRQ-less ROM port ISA NE2k
adapter) support to ne.c, as announced before.

Thanks,

	Michael Schmitz

>From 224ce049f71577d6ec380aeb94a4d25c3c4016a7 Mon Sep 17 00:00:00 2001
From: Michael Schmitz <schmitzmic@gmail.com>
Date: Sat, 6 Apr 2013 13:26:42 +1300
Subject: [PATCH] m68k/atari: EtherNEC - ethernet support (ne)

Support for Atari EtherNEC ROM port adapters in ne.c

Signed-off-by: Michael Schmitz <schmitz@debian.org>
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/8390/Kconfig |    3 ++-
 drivers/net/ethernet/8390/ne.c    |    2 ++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 0988811..2d89bd0 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -91,7 +91,8 @@ config MCF8390
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX)
+	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX || \
+		    ATARI_ETHERNEC)
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index 58eaa8f..de566fb 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -169,6 +169,8 @@ bad_clone_list[] __initdata = {
 #elif defined(CONFIG_PLAT_OAKS32R)  || \
    defined(CONFIG_MACH_TX49XX)
 #  define DCR_VAL 0x48		/* 8-bit mode */
+#elif defined(CONFIG_ATARI)	/* 8-bit mode on Atari, normal on Q40 */
+#  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
 #else
 #  define DCR_VAL 0x49
 #endif
-- 
1.7.0.4
