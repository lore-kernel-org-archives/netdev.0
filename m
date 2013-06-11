From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 3/3] batman-adv: Don't handle address updates when bla is disabled
Date: Tue, 11 Jun 2013 08:35:01 +0200
Message-ID: <1370932501-3937-4-git-send-email-ordex@autistici.org>
References: <1370932501-3937-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:58946 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab3FKGhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 02:37:10 -0400
In-Reply-To: <1370932501-3937-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

The bridge loop avoidance has a hook to handle address updates of the
originator. These should not be handled when bridge loop avoidance is
disabled - it might send some bridge loop avoidance packets which should
not appear if bla is disabled.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 379061c..de27b31 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1067,6 +1067,10 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 	group = htons(crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN));
 	bat_priv->bla.claim_dest.group = group;
 
+	/* purge everything when bridge loop avoidance is turned off */
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		oldif = NULL;
+
 	if (!oldif) {
 		batadv_bla_purge_claims(bat_priv, NULL, 1);
 		batadv_bla_purge_backbone_gw(bat_priv, 1);
-- 
1.8.1.5
