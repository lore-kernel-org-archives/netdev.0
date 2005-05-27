From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/7] [RTNETLINK] Add RTA_(PUT|GET) shortcuts for u8, u16, and flag
Date: Fri, 27 May 2005 16:52:52 +0200
Message-ID: <20050527145252.GV15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit c49bbdd22621352b9b96097ffdb9e5c14b4ed95e
tree 6204e59b7aa59cf79632003c621e521db1297b1b
parent 0ecf7991c4f8532a5afc903e175e2bec80585fea
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:36:11 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:36:11 +0200

 include/linux/rtnetlink.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+)

Index: include/linux/rtnetlink.h
===================================================================
--- 07e28bf36ae4052536820a75bbefc6ac1c7a9098/include/linux/rtnetlink.h  (mode:100644)
+++ 6204e59b7aa59cf79632003c621e521db1297b1b/include/linux/rtnetlink.h  (mode:100644)
@@ -897,6 +897,14 @@
 		goto rtattr_failure; \
 	memcpy(skb_put(skb, RTA_ALIGN(attrlen)), data, attrlen); })
 
+#define RTA_PUT_U8(skb, attrtype, value) \
+({	u8 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u8), &_tmp); })
+
+#define RTA_PUT_U16(skb, attrtype, value) \
+({	u16 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u16), &_tmp); })
+
 #define RTA_PUT_U32(skb, attrtype, value) \
 ({	u32 _tmp = (value); \
 	RTA_PUT(skb, attrtype, sizeof(u32), &_tmp); })
@@ -914,6 +922,9 @@
 #define RTA_PUT_STRING(skb, attrtype, value) \
 	RTA_PUT(skb, attrtype, strlen(value) + 1, value)
 
+#define RTA_PUT_FLAG(skb, attrtype) \
+	RTA_PUT(skb, attrtype, 0, NULL);
+
 #define RTA_NEST(skb, type) \
 ({	struct rtattr *__start = (struct rtattr *) (skb)->tail; \
 	RTA_PUT(skb, type, 0, NULL); \
@@ -928,6 +939,16 @@
 		skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
 	-1; })
 
+#define RTA_GET_U8(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u8)) \
+		goto rtattr_failure; \
+	*(u8 *) RTA_DATA(rta); })
+
+#define RTA_GET_U16(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u16)) \
+		goto rtattr_failure; \
+	*(u16 *) RTA_DATA(rta); })
+
 #define RTA_GET_U32(rta) \
 ({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u32)) \
 		goto rtattr_failure; \
@@ -940,6 +961,8 @@
 	memcpy(&_tmp, RTA_DATA(rta), sizeof(_tmp)); \
 	_tmp; })
 
+#define RTA_GET_FLAG(rta) (!!(rta))
+
 #define RTA_GET_SECS(rta) ((unsigned long) RTA_GET_U64(rta) * HZ)
 #define RTA_GET_MSECS(rta) (msecs_to_jiffies((unsigned long) RTA_GET_U64(rta)))
 		
