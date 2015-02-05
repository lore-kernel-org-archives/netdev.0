From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 1/2] ipv6: Resolve sparce error with fragment id selection
Date: Thu,  5 Feb 2015 09:41:36 -0500
Message-ID: <1423147297-4757-2-git-send-email-vyasevic@redhat.com>
References: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:60100 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbbBEOlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:41:45 -0500
Received: by mail-qa0-f46.google.com with SMTP id j7so6049071qaq.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:41:45 -0800 (PST)
In-Reply-To: <1423147297-4757-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resolve the following sparce error:
 net/ipv6/output_core.c:57:38: sparse: incorrect type in assignment
 (different base types)
   net/ipv6/output_core.c:57:38:    expected restricted __be32
[usertype] ip6_frag_id
   net/ipv6/output_core.c:57:38:    got unsigned int [unsigned]
[assigned] [usertype] id

Fixes: 0508c07f5e0c9 (ipv6: Select fragment id during UFO segmentation
if not set.)
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/output_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 54520a0..a86cf60 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -54,7 +54,7 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
 
 	id = __ipv6_select_ident(ip6_proxy_idents_hashrnd,
 				 &addrs[1], &addrs[0]);
-	skb_shinfo(skb)->ip6_frag_id = id;
+	skb_shinfo(skb)->ip6_frag_id = htonl(id);
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
-- 
1.9.3
