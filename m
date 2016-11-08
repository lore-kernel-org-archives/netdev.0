From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 05/17] batman-adv: Remove unnecessary lockdep
	in batadv_mcast_mla_list_free
Date: Tue,  8 Nov 2016 17:45:14 +0100
Message-ID: <20161108164526.7518-6-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161108164526.7518-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

From: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

batadv_mcast_mla_list_free() just frees some leftovers of a local feast
in batadv_mcast_mla_update(). No lockdep needed as it has nothing to do
with bat_priv->mcast.mla_list.

Signed-off-by: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/multicast.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 13661f4..45757fa 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -231,19 +231,15 @@ static int batadv_mcast_mla_bridge_get(struct net_device *dev,
 
 /**
  * batadv_mcast_mla_list_free - free a list of multicast addresses
- * @bat_priv: the bat priv with all the soft interface information
  * @mcast_list: the list to free
  *
  * Removes and frees all items in the given mcast_list.
  */
-static void batadv_mcast_mla_list_free(struct batadv_priv *bat_priv,
-				       struct hlist_head *mcast_list)
+static void batadv_mcast_mla_list_free(struct hlist_head *mcast_list)
 {
 	struct batadv_hw_addr *mcast_entry;
 	struct hlist_node *tmp;
 
-	lockdep_assert_held(&bat_priv->tt.commit_lock);
-
 	hlist_for_each_entry_safe(mcast_entry, tmp, mcast_list, list) {
 		hlist_del(&mcast_entry->list);
 		kfree(mcast_entry);
@@ -560,7 +556,7 @@ void batadv_mcast_mla_update(struct batadv_priv *bat_priv)
 	batadv_mcast_mla_tt_add(bat_priv, &mcast_list);
 
 out:
-	batadv_mcast_mla_list_free(bat_priv, &mcast_list);
+	batadv_mcast_mla_list_free(&mcast_list);
 }
 
 /**
-- 
2.10.1
