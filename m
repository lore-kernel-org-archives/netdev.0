From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 4/14] tipc: Use rhashtable max_size instead of max_shift
Date: Sun, 15 Mar 2015 21:44:28 +1100
Message-ID: <E1YX620-0005n3-Uy@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33083 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbCOKod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts tipc to use rhashtable max_size instead of
the obsolete max_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/tipc/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 934947f..64eb669 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2361,8 +2361,8 @@ int tipc_sk_rht_init(struct net *net)
 		.key_offset = offsetof(struct tipc_sock, portid),
 		.key_len = sizeof(u32), /* portid */
 		.hashfn = jhash,
-		.max_shift = 20, /* 1M */
-		.min_shift = 8,  /* 256 */
+		.max_size = 1048576,
+		.min_size = 256,
 	};
 
 	return rhashtable_init(&tn->sk_rht, &rht_params);
