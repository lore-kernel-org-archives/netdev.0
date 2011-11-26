From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 05/10] batman-adv: use orig_hash_find()
	instead of get_orig_node() in TT code
Date: Sat, 26 Nov 2011 22:26:47 +0800
Message-ID: <1322317612-7770-6-git-send-email-lindner_marek@yahoo.de>
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

get_orig_node() tries to retrieve an orig_node object based on a mac address
and creates it if not present. This is not the wanted behaviour in the
translation table code as we don't want to create new orig_code objects but
expect a NULL pointer if the object does not exist.

Reported-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/translation-table.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1db9d96..7ab9d72 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1188,11 +1188,11 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* Let's get the orig node of the REAL destination */
-	req_dst_orig_node = get_orig_node(bat_priv, tt_request->dst);
+	req_dst_orig_node = orig_hash_find(bat_priv, tt_request->dst);
 	if (!req_dst_orig_node)
 		goto out;
 
-	res_dst_orig_node = get_orig_node(bat_priv, tt_request->src);
+	res_dst_orig_node = orig_hash_find(bat_priv, tt_request->src);
 	if (!res_dst_orig_node)
 		goto out;
 
@@ -1318,7 +1318,7 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 	my_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
 	req_ttvn = tt_request->ttvn;
 
-	orig_node = get_orig_node(bat_priv, tt_request->src);
+	orig_node = orig_hash_find(bat_priv, tt_request->src);
 	if (!orig_node)
 		goto out;
 
-- 
1.7.5.4
