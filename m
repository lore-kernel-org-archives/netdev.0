From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 05/15] net: move __skb_get_hash function declaration to flow_dissector.h
Date: Tue, 12 May 2015 14:56:11 +0200
Message-ID: <1431435381-7164-6-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38387 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932892AbbELM4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:56:52 -0400
Received: by wicnf17 with SMTP id nf17so14235273wic.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:56:51 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
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
index 8616bfe..55677e9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -918,7 +918,6 @@ skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 	skb->hash = hash;
 }
 
-void __skb_get_hash(struct sk_buff *skb);
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
 	if (!skb->l4_hash && !skb->sw_hash)
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 4570cca..e4ee761 100644
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
2.4.0
