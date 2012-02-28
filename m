From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 6/8] batman-adv: TT_CLIENT_PENDING is never
	set in struct tt_global_entry
Date: Tue, 28 Feb 2012 19:32:26 +0800
Message-ID: <1330428748-23137-7-git-send-email-lindner_marek@yahoo.de>
References: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1330428748-23137-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

Actually the TT_CLIENT_PENDING flag is never set in the tt_global_entry
structure, therefore this code is useless and can be removed.

Reported-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/translation-table.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1ff7fbe..9a6f315 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -603,7 +603,7 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 						       struct tt_global_entry,
 						       common);
 			seq_printf(seq, " * %pM  (%3u) via %pM     (%3u)   "
-					"[%c%c%c]\n",
+					"[%c%c]\n",
 					tt_global_entry->common.addr,
 					tt_global_entry->ttvn,
 					tt_global_entry->orig_node->orig,
@@ -613,8 +613,6 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 					(tt_global_entry->common.flags &
 					 TT_CLIENT_ROAM ? 'R' : '.'),
 					(tt_global_entry->common.flags &
-					 TT_CLIENT_PENDING ? 'X' : '.'),
-					(tt_global_entry->common.flags &
 					 TT_CLIENT_WIFI ? 'W' : '.'));
 		}
 		rcu_read_unlock();
@@ -838,11 +836,6 @@ struct orig_node *transtable_search(struct bat_priv *bat_priv,
 	if (!atomic_inc_not_zero(&tt_global_entry->orig_node->refcount))
 		goto out;
 
-	/* A global client marked as PENDING has already moved from that
-	 * originator */
-	if (tt_global_entry->common.flags & TT_CLIENT_PENDING)
-		goto out;
-
 	orig_node = tt_global_entry->orig_node;
 
 out:
-- 
1.7.9
