From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2] ipv4,ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL
Date: Fri, 26 Jul 2013 17:05:16 +0200
Message-ID: <20130726150516.GC3890@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bcrl@kvack.org, william.manley@youview.com, luky-37@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41351 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab3GZPFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:05:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
a) Also send ipv4 igmp messages with TC_PRIO_CONTROL

Cc: William Manley <william.manley@youview.com>
Cc: Lukas Tribus <luky-37@hotmail.com>
Acked-by: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/igmp.c  | 3 +++
 net/ipv6/mcast.c | 4 +++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 375aca3..ef76186 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -88,6 +88,7 @@
 #include <linux/if_arp.h>
 #include <linux/rtnetlink.h>
 #include <linux/times.h>
+#include <linux/pkt_sched.h>
 
 #include <net/net_namespace.h>
 #include <net/arp.h>
@@ -315,6 +316,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 		if (size < 256)
 			return NULL;
 	}
+	skb->priority = TC_PRIO_CONTROL;
 	igmp_skb_size(skb) = size;
 
 	rt = ip_route_output_ports(net, &fl4, NULL, IGMPV3_ALL_MCR, 0,
@@ -670,6 +672,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		ip_rt_put(rt);
 		return -1;
 	}
+	skb->priority = TC_PRIO_CONTROL;
 
 	skb_dst_set(skb, &rt->dst);
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 99cd65c..db25b8e 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -44,6 +44,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/pkt_sched.h>
 #include <net/mld.h>
 
 #include <linux/netfilter.h>
@@ -1376,6 +1377,7 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
 	if (!skb)
 		return NULL;
 
+	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, hlen);
 
 	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
@@ -1769,7 +1771,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		rcu_read_unlock();
 		return;
 	}
-
+	skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(skb, hlen);
 
 	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
-- 
1.8.3.1
