From: Joe Perches <joe@perches.com>
Subject: [PATCH] include/linux/icmpv6.h - remove duplicate include
Date: Sun, 09 Mar 2008 16:55:28 -0700
Message-ID: <1205106928.656.102.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4373 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbYCIX4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 19:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate #include <linux/skbuff.h>
Combine #ifdef __KERNEL__ blocks
Neaten function prototypes

Signed-off-by: Joe Perches <joe@perches.com>

 include/linux/icmpv6.h |   32 +++++++++++---------------------
 1 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 7c5e981..5185ffa 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -75,15 +75,6 @@ struct icmp6hdr {
 #define icmp6_router_pref	icmp6_dataun.u_nd_ra.router_pref
 };
 
-#ifdef __KERNEL__
-#include <linux/skbuff.h>
-
-static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)
-{
-	return (struct icmp6hdr *)skb_transport_header(skb);
-}
-#endif
-
 #define ICMPV6_ROUTER_PREF_LOW		0x3
 #define ICMPV6_ROUTER_PREF_MEDIUM	0x0
 #define ICMPV6_ROUTER_PREF_HIGH		0x1
@@ -166,22 +157,21 @@ struct icmp6_filter {
 #define MLD2_ALL_MCR_INIT { { { 0xff,0x02,0,0,0,0,0,0,0,0,0,0,0,0,0,0x16 } } }
 
 #ifdef __KERNEL__
-
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 
+static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)
+{
+	return (struct icmp6hdr *)skb_transport_header(skb);
+}
 
-extern void				icmpv6_send(struct sk_buff *skb,
-						    int type, int code,
-						    __u32 info, 
-						    struct net_device *dev);
+extern void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
+			struct net_device *dev);
 
-extern int				icmpv6_init(struct net_proto_family *ops);
-extern int				icmpv6_err_convert(int type, int code,
-							   int *err);
-extern void				icmpv6_cleanup(void);
-extern void				icmpv6_param_prob(struct sk_buff *skb,
-							  int code, int pos);
+extern int icmpv6_init(struct net_proto_family *ops);
+extern int icmpv6_err_convert(int type, int code, int *err);
+extern void icmpv6_cleanup(void);
+extern void icmpv6_param_prob(struct sk_buff *skb, int code, int pos);
 #endif
 
 #endif


