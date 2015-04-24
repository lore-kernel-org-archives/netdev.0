From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 05/15] net: move __skb_get_hash function declaration to flow_dissector.h
Date: Fri, 24 Apr 2015 17:51:31 +0200
Message-ID: <1429890701-30052-6-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37549 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031114AbbDXPvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:53 -0400
Received: by widdi4 with SMTP id di4so25125593wid.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:52 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the definition of the function is in flow_dissector.c, it makes
sense to have the declaration in flow_dissector.h

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/skbuff.h       | 1 -
 include/net/flow_dissector.h | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 16fa278..57f5e5c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -917,7 +917,6 @@ skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 	skb->hash = hash;
 }
 
-void __skb_get_hash(struct sk_buff *skb);
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
 	if (!skb->l4_hash && !skb->sw_hash)
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index b27cd24..8a5bf48 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -46,6 +46,7 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 }
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
+void __skb_get_hash(struct sk_buff *skb);
 u32 skb_get_poff(const struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen);
-- 
1.9.3
