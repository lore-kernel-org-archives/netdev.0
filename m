From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] 2/3 rtnetlink -- RTA_PUT unlikely.
Date: Mon, 22 Sep 2003 16:36:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922163639.6d7ac30f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

RTA_PUT should normally be handed enough space, so optimize 

diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	Mon Sep 22 16:14:19 2003
+++ b/include/linux/rtnetlink.h	Mon Sep 22 16:14:19 2003
@@ -642,8 +642,9 @@
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
 
 #define RTA_PUT(skb, attrtype, attrlen, data) \
-({ if (skb_tailroom(skb) < (int)RTA_SPACE(attrlen)) goto rtattr_failure; \
-   __rta_fill(skb, attrtype, attrlen, data); })
+({	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		 goto rtattr_failure; \
+   	__rta_fill(skb, attrtype, attrlen, data); }) 
 
 static inline struct rtattr *
 __rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
@@ -658,8 +659,9 @@
 }
 
 #define __RTA_PUT(skb, attrtype, attrlen) \
-({ if (skb_tailroom(skb) < (int)RTA_SPACE(attrlen)) goto rtattr_failure; \
-   __rta_reserve(skb, attrtype, attrlen); })
+({ 	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		goto rtattr_failure; \
+   	__rta_reserve(skb, attrtype, attrlen); })
 
 extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
 
