From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 13/14] tipc: Use default rhashtable hashfn
Date: Sun, 15 Mar 2015 21:44:39 +1100
Message-ID: <E1YX62B-0005pa-1R@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39986 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbbCOKon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the explicit jhash value for the hashfn parameter
of rhashtable.  The default is now jhash so removing the setting
makes no difference apart from making one less copy of jhash in
the kernel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/tipc/socket.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 64eb669..f462498 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -35,7 +35,6 @@
  */
 
 #include <linux/rhashtable.h>
-#include <linux/jhash.h>
 #include "core.h"
 #include "name_table.h"
 #include "node.h"
@@ -2360,7 +2359,6 @@ int tipc_sk_rht_init(struct net *net)
 		.head_offset = offsetof(struct tipc_sock, node),
 		.key_offset = offsetof(struct tipc_sock, portid),
 		.key_len = sizeof(u32), /* portid */
-		.hashfn = jhash,
 		.max_size = 1048576,
 		.min_size = 256,
 	};
