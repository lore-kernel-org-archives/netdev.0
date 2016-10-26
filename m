From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] flow_dissector: __skb_get_hash_symmetric arg can be const
Date: Wed, 26 Oct 2016 18:49:46 +0200
Message-ID: <1477500586-17451-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56726 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754226AbcJZQt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:49:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h    | 2 +-
 net/core/flow_dissector.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 601258f6e621..663fda2887f7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1086,7 +1086,7 @@ __skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
 }
 
 void __skb_get_hash(struct sk_buff *skb);
-u32 __skb_get_hash_symmetric(struct sk_buff *skb);
+u32 __skb_get_hash_symmetric(const struct sk_buff *skb);
 u32 skb_get_poff(const struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1a7b80f73376..0cc607d05fc8 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -723,7 +723,7 @@ EXPORT_SYMBOL(make_flow_keys_digest);
 
 static struct flow_dissector flow_keys_dissector_symmetric __read_mostly;
 
-u32 __skb_get_hash_symmetric(struct sk_buff *skb)
+u32 __skb_get_hash_symmetric(const struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
-- 
2.7.3
