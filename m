From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 5/8] batman-adv: code refactoring - move
	debug print into tt_local_set_pending
Date: Tue, 28 Feb 2012 19:32:25 +0800
Message-ID: <1330428748-23137-6-git-send-email-lindner_marek@yahoo.de>
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

Each tt_local_set_pending is always followed by a bat_dbg invocation. This can
be simplified by moving the bat_dbg() call.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/translation-table.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9be9c41..1ff7fbe 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -355,7 +355,7 @@ out:
 
 static void tt_local_set_pending(struct bat_priv *bat_priv,
 				 struct tt_local_entry *tt_local_entry,
-				 uint16_t flags)
+				 uint16_t flags, const char *message)
 {
 	tt_local_event(bat_priv, tt_local_entry->common.addr,
 		       tt_local_entry->common.flags | flags);
@@ -364,6 +364,9 @@ static void tt_local_set_pending(struct bat_priv *bat_priv,
 	 * to be kept in the table in order to send it in a full table
 	 * response issued before the net ttvn increment (consistency check) */
 	tt_local_entry->common.flags |= TT_CLIENT_PENDING;
+
+	bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) pending to be removed: "
+		"%s\n", tt_local_entry->common.addr, message);
 }
 
 void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
@@ -376,10 +379,7 @@ void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 		goto out;
 
 	tt_local_set_pending(bat_priv, tt_local_entry, TT_CLIENT_DEL |
-			     (roaming ? TT_CLIENT_ROAM : NO_FLAGS));
-
-	bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) pending to be removed: "
-		"%s\n", tt_local_entry->common.addr, message);
+			     (roaming ? TT_CLIENT_ROAM : NO_FLAGS), message);
 out:
 	if (tt_local_entry)
 		tt_local_entry_free_ref(tt_local_entry);
@@ -417,10 +417,7 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 				continue;
 
 			tt_local_set_pending(bat_priv, tt_local_entry,
-					     TT_CLIENT_DEL);
-			bat_dbg(DBG_TT, bat_priv, "Local tt entry (%pM) "
-				"pending to be removed: timed out\n",
-				tt_local_entry->common.addr);
+					     TT_CLIENT_DEL, "timed out");
 		}
 		spin_unlock_bh(list_lock);
 	}
-- 
1.7.9
