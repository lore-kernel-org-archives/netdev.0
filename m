From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 31/44] [IPV6] MIP6: Add Mobility header definition.
Date: Thu, 24 Aug 2006 00:02:32 +0900
Message-ID: <11563453671944-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:8073 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964945AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453674137-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add Mobility header definition for Mobile IPv6.
Based on MIPL2 kernel patch.

This patch was also written by: Antti Tuominen <anttit@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
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
index 21d988b..e052291 100644
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
 	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8e6ec60..72bf47b 100644
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
1.4.0

