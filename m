From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] rtnetlink.c: #if 0 no longer used functions
Date: Wed, 30 Jan 2008 22:02:57 +0200
Message-ID: <20080130200257.GD29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40726 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759985AbYA3UCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:02:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch #if 0's the following no longer used functions:
- rtattr_parse()
- rtattr_strlcpy()
- __rtattr_parse_nested_compat()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/rtnetlink.h |   12 ------------
 net/core/rtnetlink.c      |    9 ++++++---
 2 files changed, 6 insertions(+), 15 deletions(-)

06cd9ace5f9ca3d8070364d33ca76d1fa4cd203b 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b014f6b..b9e1740 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -602,24 +602,12 @@ struct tcamsg
 
 #include <linux/mutex.h>
 
-extern size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size);
 static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 {
 	int len = strlen(str) + 1;
 	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
 }
 
-extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
-extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-				        struct rtattr *rta, int len);
-
-#define rtattr_parse_nested(tb, max, rta) \
-	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
-
-#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
-({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
-	__rtattr_parse_nested_compat(tb, max, rta, len); })
-
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
 extern int rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ddbdde8..a689f17 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -82,6 +82,8 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
+#if 0
+
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr*)*maxattr);
@@ -108,6 +110,8 @@ int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
 	return 0;
 }
 
+#endif  /*  0  */
+
 static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
@@ -442,6 +446,7 @@ void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data
 	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
 }
 
+#if 0
 size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size)
 {
 	size_t ret = RTA_PAYLOAD(rta);
@@ -456,6 +461,7 @@ size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size)
 	}
 	return ret;
 }
+#endif  /*  0  */
 
 int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group, int echo)
 {
@@ -1411,9 +1417,6 @@ void __init rtnetlink_init(void)
 }
 
 EXPORT_SYMBOL(__rta_fill);
-EXPORT_SYMBOL(rtattr_strlcpy);
-EXPORT_SYMBOL(rtattr_parse);
-EXPORT_SYMBOL(__rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);

