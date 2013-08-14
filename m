From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv4,ipv6: send arp/ndisc packets with TC_PRIO_CONTROL
Date: Thu, 15 Aug 2013 01:34:12 +0200
Message-ID: <20130814233412.GC13066@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52531 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381Ab3HNXeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 19:34:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already did this change for igmp/mld packets in commit
9d4a0314642918cbda9ed4012df51e8df608fce6 ("ipv4, ipv6: send igmpv3/mld
packets with TC_PRIO_CONTROL").

arp and ndisc are as important as mld/igmp for a working network, so
make the appropriate change here, too.

Cc: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/arp.c   | 2 ++
 net/ipv6/ndisc.c | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4429b01..4ed18371 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -92,6 +92,7 @@
 #include <linux/fddidevice.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
+#include <linux/pkt_sched.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/stat.h>
@@ -594,6 +595,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	skb_reset_network_header(skb);
 	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
+	skb->priority = TC_PRIO_CONTROL;
 	skb->protocol = htons(ETH_P_ARP);
 	if (src_hw == NULL)
 		src_hw = dev->dev_addr;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 79aa965..007f868 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -50,6 +50,7 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/jhash.h>
+#include <linux/pkt_sched.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -382,7 +383,7 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 			  __func__, err);
 		return NULL;
 	}
-
+	skb->priority = TC_PRIO_CONTROL;
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
-- 
1.8.3.1
