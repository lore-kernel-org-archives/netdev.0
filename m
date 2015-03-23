From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 4/9] netlink: Use default rhashtable hashfn
Date: Tue, 24 Mar 2015 00:50:22 +1100
Message-ID: <E1Ya2kI-0004Hq-V0@gondolin.me.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54671 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbbCWNuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the explicit jhash value for the hashfn parameter
of rhashtable.  As the key length is a multiple of 4, this means that
we will actually end up using jhash2.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: Thomas Graf <tgraf@suug.ch>
---

 net/netlink/af_netlink.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6517921..e2f7f28 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3133,13 +3133,12 @@ static inline u32 netlink_hash(const void *data, u32 seed)
 	struct netlink_compare_arg arg;
 
 	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
-	return jhash(&arg, netlink_compare_arg_len, seed);
+	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);
 }
 
 static const struct rhashtable_params netlink_rhashtable_params = {
 	.head_offset = offsetof(struct netlink_sock, node),
 	.key_len = netlink_compare_arg_len,
-	.hashfn = jhash,
 	.obj_hashfn = netlink_hash,
 	.obj_cmpfn = netlink_compare,
 	.max_size = 65536,
