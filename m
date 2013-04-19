From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: ipset: bitmap:ip,mac: fix listing with timeout
Date: Fri, 19 Apr 2013 03:16:01 +0200
Message-ID: <1366334162-4958-2-git-send-email-pablo@netfilter.org>
References: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56900 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967630Ab3DSBQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 21:16:12 -0400
In-Reply-To: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The type when timeout support was enabled, could not list all elements,
just the first ones which could fit into one netlink message: it just
did not continue listing after the first message.

Reported-by: Yoann JUET <yoann.juet@univ-nantes.fr>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Tested-by: Yoann JUET <yoann.juet@univ-nantes.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 0f92dc2..d7df6ac 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -339,7 +339,11 @@ bitmap_ipmac_tlist(const struct ip_set *set,
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	ipset_nest_end(skb, atd);
-	return -EMSGSIZE;
+	if (unlikely(id == first)) {
+		cb->args[2] = 0;
+		return -EMSGSIZE;
+	}
+	return 0;
 }
 
 static int
-- 
1.7.10.4
