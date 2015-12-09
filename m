From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 03/10] 6lowpan: add nhc module for GHC UDP detection
Date: Wed,  9 Dec 2015 22:46:24 +0100
Message-ID: <1449697591-15991-4-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Stefan Schmidt <stefan@osg.samsung.com>,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34904 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbbLIVr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:47:28 -0500
In-Reply-To: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Schmidt <stefan@osg.samsung.com>

Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Signed-off-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/6lowpan/Kconfig       |  5 +++++
 net/6lowpan/Makefile      |  1 +
 net/6lowpan/nhc_ghc_udp.c | 27 +++++++++++++++++++++++++++
 3 files changed, 33 insertions(+)
 create mode 100644 net/6lowpan/nhc_ghc_udp.c

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 1bd49eb..94d5178 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -65,4 +65,9 @@ config 6LOWPAN_GHC_EXT_HDR_HOP
 	  6LoWPAN IPv6 Hop-by-Hop option generic header compression according
 	  to RFC7400.
 
+config 6LOWPAN_GHC_UDP
+	tristate "GHC UDP Support"
+	---help---
+	  6LoWPAN IPv6 UDP generic header compression according to RFC7400.
+
 endif
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
index ba20e01..5e4f2f3 100644
--- a/net/6lowpan/Makefile
+++ b/net/6lowpan/Makefile
@@ -13,3 +13,4 @@ obj-$(CONFIG_6LOWPAN_NHC_UDP) += nhc_udp.o
 
 #rfc7400 ghcs
 obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_HOP) += nhc_ghc_ext_hop.o
+obj-$(CONFIG_6LOWPAN_GHC_UDP) += nhc_ghc_udp.o
diff --git a/net/6lowpan/nhc_ghc_udp.c b/net/6lowpan/nhc_ghc_udp.c
new file mode 100644
index 0000000..17beefa
--- /dev/null
+++ b/net/6lowpan/nhc_ghc_udp.c
@@ -0,0 +1,27 @@
+/*
+ *	6LoWPAN UDP compression according to RFC7400
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include "nhc.h"
+
+#define LOWPAN_GHC_UDP_IDLEN	1
+#define LOWPAN_GHC_UDP_ID_0	0xd0
+#define LOWPAN_GHC_UDP_MASK_0	0xf8
+
+static void udp_ghid_setup(struct lowpan_nhc *nhc)
+{
+	nhc->id[0] = LOWPAN_GHC_UDP_ID_0;
+	nhc->idmask[0] = LOWPAN_GHC_UDP_MASK_0;
+}
+
+LOWPAN_NHC(ghc_udp, "RFC7400 UDP", NEXTHDR_UDP, 0,
+	   udp_ghid_setup, LOWPAN_GHC_UDP_IDLEN, NULL, NULL);
+
+module_lowpan_nhc(ghc_udp);
+MODULE_DESCRIPTION("6LoWPAN generic header UDP compression");
+MODULE_LICENSE("GPL");
-- 
2.6.1
