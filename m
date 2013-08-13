From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 2/2] netfilter: export xt_HMARK.h to userland
Date: Tue, 13 Aug 2013 15:05:39 +0200
Message-ID: <1376399139-4181-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1376399139-4181-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35730 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756929Ab3HMNGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 09:06:24 -0400
In-Reply-To: <1376399139-4181-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file contains the API for the target "HMARK", hence it should be exported
to userland.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netfilter/xt_HMARK.h      | 50 ---------------------------------
 include/uapi/linux/netfilter/Kbuild     |  1 +
 include/uapi/linux/netfilter/xt_HMARK.h | 50 +++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 50 deletions(-)
 delete mode 100644 include/linux/netfilter/xt_HMARK.h
 create mode 100644 include/uapi/linux/netfilter/xt_HMARK.h

diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
deleted file mode 100644
index 826fc5807577..000000000000
--- a/include/linux/netfilter/xt_HMARK.h
+++ /dev/null
@@ -1,50 +0,0 @@
-#ifndef XT_HMARK_H_
-#define XT_HMARK_H_
-
-#include <linux/types.h>
-
-enum {
-	XT_HMARK_SADDR_MASK,
-	XT_HMARK_DADDR_MASK,
-	XT_HMARK_SPI,
-	XT_HMARK_SPI_MASK,
-	XT_HMARK_SPORT,
-	XT_HMARK_DPORT,
-	XT_HMARK_SPORT_MASK,
-	XT_HMARK_DPORT_MASK,
-	XT_HMARK_PROTO_MASK,
-	XT_HMARK_RND,
-	XT_HMARK_MODULUS,
-	XT_HMARK_OFFSET,
-	XT_HMARK_CT,
-	XT_HMARK_METHOD_L3,
-	XT_HMARK_METHOD_L3_4,
-};
-#define XT_HMARK_FLAG(flag)	(1 << flag)
-
-union hmark_ports {
-	struct {
-		__u16	src;
-		__u16	dst;
-	} p16;
-	struct {
-		__be16	src;
-		__be16	dst;
-	} b16;
-	__u32	v32;
-	__be32	b32;
-};
-
-struct xt_hmark_info {
-	union nf_inet_addr	src_mask;
-	union nf_inet_addr	dst_mask;
-	union hmark_ports	port_mask;
-	union hmark_ports	port_set;
-	__u32			flags;
-	__u16			proto_mask;
-	__u32			hashrnd;
-	__u32			hmodulus;
-	__u32			hoffset;	/* Mark offset to start from */
-};
-
-#endif /* XT_HMARK_H_ */
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index dc00927ffd62..174915420d3f 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -22,6 +22,7 @@ header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
 header-y += xt_CT.h
 header-y += xt_DSCP.h
+header-y += xt_HMARK.h
 header-y += xt_IDLETIMER.h
 header-y += xt_LED.h
 header-y += xt_LOG.h
diff --git a/include/uapi/linux/netfilter/xt_HMARK.h b/include/uapi/linux/netfilter/xt_HMARK.h
new file mode 100644
index 000000000000..826fc5807577
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_HMARK.h
@@ -0,0 +1,50 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+enum {
+	XT_HMARK_SADDR_MASK,
+	XT_HMARK_DADDR_MASK,
+	XT_HMARK_SPI,
+	XT_HMARK_SPI_MASK,
+	XT_HMARK_SPORT,
+	XT_HMARK_DPORT,
+	XT_HMARK_SPORT_MASK,
+	XT_HMARK_DPORT_MASK,
+	XT_HMARK_PROTO_MASK,
+	XT_HMARK_RND,
+	XT_HMARK_MODULUS,
+	XT_HMARK_OFFSET,
+	XT_HMARK_CT,
+	XT_HMARK_METHOD_L3,
+	XT_HMARK_METHOD_L3_4,
+};
+#define XT_HMARK_FLAG(flag)	(1 << flag)
+
+union hmark_ports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	struct {
+		__be16	src;
+		__be16	dst;
+	} b16;
+	__u32	v32;
+	__be32	b32;
+};
+
+struct xt_hmark_info {
+	union nf_inet_addr	src_mask;
+	union nf_inet_addr	dst_mask;
+	union hmark_ports	port_mask;
+	union hmark_ports	port_set;
+	__u32			flags;
+	__u16			proto_mask;
+	__u32			hashrnd;
+	__u32			hmodulus;
+	__u32			hoffset;	/* Mark offset to start from */
+};
+
+#endif /* XT_HMARK_H_ */
-- 
1.8.2.1
