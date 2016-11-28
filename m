From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 1/1] GSO: Reload iph after pskb_may_pull
Date: Mon, 28 Nov 2016 12:36:58 -0300
Message-ID: <20161128153658.GB4778@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux Networking Development Mailing List
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39288 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932357AbcK1PhD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 10:37:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it may get stale and lead to use after free.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Duyck <aduyck@mirantis.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Fixes: cbc53e08a793 ("GSO: Add GSO type for fixed IPv4 ID")
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/af_inet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ddf5cda07f4..215143246e4b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1233,7 +1233,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
 
 		/* fixed ID is invalid if DF bit is not set */
-		if (fixedid && !(iph->frag_off & htons(IP_DF)))
+		if (fixedid && !(ip_hdr(skb)->frag_off & htons(IP_DF)))
 			goto out;
 	}
 
-- 
2.9.3
