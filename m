From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 03/21] Combine ethtool-{bitops,util}.h into
 internal.h
Date: Tue, 1 Nov 2011 23:14:08 +0000
Message-ID: <1320189248.2758.33.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37811 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1KAXOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:14:11 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool-util.h contains all kinds of declarations, not just utility
functions or macros.

ethtool-bitops.h contains just a few extra definitions, and its only
user also includes ethtool-util.h.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Makefile.am                  |    2 +-
 amd8111e.c                   |    2 +-
 at76c50x-usb.c               |    2 +-
 de2104x.c                    |    2 +-
 e100.c                       |    2 +-
 e1000.c                      |    2 +-
 ethtool-bitops.h             |   25 -------------------------
 ethtool.c                    |    2 +-
 fec_8xx.c                    |    2 +-
 ibm_emac.c                   |    2 +-
 igb.c                        |    2 +-
 ethtool-util.h => internal.h |   27 ++++++++++++++++++++++++---
 ixgb.c                       |    2 +-
 ixgbe.c                      |    2 +-
 marvell.c                    |    2 +-
 natsemi.c                    |    2 +-
 pcnet32.c                    |    2 +-
 realtek.c                    |    2 +-
 rxclass.c                    |    3 +--
 sfc.c                        |    2 +-
 smsc911x.c                   |    2 +-
 stmmac.c                     |    2 +-
 tg3.c                        |    2 +-
 vioc.c                       |    2 +-
 24 files changed, 46 insertions(+), 51 deletions(-)
 delete mode 100644 ethtool-bitops.h
 rename ethtool-util.h => internal.h (86%)

diff --git a/Makefile.am b/Makefile.am
index c87fb39..1e05640 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -4,7 +4,7 @@ man_MANS = ethtool.8
 EXTRA_DIST = LICENSE ethtool.8 ethtool.spec.in aclocal.m4 ChangeLog autogen.sh
 
 sbin_PROGRAMS = ethtool
-ethtool_SOURCES = ethtool.c ethtool-bitops.h ethtool-copy.h ethtool-util.h \
+ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h \
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
diff --git a/amd8111e.c b/amd8111e.c
index b4cd65d..23478f0 100644
--- a/amd8111e.c
+++ b/amd8111e.c
@@ -1,7 +1,7 @@
 
 /* Copyright (C) 2003  Advanced Micro Devices Inc. */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 typedef enum {
 	/* VAL2 */
diff --git a/at76c50x-usb.c b/at76c50x-usb.c
index 4c2a1a8..39e24a4 100644
--- a/at76c50x-usb.c
+++ b/at76c50x-usb.c
@@ -1,5 +1,5 @@
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 static char *hw_versions[] = {
         "503_ISL3861",
diff --git a/de2104x.c b/de2104x.c
index f64e1b2..856e0c0 100644
--- a/de2104x.c
+++ b/de2104x.c
@@ -1,6 +1,6 @@
 /* Copyright 2001 Sun Microsystems (thockin@sun.com) */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 static const char * const csr0_tap[4] = {
 	"No transmit automatic polling",
diff --git a/e100.c b/e100.c
index 4d1cef3..65627ab 100644
--- a/e100.c
+++ b/e100.c
@@ -1,6 +1,6 @@
 /* Copyright (c) 2002 Intel Corporation */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #define D102_REV_ID		12
 
diff --git a/e1000.c b/e1000.c
index 2eb3ac6..d1d3c73 100644
--- a/e1000.c
+++ b/e1000.c
@@ -1,6 +1,6 @@
 /* Copyright (c) 2002 Intel Corporation */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 /* Register Bit Masks */
 /* Device Control */
diff --git a/ethtool-bitops.h b/ethtool-bitops.h
deleted file mode 100644
index b1eb426..0000000
--- a/ethtool-bitops.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef ETHTOOL_BITOPS_H__
-#define ETHTOOL_BITOPS_H__
-
-#define BITS_PER_BYTE		8
-#define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
-#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
-#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
-
-static inline void set_bit(int nr, unsigned long *addr)
-{
-	addr[nr / BITS_PER_LONG] |= 1UL << (nr % BITS_PER_LONG);
-}
-
-static inline void clear_bit(int nr, unsigned long *addr)
-{
-	addr[nr / BITS_PER_LONG] &= ~(1UL << (nr % BITS_PER_LONG));
-}
-
-static inline int test_bit(unsigned int nr, const unsigned long *addr)
-{
-	return !!((1UL << (nr % BITS_PER_LONG)) &
-		  (((unsigned long *)addr)[nr / BITS_PER_LONG]));
-}
-
-#endif
diff --git a/ethtool.c b/ethtool.c
index ad2d583..f772f61 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -23,7 +23,7 @@
  *   * show settings for all devices
  */
 
-#include "ethtool-util.h"
+#include "internal.h"
 #include <string.h>
 #include <stdlib.h>
 #include <sys/stat.h>
diff --git a/fec_8xx.c b/fec_8xx.c
index 06a25d9..69db8c8 100644
--- a/fec_8xx.c
+++ b/fec_8xx.c
@@ -7,7 +7,7 @@
 #include <stdint.h>
 #include <stddef.h>
 
-#include "ethtool-util.h"
+#include "internal.h"
 
 struct fec {
 	uint32_t	addr_low;	/* lower 32 bits of station address	*/
diff --git a/ibm_emac.c b/ibm_emac.c
index 7974836..e128e48 100644
--- a/ibm_emac.c
+++ b/ibm_emac.c
@@ -6,7 +6,7 @@
 #include <stdint.h>
 #include <stddef.h>
 
-#include "ethtool-util.h"
+#include "internal.h"
 
 /* Ethtool get_regs complex data.
  * we want to get not just EMAC registers, but also MAL, ZMII, RGMII, TAH
diff --git a/igb.c b/igb.c
index 4b836d9..ec35d36 100644
--- a/igb.c
+++ b/igb.c
@@ -1,6 +1,6 @@
 /* Copyright (c) 2007 Intel Corporation */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 /* Register Bit Masks */
 /* Device Control */
diff --git a/ethtool-util.h b/internal.h
similarity index 86%
rename from ethtool-util.h
rename to internal.h
index 79be7f2..693b091 100644
--- a/ethtool-util.h
+++ b/internal.h
@@ -1,7 +1,7 @@
 /* Portions Copyright 2001 Sun Microsystems (thockin@sun.com) */
 /* Portions Copyright 2002 Intel (scott.feldman@intel.com) */
-#ifndef ETHTOOL_UTIL_H__
-#define ETHTOOL_UTIL_H__
+#ifndef ETHTOOL_INTERNAL_H__
+#define ETHTOOL_INTERNAL_H__
 
 #ifdef HAVE_CONFIG_H
 #include "ethtool-config.h"
@@ -57,6 +57,27 @@ static inline u64 cpu_to_be64(u64 value)
 #define ntohll cpu_to_be64
 #define htonll cpu_to_be64
 
+#define BITS_PER_BYTE		8
+#define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
+#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
+#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
+
+static inline void set_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] |= 1UL << (nr % BITS_PER_LONG);
+}
+
+static inline void clear_bit(int nr, unsigned long *addr)
+{
+	addr[nr / BITS_PER_LONG] &= ~(1UL << (nr % BITS_PER_LONG));
+}
+
+static inline int test_bit(unsigned int nr, const unsigned long *addr)
+{
+	return !!((1UL << (nr % BITS_PER_LONG)) &
+		  (((unsigned long *)addr)[nr / BITS_PER_LONG]));
+}
+
 #ifndef ARRAY_SIZE
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #endif
@@ -140,4 +161,4 @@ int rxclass_rule_ins(int fd, struct ifreq *ifr,
 		     struct ethtool_rx_flow_spec *fsp);
 int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
 
-#endif /* ETHTOOL_UTIL_H__ */
+#endif /* ETHTOOL_INTERNAL_H__ */
diff --git a/ixgb.c b/ixgb.c
index 00c90d3..8687c21 100644
--- a/ixgb.c
+++ b/ixgb.c
@@ -1,6 +1,6 @@
 /* Copyright (c) 2006 Intel Corporation */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 /* CTRL0 Bit Masks */
 #define IXGB_CTRL0_LRST           0x00000008
diff --git a/ixgbe.c b/ixgbe.c
index e64d34a..dae11d4 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -1,6 +1,6 @@
 /* Copyright (c) 2007 Intel Corporation */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 /* Register Bit Masks */
 #define IXGBE_FCTRL_SBP            0x00000002
diff --git a/marvell.c b/marvell.c
index af38c21..e583c82 100644
--- a/marvell.c
+++ b/marvell.c
@@ -7,7 +7,7 @@
 
 #include <stdio.h>
 
-#include "ethtool-util.h"
+#include "internal.h"
 
 static void dump_addr(int n, const u8 *a)
 {
diff --git a/natsemi.c b/natsemi.c
index 24a7cb3..eaf83e2 100644
--- a/natsemi.c
+++ b/natsemi.c
@@ -1,6 +1,6 @@
 /* Copyright 2001 Sun Microsystems (thockin@sun.com) */
 #include <stdio.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #define PCI_VENDOR_NATSEMI		0x100b
 #define PCI_DEVICE_DP83815		0x0020
diff --git a/pcnet32.c b/pcnet32.c
index 1dac02d..b87cee7 100644
--- a/pcnet32.c
+++ b/pcnet32.c
@@ -2,7 +2,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #define BIT0  0x0001
 #define BIT1  0x0002
diff --git a/realtek.c b/realtek.c
index 11ed835..c3d7ae5 100644
--- a/realtek.c
+++ b/realtek.c
@@ -1,7 +1,7 @@
 /* Copyright 2001 Sun Microsystems (thockin@sun.com) */
 #include <stdio.h>
 #include <stdlib.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
diff --git a/rxclass.c b/rxclass.c
index b227901..809b073 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -10,8 +10,7 @@
 
 #include <linux/sockios.h>
 #include <arpa/inet.h>
-#include "ethtool-util.h"
-#include "ethtool-bitops.h"
+#include "internal.h"
 
 static void invert_flow_mask(struct ethtool_rx_flow_spec *fsp)
 {
diff --git a/sfc.c b/sfc.c
index c8ca74a..46a617b 100644
--- a/sfc.c
+++ b/sfc.c
@@ -9,7 +9,7 @@
 
 #include <stdio.h>
 #include <string.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #ifndef ARRAY_SIZE
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
diff --git a/smsc911x.c b/smsc911x.c
index 1aa39a1..c55b97b 100644
--- a/smsc911x.c
+++ b/smsc911x.c
@@ -1,6 +1,6 @@
 #include <stdio.h>
 #include <string.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
diff --git a/stmmac.c b/stmmac.c
index ad4311c..fb69bfe 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -12,7 +12,7 @@
 
 #include <stdio.h>
 #include <string.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs)
diff --git a/tg3.c b/tg3.c
index 4868504..3232339 100644
--- a/tg3.c
+++ b/tg3.c
@@ -1,6 +1,6 @@
 #include <stdio.h>
 #include <string.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 #define TG3_MAGIC 0x669955aa
 
diff --git a/vioc.c b/vioc.c
index c771737..eff533d 100644
--- a/vioc.c
+++ b/vioc.c
@@ -2,7 +2,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
-#include "ethtool-util.h"
+#include "internal.h"
 
 struct regs_line {
 		u32	addr;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
