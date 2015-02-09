From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 1/2] ipv6: Fix fragment id assignment on LE arches.
Date: Mon,  9 Feb 2015 09:38:20 -0500
Message-ID: <1423492701-21429-2-git-send-email-vyasevic@redhat.com>
References: <1423492701-21429-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:48595 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933028AbbBIOic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 09:38:32 -0500
Received: by mail-qa0-f53.google.com with SMTP id k15so871010qaq.12
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 06:38:31 -0800 (PST)
In-Reply-To: <1423492701-21429-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commit:
0508c07f5e0c94f38afd5434e8b2a55b84553077
Author: Vlad Yasevich <vyasevich@gmail.com>
Date:   Tue Feb 3 16:36:15 2015 -0500

    ipv6: Select fragment id during UFO segmentation if not set.

Introduced a bug on LE in how ipv6 fragment id is assigned.
This was cought by nightly sparce check:

Resolve the following sparce error:
 net/ipv6/output_core.c:57:38: sparse: incorrect type in assignment
 (different base types)
   net/ipv6/output_core.c:57:38:    expected restricted __be32
[usertype] ip6_frag_id
   net/ipv6/output_core.c:57:38:    got unsigned int [unsigned]
[assigned] [usertype] id

Fixes: 0508c07f5e0c9 (ipv6: Select fragment id during UFO segmentation if not set.)
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
