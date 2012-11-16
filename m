From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/4] batman-adv: fix tt_global_entries flags update
Date: Fri, 16 Nov 2012 09:49:15 +0100
Message-ID: <1353055758-2901-2-git-send-email-ordex@autistici.org>
References: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:34815 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377Ab2KPIuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 03:50:20 -0500
In-Reply-To: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flags carried by a change_entry have to be always copied into the
client entry as they may contain important attributes (e.g.
TT_CLIENT_WIFI).

For instance, a client added by means of the "early detection
mechanism" has no flag set at the beginning, so they must be updated once the
proper ADD event is received.

This was introduced by 30cfd02b60e1cb16f5effb0a01f826c5bb7e4c59
("batman-adv: detect not yet announced clients")

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 112edd3..64c0012 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -769,6 +769,12 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 		 */
 		tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_TEMP;
 
+		/* the change can carry possible "attribute" flags like the
+		 * TT_CLIENT_WIFI, therefore they have to be copied in the
+		 * client entry
+		 */
+		tt_global_entry->common.flags |= flags;
+
 		/* If there is the BATADV_TT_CLIENT_ROAM flag set, there is only
 		 * one originator left in the list and we previously received a
 		 * delete + roaming change for this originator.
-- 
1.8.0
