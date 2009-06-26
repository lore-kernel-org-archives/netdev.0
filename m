From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/5] bridge: Use rcu_barrier() instead of syncronize_net() on
	unload.
Date: Fri, 26 Jun 2009 22:45:48 +0200
Message-ID: <20090626204548.10664.75094.stgit@localhost>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34385 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbZFZUpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:45:45 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When unloading modules that uses call_rcu() callbacks, then we must
use rcu_barrier().  This module uses syncronize_net() which is not
enough to be sure that all callback has been completed.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/bridge/br.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 9aac521..e1241c7 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -93,7 +93,7 @@ static void __exit br_deinit(void)
 
 	unregister_pernet_subsys(&br_net_ops);
 
-	synchronize_net();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
 	br_netfilter_fini();
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)

