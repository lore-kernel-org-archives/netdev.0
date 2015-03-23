From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 5/9] tipc: Use default rhashtable hashfn
Date: Tue, 24 Mar 2015 00:50:24 +1100
Message-ID: <E1Ya2kK-0004I7-5P@gondolin.me.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34462 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbCWNup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:50:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the explicit jhash value for the hashfn parameter
of rhashtable.  The default is now jhash so removing the setting
makes no difference apart from making one less copy of jhash in
the kernel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: Thomas Graf <tgraf@suug.ch>
---

 net/tipc/socket.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 73c2f51..6dd5bd9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -35,7 +35,6 @@
  */
 
 #include <linux/rhashtable.h>
-#include <linux/jhash.h>
 #include "core.h"
 #include "name_table.h"
 #include "node.h"
@@ -2294,7 +2293,6 @@ static const struct rhashtable_params tsk_rht_params = {
 	.head_offset = offsetof(struct tipc_sock, node),
 	.key_offset = offsetof(struct tipc_sock, portid),
 	.key_len = sizeof(u32), /* portid */
-	.hashfn = jhash,
 	.max_size = 1048576,
 	.min_size = 256,
 };
