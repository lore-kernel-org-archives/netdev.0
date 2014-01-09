From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 11/13] batman-adv: extend the ap_isolation
	mechanism
Date: Thu,  9 Jan 2014 15:53:00 +0100
Message-ID: <1389279182-3256-12-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1389279182-3256-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
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

From: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>

Change the AP isolation mechanism to not only "isolate" WIFI
clients but also all those marked with the more generic
"isolation flag" (BATADV_TT_CLIENT_ISOLA).

The result is that when AP isolation is on any unicast
packet originated by an "isolated" client and directed to
another "isolated" client is dropped at the source node.

Signed-off-by: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 net/batman-adv/translation-table.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index eeceb13..a874d08 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1869,6 +1869,11 @@ _batadv_is_ap_isolated(struct batadv_tt_local_entry *tt_local_entry,
 	    tt_global_entry->common.flags & BATADV_TT_CLIENT_WIFI)
 		ret = true;
 
+	/* check if the two clients are marked as isolated */
+	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_ISOLA &&
+	    tt_global_entry->common.flags & BATADV_TT_CLIENT_ISOLA)
+		ret = true;
+
 	return ret;
 }
 
-- 
1.8.5.2
