From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/15] net: move __skb_get_hash function declaration to flow_dissector.h
Date: Tue, 12 May 2015 09:39:13 +0200
Message-ID: <1431416363-5675-6-git-send-email-jiri@resnulli.us>
References: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36756 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbbELHjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 03:39:49 -0400
Received: by wizk4 with SMTP id k4so139639031wiz.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 00:39:48 -0700 (PDT)
In-Reply-To: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
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
1.9.3
