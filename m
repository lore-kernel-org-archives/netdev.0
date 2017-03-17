From: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Subject: [PATCH] batman-adv: Omit unnecessary memset of
	netdev private data
Date: Fri, 17 Mar 2017 12:08:59 +0100
Message-ID: <20170317110859.9273-1-tklauser@distanz.ch>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>, Antonio Quartulli <a@unstable.cc>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

The memory for netdev_priv is allocated using kzalloc in alloc_netdev
(or alloc_netdev_mq respectively) so there is no need to set it to 0
again.

Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
---
 net/batman-adv/soft-interface.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5d099b2e6cfc..8226495c6664 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -972,8 +972,6 @@ static void batadv_softif_free(struct net_device *dev)
  */
 static void batadv_softif_init_early(struct net_device *dev)
 {
-	struct batadv_priv *priv = netdev_priv(dev);
-
 	ether_setup(dev);
 
 	dev->netdev_ops = &batadv_netdev_ops;
@@ -990,8 +988,6 @@ static void batadv_softif_init_early(struct net_device *dev)
 	eth_hw_addr_random(dev);
 
 	dev->ethtool_ops = &batadv_ethtool_ops;
-
-	memset(priv, 0, sizeof(*priv));
 }
 
 struct net_device *batadv_softif_create(struct net *net, const char *name)
-- 
2.11.0
