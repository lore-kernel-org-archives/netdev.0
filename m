From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] add likely/unlikely to pskb_may_pull
Date: Wed, 30 Jul 2003 16:18:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730161854.3cb03258.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Code that deals with received headers needs to be robust and use pskb_may_pull in many
places, but except in the case of DOS attacks, the packets are always correctly formed
so optimize for that case.

diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	Wed Jul 30 15:50:31 2003
+++ b/include/linux/skbuff.h	Wed Jul 30 15:50:31 2003
@@ -904,9 +904,9 @@
 
 static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
 {
-	if (len <= skb_headlen(skb))
+	if (likely(len <= skb_headlen(skb)))
 		return 1;
-	if (len > skb->len)
+	if (unlikely(len > skb->len))
 		return 0;
 	return __pskb_pull_tail(skb, len-skb_headlen(skb)) != NULL;
 }
