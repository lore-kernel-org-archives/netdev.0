From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 07/10] batman-adv: do not add loop detection mac addresses to global tt
Date: Tue, 13 Jun 2017 13:36:57 +0200
Message-ID: <20170613113700.31220-8-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43806 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdFMLhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:11 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change has been made for local TT already, add another one for
global TT - but only for temporary entries (aka speedy join), to prevent
inconsistencies between local and global tables in case an older
batman-adv version is still announcing those entries from its local
table.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/translation-table.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index e75b4937b497..4b64a9a633d9 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -4012,6 +4012,12 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 {
 	bool ret = false;
 
+	/* ignore loop detect macs, they are not supposed to be in the tt local
+	 * data as well.
+	 */
+	if (batadv_bla_is_loopdetect_mac(addr))
+		return false;
+
 	if (!batadv_tt_global_add(bat_priv, orig_node, addr, vid,
 				  BATADV_TT_CLIENT_TEMP,
 				  atomic_read(&orig_node->last_ttvn)))
-- 
2.11.0
