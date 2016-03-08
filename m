From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 08/11] kernel-copy.h: import kernel.h from net-next and use it
Date: Mon,  7 Mar 2016 19:34:59 -0800
Message-ID: <1457408102-46662-9-git-send-email-ddecotig@gmail.com>
References: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33240 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638AbcCHDfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:35:21 -0500
Received: by mail-pf0-f196.google.com with SMTP id 63so355194pfe.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 19:35:20 -0800 (PST)
In-Reply-To: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This is required for recent version of ethtool.h .

This covers kernel.h up to:

  commit b5d3755a22e0cc4c369c0985aef0c52c2477c1e7
  Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
  Date:   Fri Mar 4 11:52:16 2016 +0100

      uapi: define DIV_ROUND_UP for userland


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c     |  3 ++-
 internal.h    |  4 ++--
 kernel-copy.h | 14 ++++++++++++++
 3 files changed, 18 insertions(+), 3 deletions(-)
 create mode 100644 kernel-copy.h

diff --git a/ethtool.c b/ethtool.c
index d349bee..47f0259 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -227,7 +227,8 @@ struct feature_defs {
 	struct feature_def def[0];
 };
 
-#define FEATURE_BITS_TO_BLOCKS(n_bits)		DIV_ROUND_UP(n_bits, 32U)
+#define FEATURE_BITS_TO_BLOCKS(n_bits)		\
+	__KERNEL_DIV_ROUND_UP(n_bits, 32U)
 #define FEATURE_WORD(blocks, index, field)	((blocks)[(index) / 32U].field)
 #define FEATURE_FIELD_FLAG(index)		(1U << (index) % 32U)
 #define FEATURE_BIT_SET(blocks, index, field)			\
diff --git a/internal.h b/internal.h
index e38d305..1c64306 100644
--- a/internal.h
+++ b/internal.h
@@ -35,6 +35,7 @@ typedef uint16_t u16;
 typedef uint8_t u8;
 typedef int32_t s32;
 
+#include "kernel-copy.h"
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
 
@@ -71,8 +72,7 @@ static inline u64 cpu_to_be64(u64 value)
 
 #define BITS_PER_BYTE		8
 #define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
-#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
-#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
+#define BITS_TO_LONGS(nr)	__KERNEL_DIV_ROUND_UP(nr, BITS_PER_LONG)
 
 static inline void set_bit(unsigned int nr, unsigned long *addr)
 {
diff --git a/kernel-copy.h b/kernel-copy.h
new file mode 100644
index 0000000..527549f
--- /dev/null
+++ b/kernel-copy.h
@@ -0,0 +1,14 @@
+#ifndef _LINUX_KERNEL_H
+#define _LINUX_KERNEL_H
+
+#include <linux/sysinfo.h>
+
+/*
+ * 'kernel.h' contains some often-used function prototypes etc
+ */
+#define __ALIGN_KERNEL(x, a)		__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
+#define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
+
+#define __KERNEL_DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
+
+#endif /* _LINUX_KERNEL_H */
-- 
2.7.0.rc3.207.g0ac5344
