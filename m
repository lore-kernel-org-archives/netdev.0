From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Need to export ipv6_push_frag_opts for tunneling now.
Date: Mon, 01 May 2017 15:11:09 -0400 (EDT)
Message-ID: <20170501.151109.1682060890683033268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cgallek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdEATLK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since that change also made the nfrag function not necessary
for exports, remove it.

Fixes: 89a23c8b528b ("ip6_tunnel: Fix missing tunnel encapsulation limit option")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/exthdrs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index d32e211..b636f1da 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -946,13 +946,13 @@ void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 	if (opt->hopopt)
 		ipv6_push_exthdr(skb, proto, NEXTHDR_HOP, opt->hopopt);
 }
-EXPORT_SYMBOL(ipv6_push_nfrag_opts);
 
 void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt, u8 *proto)
 {
 	if (opt->dst1opt)
 		ipv6_push_exthdr(skb, proto, NEXTHDR_DEST, opt->dst1opt);
 }
+EXPORT_SYMBOL(ipv6_push_frag_opts);
 
 struct ipv6_txoptions *
 ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
-- 
2.4.11
