From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 2/2] batman-adv: fix memory leak when
 dropping packet from other gateway
Date: Tue, 13 Jun 2017 13:15:31 +0200
Message-ID: <20170613111531.29082-3-sw@simonwunderlich.de>
References: <20170613111531.29082-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170613111531.29082-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Andreas Pape <apape-m3bsFMYJiEzvNhTXdWHAddBPR1lH4CV8@public.gmane.org>

The skb must be released in the receive handler since b91a2543b4c1
("batman-adv: Consume skb in receive handlers"). Just returning NET_RX_DROP
will no longer automatically free the memory. This results in memory leaks
when unicast packets from other backbones must be dropped because they
share a common backbone.

Fixes: 9e794b6bf4a2 ("batman-adv: drop unicast packets from other backbone gw")
Signed-off-by: Andreas Pape <apape-m3bsFMYJiEzvNhTXdWHAddBPR1lH4CV8@public.gmane.org>
[sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org: adjust commit message]
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/routing.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e1ebe14ee2a6..ae9f4d37d34f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -987,7 +987,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 				batadv_dbg(BATADV_DBG_BLA, bat_priv,
 					   "recv_unicast_packet(): Dropped unicast pkt received from another backbone gw %pM.\n",
 					   orig_addr_gw);
-				return NET_RX_DROP;
+				goto free_skb;
 			}
 		}
 
-- 
2.11.0
