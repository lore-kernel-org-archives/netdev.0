From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: dsmark should ignore ECN bits
Date: Mon, 27 Dec 2004 20:38:22 +0100
Message-ID: <20041227193822.GK7884@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Taking ECN bits into account doesn't make sense. The two bits were
still unused at the time the code was written so this brings back the
old behaviour.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/net/sched/sch_dsmark.c	2004-12-27 14:32:33.000000000 +0100
+++ linux-2.6.10-bk1/net/sched/sch_dsmark.c	2004-12-27 20:30:40.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/rtnetlink.h>
 #include <net/pkt_sched.h>
 #include <net/dsfield.h>
+#include <net/inet_ecn.h>
 #include <asm/byteorder.h>
 
 
@@ -198,10 +199,12 @@
 		/* FIXME: Safe with non-linear skbs? --RR */
 		switch (skb->protocol) {
 			case __constant_htons(ETH_P_IP):
-				skb->tc_index = ipv4_get_dsfield(skb->nh.iph);
+				skb->tc_index = ipv4_get_dsfield(skb->nh.iph)
+					& ~INET_ECN_MASK;
 				break;
 			case __constant_htons(ETH_P_IPV6):
-				skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h);
+				skb->tc_index = ipv6_get_dsfield(skb->nh.ipv6h)
+					& ~INET_ECN_MASK;
 				break;
 			default:
 				skb->tc_index = 0;
