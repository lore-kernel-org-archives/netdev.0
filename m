From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skb_pull add unlikely
Date: Thu, 7 Aug 2003 14:21:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807142151.376e5b3c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yet another case where giving compiler hints may speed up packet fast path.


diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	Thu Aug  7 14:20:09 2003
+++ b/include/linux/skbuff.h	Thu Aug  7 14:20:09 2003
@@ -883,7 +883,7 @@
  */
 static inline unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
 {
-	return (len > skb->len) ? NULL : __skb_pull(skb, len);
+	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
 }
 
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
