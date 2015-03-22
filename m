From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 4/10] netlink: Use default rhashtable hashfn
Date: Sun, 22 Mar 2015 19:04:02 +1100
Message-ID: <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60226 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbbCVIEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:04:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the explicit jhash value for the hashfn parameter
of rhashtable.  The default is now jhash so removing the setting
makes no difference apart from making one less copy of jhash in
the kernel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
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
