From: pablo@netfilter.org
Subject: [PATCH 02/23] netfilter: ipset: expose userspace-relevant parts in ip_set.h
Date: Thu,  8 Mar 2012 02:00:51 +0100
Message-ID: <1331168472-5820-3-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

iptables's libxt_SET.c depends on these.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index e7b06f5..e921766 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -11,6 +11,8 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/types.h>
+
 /* The protocol version */
 #define IPSET_PROTOCOL		6
 
@@ -168,19 +170,10 @@ enum ipset_adt {
 	IPSET_CADT_MAX,
 };
 
-#ifdef __KERNEL__
-#include <linux/ip.h>
-#include <linux/ipv6.h>
-#include <linux/netlink.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter/x_tables.h>
-#include <linux/vmalloc.h>
-#include <net/netlink.h>
-
 /* Sets are identified by an index in kernel space. Tweak with ip_set_id_t
  * and IPSET_INVALID_ID if you want to increase the max number of sets.
  */
-typedef u16 ip_set_id_t;
+typedef __u16 ip_set_id_t;
 
 #define IPSET_INVALID_ID		65535
 
@@ -203,6 +196,15 @@ enum ip_set_kopt {
 	IPSET_DIM_THREE_SRC = (1 << IPSET_DIM_THREE),
 };
 
+#ifdef __KERNEL__
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/vmalloc.h>
+#include <net/netlink.h>
+
 /* Set features */
 enum ip_set_feature {
 	IPSET_TYPE_IP_FLAG = 0,
@@ -453,6 +455,8 @@ bitmap_bytes(u32 a, u32 b)
 	return 4 * ((((b - a + 8) / 8) + 3) / 4);
 }
 
+#endif /* __KERNEL__ */
+
 /* Interface to iptables/ip6tables */
 
 #define SO_IP_SET		83
@@ -478,6 +482,4 @@ struct ip_set_req_version {
 	unsigned version;
 };
 
-#endif	/* __KERNEL__ */
-
 #endif /*_IP_SET_H */
-- 
1.7.7.3

