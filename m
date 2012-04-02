From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 51/51] netlink: Delete all NLA_PUT*() macros.
Date: Sun,  1 Apr 2012 22:58:41 -0400
Message-ID: <1333335521-1348-52-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab2DBDAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:55 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

They were error prone due to an embedded goto, and the entire tree has
been converted away from using them.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netlink.h |   68 -------------------------------------------------
 1 files changed, 0 insertions(+), 68 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index efbd2c1..785f37a 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -102,20 +102,6 @@
  *   nla_put_flag(skb, type)		add flag attribute to skb
  *   nla_put_msecs(skb, type, jiffies)	add msecs attribute to skb
  *
- * Exceptions Based Attribute Construction:
- *   NLA_PUT(skb, type, len, data)	add attribute to skb
- *   NLA_PUT_U8(skb, type, value)	add u8 attribute to skb
- *   NLA_PUT_U16(skb, type, value)	add u16 attribute to skb
- *   NLA_PUT_U32(skb, type, value)	add u32 attribute to skb
- *   NLA_PUT_U64(skb, type, value)	add u64 attribute to skb
- *   NLA_PUT_STRING(skb, type, str)	add string attribute to skb
- *   NLA_PUT_FLAG(skb, type)		add flag attribute to skb
- *   NLA_PUT_MSECS(skb, type, jiffies)	add msecs attribute to skb
- *
- *   The meaning of these functions is equal to their lower case
- *   variants but they jump to the label nla_put_failure in case
- *   of a failure.
- *
  * Nested Attributes Construction:
  *   nla_nest_start(skb, type)		start a nested attribute
  *   nla_nest_end(skb, nla)		finalize a nested attribute
@@ -927,60 +913,6 @@ static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
 	return nla_put(skb, attrtype, sizeof(u64), &tmp);
 }
 
-#define NLA_PUT(skb, attrtype, attrlen, data) \
-	do { \
-		if (unlikely(nla_put(skb, attrtype, attrlen, data) < 0)) \
-			goto nla_put_failure; \
-	} while(0)
-
-#define NLA_PUT_TYPE(skb, type, attrtype, value) \
-	do { \
-		type __tmp = value; \
-		NLA_PUT(skb, attrtype, sizeof(type), &__tmp); \
-	} while(0)
-
-#define NLA_PUT_U8(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, u8, attrtype, value)
-
-#define NLA_PUT_U16(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, u16, attrtype, value)
-
-#define NLA_PUT_LE16(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, __le16, attrtype, value)
-
-#define NLA_PUT_BE16(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, __be16, attrtype, value)
-
-#define NLA_PUT_NET16(skb, attrtype, value) \
-	NLA_PUT_BE16(skb, attrtype | NLA_F_NET_BYTEORDER, value)
-
-#define NLA_PUT_U32(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, u32, attrtype, value)
-
-#define NLA_PUT_BE32(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, __be32, attrtype, value)
-
-#define NLA_PUT_NET32(skb, attrtype, value) \
-	NLA_PUT_BE32(skb, attrtype | NLA_F_NET_BYTEORDER, value)
-
-#define NLA_PUT_U64(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, u64, attrtype, value)
-
-#define NLA_PUT_BE64(skb, attrtype, value) \
-	NLA_PUT_TYPE(skb, __be64, attrtype, value)
-
-#define NLA_PUT_NET64(skb, attrtype, value) \
-	NLA_PUT_BE64(skb, attrtype | NLA_F_NET_BYTEORDER, value)
-
-#define NLA_PUT_STRING(skb, attrtype, value) \
-	NLA_PUT(skb, attrtype, strlen(value) + 1, value)
-
-#define NLA_PUT_FLAG(skb, attrtype) \
-	NLA_PUT(skb, attrtype, 0, NULL)
-
-#define NLA_PUT_MSECS(skb, attrtype, jiffies) \
-	NLA_PUT_U64(skb, attrtype, jiffies_to_msecs(jiffies))
-
 /**
  * nla_get_u32 - return payload of u32 attribute
  * @nla: u32 netlink attribute
-- 
1.7.7.6
