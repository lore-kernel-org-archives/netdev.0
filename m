From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 06/12] headers, netfilter: Use kernel type names __u8,
 __u16, __u32
Date: Mon, 08 Aug 2011 14:19:27 +0100
Message-ID: <1312809567.2591.1145.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These types are guaranteed to be defined by <linux/types.h> for
both userland and kernel, unlike u_intN_t.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netfilter_arp/arp_tables.h  |   14 +++++++-------
 include/linux/netfilter_ipv4/ip_tables.h  |   20 ++++++++++----------
 include/linux/netfilter_ipv6/ip6_tables.h |   22 +++++++++++-----------
 3 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index adbf4bf..e08565d 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -52,7 +52,7 @@ struct arpt_arp {
 	struct in_addr smsk, tmsk;
 
 	/* Device hw address length, src+target device addresses */
-	u_int8_t arhln, arhln_mask;
+	__u8 arhln, arhln_mask;
 	struct arpt_devaddr_info src_devaddr;
 	struct arpt_devaddr_info tgt_devaddr;
 
@@ -71,9 +71,9 @@ struct arpt_arp {
 	unsigned char iniface_mask[IFNAMSIZ], outiface_mask[IFNAMSIZ];
 
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int16_t invflags;
+	__u16 invflags;
 };
 
 /* Values for "flag" field in struct arpt_ip (general arp structure).
@@ -102,9 +102,9 @@ struct arpt_entry
 	struct arpt_arp arp;
 
 	/* Size of arpt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of arpt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
 
 	/* Back pointer */
 	unsigned int comefrom;
@@ -260,8 +260,8 @@ extern unsigned int arpt_do_table(struct sk_buff *skb,
 
 struct compat_arpt_entry {
 	struct arpt_arp arp;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 64a5d95..db79231 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -81,12 +81,12 @@ struct ipt_ip {
 	unsigned char iniface_mask[IFNAMSIZ], outiface_mask[IFNAMSIZ];
 
 	/* Protocol, 0 = ANY */
-	u_int16_t proto;
+	__u16 proto;
 
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int8_t invflags;
+	__u8 invflags;
 };
 
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
@@ -114,9 +114,9 @@ struct ipt_entry {
 	unsigned int nfcache;
 
 	/* Size of ipt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of ipt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
 
 	/* Back pointer */
 	unsigned int comefrom;
@@ -149,9 +149,9 @@ struct ipt_entry {
 
 /* ICMP matching stuff */
 struct ipt_icmp {
-	u_int8_t type;				/* type to match */
-	u_int8_t code[2];			/* range of code */
-	u_int8_t invflags;			/* Inverse flags */
+	__u8 type;				/* type to match */
+	__u8 code[2];				/* range of code */
+	__u8 invflags;				/* Inverse flags */
 };
 
 /* Values for "inv" field for struct ipt_icmp. */
@@ -288,8 +288,8 @@ extern unsigned int ipt_do_table(struct sk_buff *skb,
 struct compat_ipt_entry {
 	struct ipt_ip ip;
 	compat_uint_t nfcache;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index c9784f7..f549adc 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -81,14 +81,14 @@ struct ip6t_ip6 {
 	 *   MH do not match any packets.
 	 * - You also need to set IP6T_FLAGS_PROTO to "flags" to check protocol.
 	 */
-	u_int16_t proto;
+	__u16 proto;
 	/* TOS to match iff flags & IP6T_F_TOS */
-	u_int8_t tos;
+	__u8 tos;
 
 	/* Flags word */
-	u_int8_t flags;
+	__u8 flags;
 	/* Inverse flags */
-	u_int8_t invflags;
+	__u8 invflags;
 };
 
 /* Values for "flag" field in struct ip6t_ip6 (general ip6 structure). */
@@ -118,9 +118,9 @@ struct ip6t_entry {
 	unsigned int nfcache;
 
 	/* Size of ipt_entry + matches */
-	u_int16_t target_offset;
+	__u16 target_offset;
 	/* Size of ipt_entry + matches + target */
-	u_int16_t next_offset;
+	__u16 next_offset;
 
 	/* Back pointer */
 	unsigned int comefrom;
@@ -186,9 +186,9 @@ struct ip6t_error {
 
 /* ICMP matching stuff */
 struct ip6t_icmp {
-	u_int8_t type;				/* type to match */
-	u_int8_t code[2];			/* range of code */
-	u_int8_t invflags;			/* Inverse flags */
+	__u8 type;				/* type to match */
+	__u8 code[2];				/* range of code */
+	__u8 invflags;				/* Inverse flags */
 };
 
 /* Values for "inv" field for struct ipt_icmp. */
@@ -298,8 +298,8 @@ extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 struct compat_ip6t_entry {
 	struct ip6t_ip6 ipv6;
 	compat_uint_t nfcache;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
+	__u16 target_offset;
+	__u16 next_offset;
 	compat_uint_t comefrom;
 	struct compat_xt_counters counters;
 	unsigned char elems[0];
-- 
1.7.5.4



