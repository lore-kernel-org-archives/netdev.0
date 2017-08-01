From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] flow_dissector: remove unused functions
Date: Tue,  1 Aug 2017 13:18:09 -0700
Message-ID: <20170801201809.12922-1-xiyou.wangcong@gmail.com>
Cc: tom@herbertland.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37950 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752044AbdHAUSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:18:21 -0400
Received: by mail-pf0-f193.google.com with SMTP id e3so3700015pfc.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 13:18:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are introduced by commit f70ea018da06
("net: Add functions to get skb->hash based on flow structures")
but never gets used in tree.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/skbuff.h    | 16 ----------------
 net/core/flow_dissector.c | 45 ---------------------------------------------
 2 files changed, 61 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4093552be1de..7090519c72dd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1122,8 +1122,6 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
-__u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6);
-
 static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
 {
 	if (!skb->l4_hash && !skb->sw_hash) {
@@ -1136,20 +1134,6 @@ static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6
 	return skb->hash;
 }
 
-__u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl);
-
-static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
-{
-	if (!skb->l4_hash && !skb->sw_hash) {
-		struct flow_keys keys;
-		__u32 hash = __get_hash_from_flowi4(fl4, &keys);
-
-		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
-	}
-
-	return skb->hash;
-}
-
 __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb);
 
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fc5fc4594c90..0cc672aba1f0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -998,51 +998,6 @@ __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
 }
 EXPORT_SYMBOL(skb_get_hash_perturb);
 
-__u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
-{
-	struct flow_keys keys;
-
-	memset(&keys, 0, sizeof(keys));
-
-	memcpy(&keys.addrs.v6addrs.src, &fl6->saddr,
-	       sizeof(keys.addrs.v6addrs.src));
-	memcpy(&keys.addrs.v6addrs.dst, &fl6->daddr,
-	       sizeof(keys.addrs.v6addrs.dst));
-	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
-	keys.ports.src = fl6->fl6_sport;
-	keys.ports.dst = fl6->fl6_dport;
-	keys.keyid.keyid = fl6->fl6_gre_key;
-	keys.tags.flow_label = (__force u32)fl6->flowlabel;
-	keys.basic.ip_proto = fl6->flowi6_proto;
-
-	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
-			  flow_keys_have_l4(&keys));
-
-	return skb->hash;
-}
-EXPORT_SYMBOL(__skb_get_hash_flowi6);
-
-__u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
-{
-	struct flow_keys keys;
-
-	memset(&keys, 0, sizeof(keys));
-
-	keys.addrs.v4addrs.src = fl4->saddr;
-	keys.addrs.v4addrs.dst = fl4->daddr;
-	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
-	keys.ports.src = fl4->fl4_sport;
-	keys.ports.dst = fl4->fl4_dport;
-	keys.keyid.keyid = fl4->fl4_gre_key;
-	keys.basic.ip_proto = fl4->flowi4_proto;
-
-	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
-			  flow_keys_have_l4(&keys));
-
-	return skb->hash;
-}
-EXPORT_SYMBOL(__skb_get_hash_flowi4);
-
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen)
 {
-- 
2.13.0
