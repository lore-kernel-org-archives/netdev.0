From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 5/6] net: Added cpumask_parse
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.61E2D412793@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19847 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769AbYCEUvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the cpumask_parse function that allows parsing of a kernel buffer (analogous to bitmap_parse).

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/cpumask net-2.6/include/linux/cpumask.h net-2.6.patch/include/linux/cpumask.h
--- net-2.6/include/linux/cpumask.h	2008-03-05 09:03:20.130056000 -0800
+++ net-2.6.patch/include/linux/cpumask.h	2008-03-05 09:25:33.435758000 -0800
@@ -49,6 +49,7 @@
  * unsigned long *cpus_addr(mask)	Array of unsigned long's in mask
  *
  * int cpumask_scnprintf(buf, len, mask) Format cpumask for printing
+ * int cpumask_parse(ubuf, ulen, mask)	Parse ascii string as cpumask
  * int cpumask_parse_user(ubuf, ulen, mask)	Parse ascii string as cpumask
  * int cpulist_scnprintf(buf, len, mask) Format cpumask as list for printing
  * int cpulist_parse(buf, map)		Parse ascii string as cpulist
@@ -273,6 +274,14 @@ static inline int __cpumask_scnprintf(ch
 	return bitmap_scnprintf(buf, len, srcp->bits, nbits);
 }
 
+#define cpumask_parse(ubuf, ulen, dst) \
+			__cpumask_parse((ubuf), (ulen), &(dst), NR_CPUS)
+static inline int __cpumask_parse(const char __user *buf, int len,
+					cpumask_t *dstp, int nbits)
+{
+	return bitmap_parse(buf, len, dstp->bits, nbits);
+}
+
 #define cpumask_parse_user(ubuf, ulen, dst) \
 			__cpumask_parse_user((ubuf), (ulen), &(dst), NR_CPUS)
 static inline int __cpumask_parse_user(const char __user *buf, int len,
