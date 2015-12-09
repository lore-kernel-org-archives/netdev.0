From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH bluetooth-next 02/10] 6lowpan: add nhc module for GHC hop-by-hopextension header detection
Date: Wed,  9 Dec 2015 22:46:23 +0100
Message-ID: <1449697591-15991-3-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449697591-15991-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

Acked-by: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/6lowpan/Kconfig           |  6 ++++++
 net/6lowpan/Makefile          |  3 +++
 net/6lowpan/nhc_ghc_ext_hop.c | 27 +++++++++++++++++++++++++++
 3 files changed, 36 insertions(+)
 create mode 100644 net/6lowpan/nhc_ghc_ext_hop.c

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 6af7a46..1bd49eb 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -59,4 +59,10 @@ config 6LOWPAN_NHC_UDP
 	---help---
 	  6LoWPAN IPv6 UDP Header compression according to RFC6282.
 
+config 6LOWPAN_GHC_EXT_HDR_HOP
+	tristate "GHC Hop-by-Hop Options Header Support"
+	---help---
+	  6LoWPAN IPv6 Hop-by-Hop option generic header compression according
+	  to RFC7400.
+
 endif
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
index c6ffc55..ba20e01 100644
--- a/net/6lowpan/Makefile
+++ b/net/6lowpan/Makefile
@@ -10,3 +10,6 @@ obj-$(CONFIG_6LOWPAN_NHC_IPV6) += nhc_ipv6.o
 obj-$(CONFIG_6LOWPAN_NHC_MOBILITY) += nhc_mobility.o
 obj-$(CONFIG_6LOWPAN_NHC_ROUTING) += nhc_routing.o
 obj-$(CONFIG_6LOWPAN_NHC_UDP) += nhc_udp.o
+
+#rfc7400 ghcs
+obj-$(CONFIG_6LOWPAN_GHC_EXT_HDR_HOP) += nhc_ghc_ext_hop.o
diff --git a/net/6lowpan/nhc_ghc_ext_hop.c b/net/6lowpan/nhc_ghc_ext_hop.c
new file mode 100644
index 0000000..baec86f
--- /dev/null
+++ b/net/6lowpan/nhc_ghc_ext_hop.c
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
+#define LOWPAN_GHC_EXT_HOP_IDLEN	1
+#define LOWPAN_GHC_EXT_HOP_ID_0		0xb0
+#define LOWPAN_GHC_EXT_HOP_MASK_0	0xfe
+
+static void hop_ghid_setup(struct lowpan_nhc *nhc)
+{
+	nhc->id[0] = LOWPAN_GHC_EXT_HOP_ID_0;
+	nhc->idmask[0] = LOWPAN_GHC_EXT_HOP_MASK_0;
+}
+
+LOWPAN_NHC(ghc_ext_hop, "RFC7400 Hop-by-Hop Extension Header", NEXTHDR_HOP, 0,
+	   hop_ghid_setup, LOWPAN_GHC_EXT_HOP_IDLEN, NULL, NULL);
+
+module_lowpan_nhc(ghc_ext_hop);
+MODULE_DESCRIPTION("6LoWPAN generic header hop-by-hop extension compression");
+MODULE_LICENSE("GPL");
-- 
2.6.1
