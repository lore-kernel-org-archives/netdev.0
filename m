From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 09/10] batman-adv: check for tt_reponse
	packet real length
Date: Sat, 26 Nov 2011 22:26:51 +0800
Message-ID: <1322317612-7770-10-git-send-email-lindner_marek@yahoo.de>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1322317612-7770-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

Before accessing the TT_RESPONSE packet payload, the node has to ensure that the
packet is long enough as it would expect to be.

Reported-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e0e7b7b..ef24a72 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -578,6 +578,7 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct tt_query_packet *tt_query;
+	uint16_t tt_len;
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
@@ -622,6 +623,14 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 			if (skb_linearize(skb) < 0)
 				goto out;
 
+			tt_len = tt_query->tt_data * sizeof(struct tt_change);
+
+			/* Ensure we have all the claimed data */
+			if (unlikely(skb_headlen(skb) <
+					sizeof(struct tt_query_packet) +
+					tt_len))
+				goto out;
+
 			handle_tt_response(bat_priv, tt_query);
 		} else {
 			bat_dbg(DBG_TT, bat_priv,
-- 
1.7.5.4
