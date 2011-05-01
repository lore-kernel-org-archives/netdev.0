From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 2/4] batman-adv: Move definition of
	atomic_dec_not_zero() into main.h
Date: Sun,  1 May 2011 23:10:32 +0200
Message-ID: <1304284234-27338-3-git-send-email-sven@narfation.org>
References: <1304284234-27338-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304284234-27338-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

atomic_dec_not_zero() is very useful and it is currently defined
multiple times. So it is possible to move it in main.h

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/aggregation.c |    1 -
 net/batman-adv/main.h        |    2 ++
 net/batman-adv/send.c        |    1 -
 3 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index af45d6b..c11788c 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -95,7 +95,6 @@ static bool can_aggregate_with(struct batman_packet *new_batman_packet,
 	return false;
 }
 
-#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
 /* create a new aggregated packet and add this packet to it */
 static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 				  unsigned long send_time, bool direct_link,
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index dc24869..ace7285 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -175,4 +175,6 @@ static inline int compare_eth(void *data1, void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
+#define atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
+
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index e78670c..7650e2b 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -393,7 +393,6 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
 			   send_time);
 }
 
-#define atomic_dec_not_zero(v)          atomic_add_unless((v), -1, 0)
 /* add a broadcast packet to the queue and setup timers. broadcast packets
  * are sent multiple times to increase probability for beeing received.
  *
-- 
1.7.4.4
