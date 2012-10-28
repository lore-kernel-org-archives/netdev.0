From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/16] batman-adv: properly store the roaming time
Date: Sun, 28 Oct 2012 12:17:12 +0100
Message-ID: <1351423037-5292-12-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56203 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab2J1LSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:44 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in case of a new global entry added because of roaming, the roam_at field must
be properly initiated with the current time. This value will be later use to
purge this entry out on time out (if nobody claims it). Instead roam_at field
is now set to zero in this situation leading to an immediate purging of the
related entry.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 42a74e3..0ac39d5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -726,6 +726,12 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 
 		common->flags = flags;
 		tt_global_entry->roam_at = 0;
+		/* node must store current time in case of roaming. This is
+		 * needed to purge this entry out on timeout (if nobody claims
+		 * it)
+		 */
+		if (flags & BATADV_TT_CLIENT_ROAM)
+			tt_global_entry->roam_at = jiffies;
 		atomic_set(&common->refcount, 2);
 		common->added_at = jiffies;
 
-- 
1.7.12.4
