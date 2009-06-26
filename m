From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 2/5] mac80211: Use rcu_barrier() on unload.
Date: Fri, 26 Jun 2009 22:45:53 +0200
Message-ID: <20090626204553.10664.57323.stgit@localhost>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34391 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbZFZUpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:45:50 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac80211 module uses rcu_call() thus it should use rcu_barrier()
on module unload.

The rcu_barrier() is placed in mech.c ieee80211_stop_mesh() which is
invoked from ieee80211_stop() in case vif.type == NL80211_IFTYPE_MESH_POINT.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/mac80211/mesh.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index fc712e6..11cf45b 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -494,7 +494,7 @@ void ieee80211_stop_mesh(struct ieee80211_sub_if_data *sdata)
 	 * should it be using the interface and enqueuing
 	 * frames at this very time on another CPU.
 	 */
-	synchronize_rcu();
+	rcu_barrier(); /* Wait for RX path and call_rcu()'s */
 	skb_queue_purge(&sdata->u.mesh.skb_queue);
 }
 

