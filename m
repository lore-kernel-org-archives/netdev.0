From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] add prefetch to skb_queue_walk
Date: Thu, 19 Jun 2003 12:13:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619121325.0a2059ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

skb_queue_walk macro can use prefetch's  (like list_for_each)

--- include/linux/skbuff.h.orig	2003-06-19 12:08:17.000000000 -0700
+++ include/linux/skbuff.h	2003-06-19 12:08:43.000000000 -0700
@@ -1149,9 +1149,9 @@
 }
 
 #define skb_queue_walk(queue, skb) \
-		for (skb = (queue)->next;			\
+		for (skb = (queue)->next, prefetch(skb->next);	\
 		     (skb != (struct sk_buff *)(queue));	\
-		     skb = skb->next)
+		     skb = skb->next, prefetch(skb->next))
 
 
 extern struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
