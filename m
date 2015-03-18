From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 3/6] netlink: Use rhashtable max_size instead of max_shift
Date: Wed, 18 Mar 2015 20:01:17 +1100
Message-ID: <E1YY9qn-0005mR-N9@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35099 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438AbbCRJBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:01:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts netlink to use rhashtable max_size instead
of the obsolete max_shift.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6b0f219..d97aed6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3123,7 +3123,7 @@ static int __init netlink_proto_init(void)
 		.key_offset = offsetof(struct netlink_sock, portid),
 		.key_len = sizeof(u32), /* portid */
 		.hashfn = jhash,
-		.max_shift = 16, /* 64K */
+		.max_size = 65536,
 	};
 
 	if (err != 0)
