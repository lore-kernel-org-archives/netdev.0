From: akpm@osdl.org
Subject: [patch 10/13] fix potential stack overflow in net/core/utils.c
Date: Mon, 14 Aug 2006 23:03:44 -0700
Message-ID: <200608150603.k7F63iSf012951@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, suresh.b.siddha@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45715 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965165AbWHOGDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:48 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>

On High end systems (1024 or so cpus) this can potentially cause stack
overflow.  Fix the stack usage.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/core/utils.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN net/core/utils.c~fix-potential-stack-overflow-in-net-core-utilsc net/core/utils.c
--- a/net/core/utils.c~fix-potential-stack-overflow-in-net-core-utilsc
+++ a/net/core/utils.c
@@ -130,12 +130,13 @@ void __init net_random_init(void)
 static int net_random_reseed(void)
 {
 	int i;
-	unsigned long seed[NR_CPUS];
+	unsigned long seed;
 
-	get_random_bytes(seed, sizeof(seed));
 	for_each_possible_cpu(i) {
 		struct nrnd_state *state = &per_cpu(net_rand_state,i);
-		__net_srandom(state, seed[i]);
+
+		get_random_bytes(&seed, sizeof(seed));
+		__net_srandom(state, seed);
 	}
 	return 0;
 }
_
