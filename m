From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skbuff more likely/unlikely
Date: Thu, 2 Oct 2003 10:24:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002102420.6e1cece9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A couple more places where we can help by hinting the compiler
for 2.6.0-test6.  If we are pulling off header, is is likely there;
and skb alloc's succeed in the normal case.

Thought I saw an earlier similar patch, but here is my take on it.

diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	Thu Oct  2 10:01:36 2003
+++ b/include/linux/skbuff.h	Thu Oct  2 10:01:36 2003
@@ -885,7 +885,7 @@
  */
 static inline unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
 {
-	return (len > skb->len) ? NULL : __skb_pull(skb, len);
+	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
 }
 
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
@@ -901,7 +901,7 @@
 
 static inline unsigned char *pskb_pull(struct sk_buff *skb, unsigned int len)
 {
-	return (len > skb->len) ? NULL : __pskb_pull(skb, len);
+	return unlikely(len > skb->len) ? NULL : __pskb_pull(skb, len);
 }
 
 static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
@@ -1052,7 +1052,7 @@
 					      int gfp_mask)
 {
 	struct sk_buff *skb = alloc_skb(length + 16, gfp_mask);
-	if (skb)
+	if (likely(skb))
 		skb_reserve(skb, 16);
 	return skb;
 }
