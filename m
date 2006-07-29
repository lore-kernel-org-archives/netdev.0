From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 16/20] [PATCH] [IPV6] MIP6: Add Mobility header definition.
Date: Sat, 29 Jul 2006 18:39:00 +0900
Message-ID: <11541659402139-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:50819 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422718AbWG2JjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:39:01 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Mobility header definition for Mobile IPv6.
Based on MIPL2 kernel patch.
---
 include/linux/in6.h |    1 +
 include/net/flow.h  |    9 +++++++++
 include/net/ipv6.h  |    1 +
 include/net/mip6.h  |   23 +++++++++++++++++++++++
 4 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 086ec2a..d776829 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -134,6 +134,7 @@ #define IPPROTO_FRAGMENT	44	/* IPv6 frag
 #define IPPROTO_ICMPV6		58	/* ICMPv6			*/
 #define IPPROTO_NONE		59	/* IPv6 no next header		*/
 #define IPPROTO_DSTOPTS		60	/* IPv6 destination options	*/
+#define IPPROTO_MH		135	/* IPv6 mobility header		*/
 
 /*
  *	IPv6 TLV options.
diff --git a/include/net/flow.h b/include/net/flow.h
index 04d89f7..650dfaf 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -72,12 +72,21 @@ #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x0
 		} dnports;
 
 		__u32		spi;
+
+#ifdef CONFIG_IPV6_MIP6
+		struct {
+			__u8	type;
+		} mht;
+#endif
 	} uli_u;
 #define fl_ip_sport	uli_u.ports.sport
 #define fl_ip_dport	uli_u.ports.dport
 #define fl_icmp_type	uli_u.icmpt.type
 #define fl_icmp_code	uli_u.icmpt.code
 #define fl_ipsec_spi	uli_u.spi
+#ifdef CONFIG_IPV6_MIP6
+#define fl_mh_type	uli_u.mht.type
+#endif
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index cbe72ea..7688534 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -40,6 +40,7 @@ #define NEXTHDR_AUTH		51	/* Authenticati
 #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
 #define NEXTHDR_NONE		59	/* No next header */
 #define NEXTHDR_DEST		60	/* Destination options header. */
+#define NEXTHDR_MOBILITY	135	/* Mobility header. */
 
 #define NEXTHDR_MAX		255
 
diff --git a/include/net/mip6.h b/include/net/mip6.h
index 42b65ba..fd43178 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -28,6 +28,29 @@ #define _NET_MIP6_H
 #define MIP6_OPT_PAD_1	0
 #define MIP6_OPT_PAD_N	1
 
+/*
+ * Mobility Header
+ */
+struct ip6_mh {
+	__u8	ip6mh_proto;
+	__u8	ip6mh_hdrlen;
+	__u8	ip6mh_type;
+	__u8	ip6mh_reserved;
+	__u16	ip6mh_cksum;
+	/* Followed by type specific messages */
+	__u8	data[0];
+} __attribute__ ((__packed__));
+
+#define IP6_MH_TYPE_BRR		0   /* Binding Refresh Request */
+#define IP6_MH_TYPE_HOTI	1   /* HOTI Message   */
+#define IP6_MH_TYPE_COTI	2   /* COTI Message  */
+#define IP6_MH_TYPE_HOT		3   /* HOT Message   */
+#define IP6_MH_TYPE_COT		4   /* COT Message  */
+#define IP6_MH_TYPE_BU		5   /* Binding Update */
+#define IP6_MH_TYPE_BACK	6   /* Binding ACK */
+#define IP6_MH_TYPE_BERROR	7   /* Binding Error */
+#define IP6_MH_TYPE_MAX		IP6_MH_TYPE_BERROR
+
 extern int mip6_init(void);
 extern void mip6_fini(void);
 
-- 
1.4.1

