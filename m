From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 1/10] rhashtable: Add barrier to ensure we see new tables in walker
Date: Sun, 22 Mar 2015 18:53:43 +1100
Message-ID: <E1YZahb-0000hI-SD@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45379 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbCVHyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The walker is a lockless reader so it too needs an smp_rmb before
reading the future_tbl field in order to see any new tables that
may contain elements that we should have walked over.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 83cfedd..618a3f0 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -477,6 +477,9 @@ next:
 		iter->skip = 0;
 	}
 
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
 	iter->walker->tbl = rht_dereference_rcu(tbl->future_tbl, ht);
 	if (iter->walker->tbl) {
 		iter->slot = 0;
