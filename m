From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netlink: kill nla_put_u64()
Date: Fri, 13 May 2016 15:25:40 +0200
Message-ID: <1463145940-5932-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:45379 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbcEMN0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 09:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is not used anymore. nla_put_u64_64bit() should be used
instead.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

I'm asking myself if it's better to rename nla_put_u64_64bit() to
nla_put_u64(). Because there is a lot of users, the change will be
huge, so I tend to say no.

 include/net/netlink.h | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e589cb3dccee..254a0fc01800 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -98,7 +98,8 @@
  *   nla_put_u8(skb, type, value)	add u8 attribute to skb
  *   nla_put_u16(skb, type, value)	add u16 attribute to skb
  *   nla_put_u32(skb, type, value)	add u32 attribute to skb
- *   nla_put_u64(skb, type, value)	add u64 attribute to skb
+ *   nla_put_u64_64bits(skb, type,
+ *			value, padattr)	add u64 attribute to skb
  *   nla_put_s8(skb, type, value)	add s8 attribute to skb
  *   nla_put_s16(skb, type, value)	add s16 attribute to skb
  *   nla_put_s32(skb, type, value)	add s32 attribute to skb
@@ -847,17 +848,6 @@ static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
 }
 
 /**
- * nla_put_u64 - Add a u64 netlink attribute to a socket buffer
- * @skb: socket buffer to add attribute to
- * @attrtype: attribute type
- * @value: numeric value
- */
-static inline int nla_put_u64(struct sk_buff *skb, int attrtype, u64 value)
-{
-	return nla_put(skb, attrtype, sizeof(u64), &value);
-}
-
-/**
  * nla_put_u64_64bit - Add a u64 netlink attribute to a skb and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
-- 
2.8.1
