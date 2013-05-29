From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/21] batman-adv: don't check compat version twice
Date: Wed, 29 May 2013 02:59:32 +0200
Message-ID: <1369789186-3600-8-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43878 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934238Ab3E2BBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:50 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Compatibility version is checked upon packet reception
before calling any handler. For this reason it does need to
be checked once more in the handler itself.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 6d62e29..38183dc 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1054,13 +1054,6 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 	}
 	rcu_read_unlock();
 
-	if (batadv_ogm_packet->header.version != BATADV_COMPAT_VERSION) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Drop packet: incompatible batman version (%i)\n",
-			   batadv_ogm_packet->header.version);
-		return;
-	}
-
 	if (is_my_addr) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Drop packet: received my own broadcast (sender: %pM)\n",
-- 
1.8.1.5
