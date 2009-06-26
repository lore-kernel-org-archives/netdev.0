From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 5/5] decnet: Use rcu_barrier() on module unload.
Date: Fri, 26 Jun 2009 22:46:08 +0200
Message-ID: <20090626204608.10664.84674.stgit@localhost>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34406 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbZFZUqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:46:06 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The decnet module unloading as been disabled with a '#if 0' statement,
because it have had issues.

We add a rcu_barrier() anyhow for correctness.

The maintainer (Chrissie Caulfield) will look into the unload issue
when time permits.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Chrissie Caulfield <christine.caulfield@googlemail.com>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/decnet/af_decnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index d351b8d..77d4028 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2413,6 +2413,8 @@ static void __exit decnet_exit(void)
 	proc_net_remove(&init_net, "decnet");
 
 	proto_unregister(&dn_proto);
+
+	rcu_barrier_bh(); /* Wait for completion of call_rcu_bh()'s */
 }
 module_exit(decnet_exit);
 #endif

