From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 4/6] tipc: Use rhashtable max/min_size instead of max/min_shift
Date: Wed, 18 Mar 2015 20:01:18 +1100
Message-ID: <E1YY9qo-0005mi-Qf@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60059 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013AbbCRJBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:01:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts tipc to use rhashtable max/min_size instead of
the obsolete max/min_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/tipc/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 813847d..d7a6c10 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2286,8 +2286,8 @@ int tipc_sk_rht_init(struct net *net)
 		.key_offset = offsetof(struct tipc_sock, portid),
 		.key_len = sizeof(u32), /* portid */
 		.hashfn = jhash,
-		.max_shift = 20, /* 1M */
-		.min_shift = 8,  /* 256 */
+		.max_size = 1048576,
+		.min_size = 256,
 	};
 
 	return rhashtable_init(&tn->sk_rht, &rht_params);
