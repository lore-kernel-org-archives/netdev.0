From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/16] batman-adv: print packets re-routing on DBG_TT and ratelimit it
Date: Sun, 28 Oct 2012 12:17:13 +0100
Message-ID: <1351423037-5292-13-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56248 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2J1LSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:46 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To simplify TranslationTable debugging it is better to print the packet
rerouting message on the DBG_TT log level. In this way a developer interested in
packets rerouting doesn't need to filter it out of the whole ROUTES log.

Moreover, since this message will appear for each rerouted message, it is now
"ratelimited".

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1ac072d..456a0a9 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -965,10 +965,10 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 			batadv_orig_node_free_ref(orig_node);
 		}
 
-		batadv_dbg(BATADV_DBG_ROUTES, bat_priv,
-			   "TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
-			   unicast_packet->ttvn, curr_ttvn, ethhdr->h_dest,
-			   unicast_packet->dest);
+		net_ratelimited_function(batadv_dbg, BATADV_DBG_TT, bat_priv,
+					 "TTVN mismatch (old_ttvn %u new_ttvn %u)! Rerouting unicast packet (for %pM) to %pM\n",
+					 unicast_packet->ttvn, curr_ttvn,
+					 ethhdr->h_dest, unicast_packet->dest);
 
 		unicast_packet->ttvn = curr_ttvn;
 	}
-- 
1.7.12.4
