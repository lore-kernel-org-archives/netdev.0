From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] ne: Use CONFIG_MACH_TX49XX
Date: Fri, 08 Aug 2008 00:55:17 +0900 (JST)
Message-ID: <20080808.005517.96686714.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:60193 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbYHGQmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 12:42:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After some cleanups in arch/mips area, now MACH_TX49XX is selected for
both TOSHIBA_RBTX4927 and TOSHIBA_RBTX4938.  Fold these two conditions
to one.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/Kconfig |    2 +-
 drivers/net/ne.c    |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8a03875..b6c1717 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1171,7 +1171,7 @@ config ETH16I
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R || TOSHIBA_RBTX4927 || TOSHIBA_RBTX4938
+	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 42443d6..fa3ceca 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -118,7 +118,7 @@ bad_clone_list[] __initdata = {
     {"E-LAN100", "E-LAN200", {0x00, 0x00, 0x5d}}, /* Broken ne1000 clones */
     {"PCM-4823", "PCM-4823", {0x00, 0xc0, 0x6c}}, /* Broken Advantech MoBo */
     {"REALTEK", "RTL8019", {0x00, 0x00, 0xe8}}, /* no-name with Realtek chip */
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+#ifdef CONFIG_MACH_TX49XX
     {"RBHMA4X00-RTL8019", "RBHMA4X00/RTL8019", {0x00, 0x60, 0x0a}},  /* Toshiba built-in */
 #endif
     {"LCS-8834", "LCS-8836", {0x04, 0x04, 0x37}}, /* ShinyNet (SET) */
@@ -142,7 +142,7 @@ bad_clone_list[] __initdata = {
 #if defined(CONFIG_PLAT_MAPPI)
 #  define DCR_VAL 0x4b
 #elif defined(CONFIG_PLAT_OAKS32R)  || \
-   defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+   defined(CONFIG_MACH_TX49XX)
 #  define DCR_VAL 0x48		/* 8-bit mode */
 #else
 #  define DCR_VAL 0x49
