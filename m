From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] ethtool: Remove duplicate type definitions
Date: Sun, 29 Nov 2009 15:40:42 +0000
Message-ID: <1259509242.3709.69.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: =?ISO-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59948 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbZK2Pkm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 10:40:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/ethtool.h> and ethtool-copy.h now include <linux/types.h>, which
provides these type definitions.

The duplicate type definitions in ethtool-util.h conflict with those in
<asm/types.h> on Alpha, as reported in <http://bugs.debian.org/545850>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -5,11 +5,7 @@
 
 #include <sys/types.h>
 
-/* hack, so we may include kernel's ethtool.h */
-typedef unsigned long long __u64;
-typedef __uint32_t __u32;         /* ditto */
-typedef __uint16_t __u16;         /* ditto */
-typedef __uint8_t __u8;           /* ditto */
+#include "ethtool-copy.h"
 
 /* historical: we used to use kernel-like types; remove these once cleaned */
 typedef unsigned long long u64;
@@ -17,8 +13,6 @@
 typedef __uint16_t u16;         /* ditto */
 typedef __uint8_t u8;           /* ditto */
 
-#include "ethtool-copy.h"
-
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,


-- 
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

