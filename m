From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 19/19] batman-adv: only store changed gw_bandwidth values
Date: Mon, 18 Jun 2012 22:39:23 +0200
Message-ID: <1340051963-14836-20-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41527 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab2FRUjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:19 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/gateway_common.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index ca57ac7..6e3b052 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -162,6 +162,9 @@ ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 	 **/
 	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
 
+	if (atomic_read(&bat_priv->gw_bandwidth) == gw_bandwidth_tmp)
+		return count;
+
 	gw_deselect(bat_priv);
 	bat_info(net_dev,
 		 "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
-- 
1.7.9.4
