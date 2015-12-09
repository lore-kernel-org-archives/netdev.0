From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 05/10] 6lowpan: add nhc module for GHC destination extension header detection
Date: Wed,  9 Dec 2015 22:46:26 +0100
Message-ID: <1449697591-15991-6-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Stefan Schmidt <stefan@osg.samsung.com>,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34624 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbbLIVrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:47:31 -0500
In-Reply-To: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Schmidt <stefan@osg.samsung.com>

Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Signed-off-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/6lowpan/Kconfig            |  6 ++++++
 net/6lowpan/Makefile           |  1 +
 net/6lowpan/nhc_ghc_ext_dest.c | 27 +++++++++++++++++++++++++++
 3 files changed, 34 insertions(+)
 create mode 100644 net/6lowpan/nhc_ghc_ext_dest.c

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 0a3f5a8..e5184e6 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -75,4 +75,10 @@ config 6LOWPAN_GHC_ICMPV6
 	---help---
 	  6LoWPAN IPv6 ICMPv6 generic header compression according to RFC7400.
 
+config 6LOWPAN_GHC_EXT_HDR_DEST
+	tristate "GHC Destination Options Header Support"
+	---help---
+	  6LoWPAN IPv6 destination option generic header compression according
+	  to RFC7400.
+
 endif
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
index 86af3fd..fc4bac0 100644
--- a/net/6lowpan/Makefile
+++ b/net/6lowpan/Makefile
@@ -15,3 +15,4 @@ obj-$(CONFIG_6LOWPAN_NHC_UDP) += nhc_udp.o
 obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_HOP) += nhc_ghc_ext_hop.o
 obj-$(CONFIG_6LOWPAN_GHC_UDP) += nhc_ghc_udp.o
 obj-$(CONFIG_6LOWPAN_GHC_ICMPV6) += nhc_ghc_icmpv6.o
+obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_DEST) += nhc_ghc_ext_dest.o
diff --git a/net/6lowpan/nhc_ghc_ext_dest.c b/net/6lowpan/nhc_ghc_ext_dest.c
new file mode 100644
index 0000000..9887b3a
--- /dev/null
+++ b/net/6lowpan/nhc_ghc_ext_dest.c
@@ -0,0 +1,27 @@
+/*
+ *	6LoWPAN Extension Header compression according to RFC7400
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include "nhc.h"
+
+#define LOWPAN_GHC_EXT_DEST_IDLEN	1
+#define LOWPAN_GHC_EXT_DEST_ID_0	0xb6
+#define LOWPAN_GHC_EXT_DEST_MASK_0	0xfe
+
+static void dest_ghid_setup(struct lowpan_nhc *nhc)
+{
+	nhc->id[0] = LOWPAN_GHC_EXT_DEST_ID_0;
+	nhc->idmask[0] = LOWPAN_GHC_EXT_DEST_MASK_0;
+}
+
+LOWPAN_NHC(ghc_ext_dest, "RFC7400 Destination Extension Header", NEXTHDR_DEST,
+	   0, dest_ghid_setup, LOWPAN_GHC_EXT_DEST_IDLEN, NULL, NULL);
+
+module_lowpan_nhc(ghc_ext_dest);
+MODULE_DESCRIPTION("6LoWPAN generic header destination extension compression");
+MODULE_LICENSE("GPL");
-- 
2.6.1
