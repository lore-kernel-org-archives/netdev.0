From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] deliver_skb cleanup
Date: Tue, 24 Aug 2004 11:07:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824110711.3a1782d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup of deliver_skb: get rid of unused argument and use it
in the NET_CLS_ACT hook.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-08-24 11:05:51 -07:00
+++ b/net/core/dev.c	2004-08-24 11:05:51 -07:00
@@ -1676,7 +1676,7 @@
 }
 
 static __inline__ int deliver_skb(struct sk_buff *skb,
-				  struct packet_type *pt_prev, int last)
+				  struct packet_type *pt_prev)
 {
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev);
@@ -1691,7 +1691,7 @@
 {
 	int ret = NET_RX_DROP;
 	if (pt_prev)
-		ret = deliver_skb(skb, pt_prev, 0);
+		ret = deliver_skb(skb, pt_prev);
 
 	return ret;
 }
@@ -1791,15 +1791,14 @@
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev) 
-				ret = deliver_skb(skb, pt_prev, 0);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (pt_prev) {
-		atomic_inc(&skb->users);
-		ret = pt_prev->func(skb, skb->dev, pt_prev);
+		ret = deliver_skb(skb, pt_prev);
 		pt_prev = NULL; /* noone else should process this after*/
 	} else {
 		skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
@@ -1826,7 +1825,7 @@
 		if (ptype->type == type &&
 		    (!ptype->dev || ptype->dev == skb->dev)) {
 			if (pt_prev) 
-				ret = deliver_skb(skb, pt_prev, 0);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
