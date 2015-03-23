From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 1/9] rhashtable: Add barrier to ensure we see new tables in walker
Date: Tue, 24 Mar 2015 00:50:19 +1100
Message-ID: <E1Ya2kF-0004H1-35@gondolin.me.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:44030 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbbCWNuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The walker is a lockless reader so it too needs an smp_rmb before
reading the future_tbl field in order to see any new tables that
may contain elements that we should have walked over.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: Thomas Graf <tgraf@suug.ch>
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
