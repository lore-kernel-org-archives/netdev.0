From: avi.kp.137@gmail.com
Subject: [PATCH 5/5] net: ethernet: eth.c: removed checkpatch warnings and errors
Date: Thu, 19 Sep 2013 21:36:50 +0530
Message-ID: <523b2124.645d440a.1c55.0f75@mx.google.com>
Cc: akong@redhat.com, stefanha@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Avinash Kumar <avi.kp.137@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avinash Kumar <avi.kp.137@gmail.com>

removed these checkpatch.pl warnings:
net/ethernet/eth.c:61: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
net/ethernet/eth.c:136: WARNING: Prefer netdev_dbg(netdev, ... then dev_dbg(dev, ... then pr_debug(...  to printk(KERN_DEBUG ...
net/ethernet/eth.c:181: ERROR: space prohibited before that close parenthesis ')'

Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>
---
 net/ethernet/eth.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index be1f64d..9bd3c31 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -58,7 +58,7 @@
 #include <net/ipv6.h>
 #include <net/ip.h>
 #include <net/dsa.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 __setup("ether=", netdev_boot_setup);
 
@@ -133,7 +133,7 @@ int eth_rebuild_header(struct sk_buff *skb)
 		return arp_find(eth->h_dest, skb);
 #endif
 	default:
-		printk(KERN_DEBUG
+		netdev_dbg(dev,
 		       "%s: unable to resolve type %X addresses.\n",
 		       dev->name, ntohs(eth->h_proto));
 
@@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      seems to set IFF_PROMISC.
 	 */
 
-	else if (1 /*dev->flags&IFF_PROMISC */ ) {
+	else if (1 /*dev->flags&IFF_PROMISC */) {
 		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
 						      dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
-- 
1.7.10.4
