From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/23] netfilter: fix include files for compilation
Date: Fri, 18 Dec 2015 21:26:28 +0100
Message-ID: <1450470409-31427-3-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikko Rapeli <mikko.rapeli@iki.fi>

Add missing header dependencies and other small changes so that each file
compiles alone in userspace.

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h       |  2 ++
 include/uapi/linux/netfilter/ipset/ip_set_hash.h         |  2 ++
 include/uapi/linux/netfilter/ipset/ip_set_list.h         |  2 ++
 include/uapi/linux/netfilter/nf_conntrack_tuple_common.h |  3 +++
 include/uapi/linux/netfilter/xt_HMARK.h                  |  1 +
 include/uapi/linux/netfilter/xt_RATEEST.h                |  1 +
 include/uapi/linux/netfilter/xt_TEE.h                    |  2 ++
 include/uapi/linux/netfilter/xt_TPROXY.h                 |  1 +
 include/uapi/linux/netfilter/xt_hashlimit.h              |  1 +
 include/uapi/linux/netfilter/xt_ipvs.h                   |  1 +
 include/uapi/linux/netfilter/xt_mac.h                    |  2 ++
 include/uapi/linux/netfilter/xt_osf.h                    |  2 ++
 include/uapi/linux/netfilter/xt_physdev.h                |  2 +-
 include/uapi/linux/netfilter/xt_policy.h                 |  2 ++
 include/uapi/linux/netfilter/xt_rateest.h                |  1 +
 include/uapi/linux/netfilter/xt_recent.h                 |  1 +
 include/uapi/linux/netfilter/xt_sctp.h                   | 12 ++++++------
 include/uapi/linux/netfilter_arp/arp_tables.h            |  1 +
 include/uapi/linux/netfilter_bridge.h                    |  1 +
 include/uapi/linux/netfilter_bridge/ebt_arp.h            |  1 +
 include/uapi/linux/netfilter_bridge/ebt_arpreply.h       |  2 ++
 include/uapi/linux/netfilter_bridge/ebt_ip6.h            |  1 +
 include/uapi/linux/netfilter_bridge/ebt_nat.h            |  2 ++
 include/uapi/linux/netfilter_ipv4/ip_tables.h            |  1 +
 include/uapi/linux/netfilter_ipv6/ip6_tables.h           |  1 +
 include/uapi/linux/netfilter_ipv6/ip6t_rt.h              |  2 +-
 26 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/netfilter/ipset/ip_set_bitmap.h b/include/uapi/linux/netfilter/ipset/ip_set_bitmap.h
index 6a2c038..fd5024d 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set_bitmap.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set_bitmap.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__IP_SET_BITMAP_H
 #define _UAPI__IP_SET_BITMAP_H
 
+#include <linux/netfilter/ipset/ip_set.h>
+
 /* Bitmap type specific error codes */
 enum {
 	/* The element is out of the range of the set */
diff --git a/include/uapi/linux/netfilter/ipset/ip_set_hash.h b/include/uapi/linux/netfilter/ipset/ip_set_hash.h
index 352eecc..82deeb8 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set_hash.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set_hash.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__IP_SET_HASH_H
 #define _UAPI__IP_SET_HASH_H
 
+#include <linux/netfilter/ipset/ip_set.h>
+
 /* Hash type specific error codes */
 enum {
 	/* Hash is full */
diff --git a/include/uapi/linux/netfilter/ipset/ip_set_list.h b/include/uapi/linux/netfilter/ipset/ip_set_list.h
index a44efaa..84d4303 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set_list.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set_list.h
@@ -1,6 +1,8 @@
 #ifndef _UAPI__IP_SET_LIST_H
 #define _UAPI__IP_SET_LIST_H
 
+#include <linux/netfilter/ipset/ip_set.h>
+
 /* List type specific error codes */
 enum {
 	/* Set name to be added/deleted/tested does not exist. */
diff --git a/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h b/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
index 2f6bbc5..a9c3834 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
@@ -1,6 +1,9 @@
 #ifndef _NF_CONNTRACK_TUPLE_COMMON_H
 #define _NF_CONNTRACK_TUPLE_COMMON_H
 
+#include <linux/types.h>
+#include <linux/netfilter.h>
+
 enum ip_conntrack_dir {
 	IP_CT_DIR_ORIGINAL,
 	IP_CT_DIR_REPLY,
diff --git a/include/uapi/linux/netfilter/xt_HMARK.h b/include/uapi/linux/netfilter/xt_HMARK.h
index 826fc58..3fb48c8 100644
--- a/include/uapi/linux/netfilter/xt_HMARK.h
+++ b/include/uapi/linux/netfilter/xt_HMARK.h
@@ -2,6 +2,7 @@
 #define XT_HMARK_H_
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 enum {
 	XT_HMARK_SADDR_MASK,
diff --git a/include/uapi/linux/netfilter/xt_RATEEST.h b/include/uapi/linux/netfilter/xt_RATEEST.h
index 6605e20..ec1b570 100644
--- a/include/uapi/linux/netfilter/xt_RATEEST.h
+++ b/include/uapi/linux/netfilter/xt_RATEEST.h
@@ -2,6 +2,7 @@
 #define _XT_RATEEST_TARGET_H
 
 #include <linux/types.h>
+#include <linux/if.h>
 
 struct xt_rateest_target_info {
 	char			name[IFNAMSIZ];
diff --git a/include/uapi/linux/netfilter/xt_TEE.h b/include/uapi/linux/netfilter/xt_TEE.h
index 5c21d5c..0109202 100644
--- a/include/uapi/linux/netfilter/xt_TEE.h
+++ b/include/uapi/linux/netfilter/xt_TEE.h
@@ -1,6 +1,8 @@
 #ifndef _XT_TEE_TARGET_H
 #define _XT_TEE_TARGET_H
 
+#include <linux/netfilter.h>
+
 struct xt_tee_tginfo {
 	union nf_inet_addr gw;
 	char oif[16];
diff --git a/include/uapi/linux/netfilter/xt_TPROXY.h b/include/uapi/linux/netfilter/xt_TPROXY.h
index 902043c..8d693ee 100644
--- a/include/uapi/linux/netfilter/xt_TPROXY.h
+++ b/include/uapi/linux/netfilter/xt_TPROXY.h
@@ -2,6 +2,7 @@
 #define _XT_TPROXY_H
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 /* TPROXY target is capable of marking the packet to perform
  * redirection. We can get rid of that whenever we get support for
diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index cbfc43d..6db9037 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -2,6 +2,7 @@
 #define _UAPI_XT_HASHLIMIT_H
 
 #include <linux/types.h>
+#include <linux/if.h>
 
 /* timings are in milliseconds. */
 #define XT_HASHLIMIT_SCALE 10000
diff --git a/include/uapi/linux/netfilter/xt_ipvs.h b/include/uapi/linux/netfilter/xt_ipvs.h
index eff34ac..e03b9c3 100644
--- a/include/uapi/linux/netfilter/xt_ipvs.h
+++ b/include/uapi/linux/netfilter/xt_ipvs.h
@@ -2,6 +2,7 @@
 #define _XT_IPVS_H
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 enum {
 	XT_IPVS_IPVS_PROPERTY =	1 << 0, /* all other options imply this one */
diff --git a/include/uapi/linux/netfilter/xt_mac.h b/include/uapi/linux/netfilter/xt_mac.h
index b892cdc..9a19a08 100644
--- a/include/uapi/linux/netfilter/xt_mac.h
+++ b/include/uapi/linux/netfilter/xt_mac.h
@@ -1,6 +1,8 @@
 #ifndef _XT_MAC_H
 #define _XT_MAC_H
 
+#include <linux/if_ether.h>
+
 struct xt_mac_info {
     unsigned char srcaddr[ETH_ALEN];
     int invert;
diff --git a/include/uapi/linux/netfilter/xt_osf.h b/include/uapi/linux/netfilter/xt_osf.h
index 5d66cae..e615995 100644
--- a/include/uapi/linux/netfilter/xt_osf.h
+++ b/include/uapi/linux/netfilter/xt_osf.h
@@ -20,6 +20,8 @@
 #define _XT_OSF_H
 
 #include <linux/types.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
 
 #define MAXGENRELEN		32
 
diff --git a/include/uapi/linux/netfilter/xt_physdev.h b/include/uapi/linux/netfilter/xt_physdev.h
index db7a298..ccdde87 100644
--- a/include/uapi/linux/netfilter/xt_physdev.h
+++ b/include/uapi/linux/netfilter/xt_physdev.h
@@ -2,7 +2,7 @@
 #define _UAPI_XT_PHYSDEV_H
 
 #include <linux/types.h>
-
+#include <linux/if.h>
 
 #define XT_PHYSDEV_OP_IN		0x01
 #define XT_PHYSDEV_OP_OUT		0x02
diff --git a/include/uapi/linux/netfilter/xt_policy.h b/include/uapi/linux/netfilter/xt_policy.h
index be8ead0..d8a9800 100644
--- a/include/uapi/linux/netfilter/xt_policy.h
+++ b/include/uapi/linux/netfilter/xt_policy.h
@@ -2,6 +2,8 @@
 #define _XT_POLICY_H
 
 #include <linux/types.h>
+#include <linux/in.h>
+#include <linux/in6.h>
 
 #define XT_POLICY_MAX_ELEM	4
 
diff --git a/include/uapi/linux/netfilter/xt_rateest.h b/include/uapi/linux/netfilter/xt_rateest.h
index d40a619..13fe50d 100644
--- a/include/uapi/linux/netfilter/xt_rateest.h
+++ b/include/uapi/linux/netfilter/xt_rateest.h
@@ -2,6 +2,7 @@
 #define _XT_RATEEST_MATCH_H
 
 #include <linux/types.h>
+#include <linux/if.h>
 
 enum xt_rateest_match_flags {
 	XT_RATEEST_MATCH_INVERT	= 1<<0,
diff --git a/include/uapi/linux/netfilter/xt_recent.h b/include/uapi/linux/netfilter/xt_recent.h
index 6ef36c1..955d562 100644
--- a/include/uapi/linux/netfilter/xt_recent.h
+++ b/include/uapi/linux/netfilter/xt_recent.h
@@ -2,6 +2,7 @@
 #define _LINUX_NETFILTER_XT_RECENT_H 1
 
 #include <linux/types.h>
+#include <linux/netfilter.h>
 
 enum {
 	XT_RECENT_CHECK    = 1 << 0,
diff --git a/include/uapi/linux/netfilter/xt_sctp.h b/include/uapi/linux/netfilter/xt_sctp.h
index 29287be..58ffcfb 100644
--- a/include/uapi/linux/netfilter/xt_sctp.h
+++ b/include/uapi/linux/netfilter/xt_sctp.h
@@ -66,26 +66,26 @@ struct xt_sctp_info {
 
 #define SCTP_CHUNKMAP_IS_CLEAR(chunkmap) \
 	__sctp_chunkmap_is_clear((chunkmap), ARRAY_SIZE(chunkmap))
-static inline bool
+static inline _Bool
 __sctp_chunkmap_is_clear(const __u32 *chunkmap, unsigned int n)
 {
 	unsigned int i;
 	for (i = 0; i < n; ++i)
 		if (chunkmap[i])
-			return false;
-	return true;
+			return 0;
+	return 1;
 }
 
 #define SCTP_CHUNKMAP_IS_ALL_SET(chunkmap) \
 	__sctp_chunkmap_is_all_set((chunkmap), ARRAY_SIZE(chunkmap))
-static inline bool
+static inline _Bool
 __sctp_chunkmap_is_all_set(const __u32 *chunkmap, unsigned int n)
 {
 	unsigned int i;
 	for (i = 0; i < n; ++i)
 		if (chunkmap[i] != ~0U)
-			return false;
-	return true;
+			return 0;
+	return 1;
 }
 
 #endif /* _XT_SCTP_H_ */
diff --git a/include/uapi/linux/netfilter_arp/arp_tables.h b/include/uapi/linux/netfilter_arp/arp_tables.h
index a5a86a4..ece3ad4 100644
--- a/include/uapi/linux/netfilter_arp/arp_tables.h
+++ b/include/uapi/linux/netfilter_arp/arp_tables.h
@@ -11,6 +11,7 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/if.h>
 #include <linux/netfilter_arp.h>
 
 #include <linux/netfilter/x_tables.h>
diff --git a/include/uapi/linux/netfilter_bridge.h b/include/uapi/linux/netfilter_bridge.h
index a5eda6d..514519b 100644
--- a/include/uapi/linux/netfilter_bridge.h
+++ b/include/uapi/linux/netfilter_bridge.h
@@ -4,6 +4,7 @@
 /* bridge-specific defines for netfilter. 
  */
 
+#include <linux/in.h>
 #include <linux/netfilter.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
diff --git a/include/uapi/linux/netfilter_bridge/ebt_arp.h b/include/uapi/linux/netfilter_bridge/ebt_arp.h
index 522f3e4..dd4df25 100644
--- a/include/uapi/linux/netfilter_bridge/ebt_arp.h
+++ b/include/uapi/linux/netfilter_bridge/ebt_arp.h
@@ -2,6 +2,7 @@
 #define __LINUX_BRIDGE_EBT_ARP_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 #define EBT_ARP_OPCODE 0x01
 #define EBT_ARP_HTYPE 0x02
diff --git a/include/uapi/linux/netfilter_bridge/ebt_arpreply.h b/include/uapi/linux/netfilter_bridge/ebt_arpreply.h
index 7e77896..6fee340 100644
--- a/include/uapi/linux/netfilter_bridge/ebt_arpreply.h
+++ b/include/uapi/linux/netfilter_bridge/ebt_arpreply.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_ARPREPLY_H
 #define __LINUX_BRIDGE_EBT_ARPREPLY_H
 
+#include <linux/if_ether.h>
+
 struct ebt_arpreply_info {
 	unsigned char mac[ETH_ALEN];
 	int target;
diff --git a/include/uapi/linux/netfilter_bridge/ebt_ip6.h b/include/uapi/linux/netfilter_bridge/ebt_ip6.h
index 42b8896..a062f0c 100644
--- a/include/uapi/linux/netfilter_bridge/ebt_ip6.h
+++ b/include/uapi/linux/netfilter_bridge/ebt_ip6.h
@@ -13,6 +13,7 @@
 #define __LINUX_BRIDGE_EBT_IP6_H
 
 #include <linux/types.h>
+#include <linux/in6.h>
 
 #define EBT_IP6_SOURCE 0x01
 #define EBT_IP6_DEST 0x02
diff --git a/include/uapi/linux/netfilter_bridge/ebt_nat.h b/include/uapi/linux/netfilter_bridge/ebt_nat.h
index 5e74e3b..c990d74 100644
--- a/include/uapi/linux/netfilter_bridge/ebt_nat.h
+++ b/include/uapi/linux/netfilter_bridge/ebt_nat.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_BRIDGE_EBT_NAT_H
 #define __LINUX_BRIDGE_EBT_NAT_H
 
+#include <linux/if_ether.h>
+
 #define NAT_ARP_BIT  (0x00000010)
 struct ebt_nat_info {
 	unsigned char mac[ETH_ALEN];
diff --git a/include/uapi/linux/netfilter_ipv4/ip_tables.h b/include/uapi/linux/netfilter_ipv4/ip_tables.h
index f1e6ef2..d0da53d 100644
--- a/include/uapi/linux/netfilter_ipv4/ip_tables.h
+++ b/include/uapi/linux/netfilter_ipv4/ip_tables.h
@@ -17,6 +17,7 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/if.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <linux/netfilter/x_tables.h>
diff --git a/include/uapi/linux/netfilter_ipv6/ip6_tables.h b/include/uapi/linux/netfilter_ipv6/ip6_tables.h
index 649c680..d1b2265 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6_tables.h
@@ -17,6 +17,7 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/if.h>
 #include <linux/netfilter_ipv6.h>
 
 #include <linux/netfilter/x_tables.h>
diff --git a/include/uapi/linux/netfilter_ipv6/ip6t_rt.h b/include/uapi/linux/netfilter_ipv6/ip6t_rt.h
index 7605a5f..558f81e 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6t_rt.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6t_rt.h
@@ -2,7 +2,7 @@
 #define _IP6T_RT_H
 
 #include <linux/types.h>
-/*#include <linux/in6.h>*/
+#include <linux/in6.h>
 
 #define IP6T_RT_HOPS 16
 
-- 
2.1.4

