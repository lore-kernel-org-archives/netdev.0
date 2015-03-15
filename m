From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 12/14] netlink: Use default rhashtable hashfn
Date: Sun, 15 Mar 2015 21:44:37 +1100
Message-ID: <E1YX629-0005pJ-Uk@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:51454 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbbCOKon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:43 -0400
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
index ca048f3..f521f35 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3126,7 +3126,7 @@ static u32 netlink_hash(const void *data, u32 seed)
 	struct netlink_compare_arg arg;
 
 	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
-	return jhash(&arg, netlink_compare_arg_len, seed);
+	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);
 }
 
 static int __init netlink_proto_init(void)
@@ -3136,7 +3136,6 @@ static int __init netlink_proto_init(void)
 	struct rhashtable_params ht_params = {
 		.head_offset = offsetof(struct netlink_sock, node),
 		.key_len = netlink_compare_arg_len,
-		.hashfn = jhash,
 		.obj_hashfn = netlink_hash,
 		.obj_cmpfn = netlink_compare,
 		.max_size = 65536,
