From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 12/20] batman-adv: Prefix ring_buffer
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:48 +0200
Message-ID: <1340297876-29923-13-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c  |   14 +++++++-------
 net/batman-adv/ring_buffer.c |    5 +++--
 net/batman-adv/ring_buffer.h |    5 +++--
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 9c8c9d0..cd57cf2 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -642,10 +642,10 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 			continue;
 
 		spin_lock_bh(&tmp_neigh_node->lq_update_lock);
-		ring_buffer_set(tmp_neigh_node->tq_recv,
-				&tmp_neigh_node->tq_index, 0);
+		batadv_ring_buffer_set(tmp_neigh_node->tq_recv,
+				       &tmp_neigh_node->tq_index, 0);
 		tmp_neigh_node->tq_avg =
-			ring_buffer_avg(tmp_neigh_node->tq_recv);
+			batadv_ring_buffer_avg(tmp_neigh_node->tq_recv);
 		spin_unlock_bh(&tmp_neigh_node->lq_update_lock);
 	}
 
@@ -673,10 +673,10 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	neigh_node->last_seen = jiffies;
 
 	spin_lock_bh(&neigh_node->lq_update_lock);
-	ring_buffer_set(neigh_node->tq_recv,
-			&neigh_node->tq_index,
-			batman_ogm_packet->tq);
-	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
+	batadv_ring_buffer_set(neigh_node->tq_recv,
+			       &neigh_node->tq_index,
+			       batman_ogm_packet->tq);
+	neigh_node->tq_avg = batadv_ring_buffer_avg(neigh_node->tq_recv);
 	spin_unlock_bh(&neigh_node->lq_update_lock);
 
 	if (!is_duplicate) {
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
index fd63951..db8f5ef 100644
--- a/net/batman-adv/ring_buffer.c
+++ b/net/batman-adv/ring_buffer.c
@@ -22,13 +22,14 @@
 #include "main.h"
 #include "ring_buffer.h"
 
-void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value)
+void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
+			    uint8_t value)
 {
 	lq_recv[*lq_index] = value;
 	*lq_index = (*lq_index + 1) % TQ_GLOBAL_WINDOW_SIZE;
 }
 
-uint8_t ring_buffer_avg(const uint8_t lq_recv[])
+uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 {
 	const uint8_t *ptr;
 	uint16_t count = 0, i = 0, sum = 0;
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
index 8b58bd8..fbaf9d2 100644
--- a/net/batman-adv/ring_buffer.h
+++ b/net/batman-adv/ring_buffer.h
@@ -22,7 +22,8 @@
 #ifndef _NET_BATMAN_ADV_RING_BUFFER_H_
 #define _NET_BATMAN_ADV_RING_BUFFER_H_
 
-void ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index, uint8_t value);
-uint8_t ring_buffer_avg(const uint8_t lq_recv[]);
+void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
+			    uint8_t value);
+uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[]);
 
 #endif /* _NET_BATMAN_ADV_RING_BUFFER_H_ */
-- 
1.7.9.4
