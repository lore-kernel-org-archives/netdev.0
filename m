From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 08/10] batman-adv: simplify return handling in some TT functions
Date: Tue, 13 Jun 2017 13:36:58 +0200
Message-ID: <20170613113700.31220-9-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43816 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753301AbdFMLhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:11 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/translation-table.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 4b64a9a633d9..e1133bc634b5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2488,18 +2488,16 @@ static bool
 _batadv_is_ap_isolated(struct batadv_tt_local_entry *tt_local_entry,
 		       struct batadv_tt_global_entry *tt_global_entry)
 {
-	bool ret = false;
-
 	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_WIFI &&
 	    tt_global_entry->common.flags & BATADV_TT_CLIENT_WIFI)
-		ret = true;
+		return true;
 
 	/* check if the two clients are marked as isolated */
 	if (tt_local_entry->common.flags & BATADV_TT_CLIENT_ISOLA &&
 	    tt_global_entry->common.flags & BATADV_TT_CLIENT_ISOLA)
-		ret = true;
+		return true;
 
-	return ret;
+	return false;
 }
 
 /**
@@ -4010,8 +4008,6 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  const unsigned char *addr,
 					  unsigned short vid)
 {
-	bool ret = false;
-
 	/* ignore loop detect macs, they are not supposed to be in the tt local
 	 * data as well.
 	 */
@@ -4021,14 +4017,13 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 	if (!batadv_tt_global_add(bat_priv, orig_node, addr, vid,
 				  BATADV_TT_CLIENT_TEMP,
 				  atomic_read(&orig_node->last_ttvn)))
-		goto out;
+		return false;
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Added temporary global client (addr: %pM, vid: %d, orig: %pM)\n",
 		   addr, batadv_print_vid(vid), orig_node->orig);
-	ret = true;
-out:
-	return ret;
+
+	return true;
 }
 
 /**
-- 
2.11.0
