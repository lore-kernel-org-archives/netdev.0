From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 06/10] 6lowpan: add nhc module for GHC fragmentation extension header detection
Date: Wed,  9 Dec 2015 22:46:27 +0100
Message-ID: <1449697591-15991-7-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Stefan Schmidt <stefan@osg.samsung.com>,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33589 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbbLIVrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:47:32 -0500
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
 net/6lowpan/nhc_ghc_ext_frag.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+)
 create mode 100644 net/6lowpan/nhc_ghc_ext_frag.c

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index e5184e6..13abcc5 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -81,4 +81,10 @@ config 6LOWPAN_GHC_EXT_HDR_DEST
 	  6LoWPAN IPv6 destination option generic header compression according
 	  to RFC7400.
 
+config 6LOWPAN_GHC_EXT_HDR_FRAG
+	tristate "GHC Fragmentation Options Header Support"
+	---help---
+	  6LoWPAN IPv6 fragmentation option generic header compression
+	  according to RFC7400.
+
 endif
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
index fc4bac0..fb3f48d 100644
--- a/net/6lowpan/Makefile
+++ b/net/6lowpan/Makefile
@@ -16,3 +16,4 @@ obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_HOP) += nhc_ghc_ext_hop.o
 obj-$(CONFIG_6LOWPAN_GHC_UDP) += nhc_ghc_udp.o
 obj-$(CONFIG_6LOWPAN_GHC_ICMPV6) += nhc_ghc_icmpv6.o
 obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_DEST) += nhc_ghc_ext_dest.o
+obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG) += nhc_ghc_ext_frag.o
diff --git a/net/6lowpan/nhc_ghc_ext_frag.c b/net/6lowpan/nhc_ghc_ext_frag.c
new file mode 100644
index 0000000..1308b79
--- /dev/null
+++ b/net/6lowpan/nhc_ghc_ext_frag.c
@@ -0,0 +1,28 @@
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
+#define LOWPAN_GHC_EXT_FRAG_IDLEN	1
+#define LOWPAN_GHC_EXT_FRAG_ID_0	0xb4
+#define LOWPAN_GHC_EXT_FRAG_MASK_0	0xfe
+
+static void frag_ghid_setup(struct lowpan_nhc *nhc)
+{
+	nhc->id[0] = LOWPAN_GHC_EXT_FRAG_ID_0;
+	nhc->idmask[0] = LOWPAN_GHC_EXT_FRAG_MASK_0;
+}
+
+LOWPAN_NHC(ghc_ext_frag, "RFC7400 Fragmentation Extension Header",
+	   NEXTHDR_FRAGMENT, 0, frag_ghid_setup,
+	   LOWPAN_GHC_EXT_FRAG_IDLEN, NULL, NULL);
+
+module_lowpan_nhc(ghc_ext_frag);
+MODULE_DESCRIPTION("6LoWPAN generic header fragmentation extension compression");
+MODULE_LICENSE("GPL");
-- 
2.6.1
