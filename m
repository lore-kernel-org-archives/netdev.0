From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 09/10] batman-adv: Use default throughput value on cfg80211 error
Date: Tue, 13 Jun 2017 13:36:59 +0200
Message-ID: <20170613113700.31220-10-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43860 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753302AbdFMLhM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:12 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

A wifi interface should never be handled like an ethernet devices. The
parser of the cfg80211 output must therefore skip the ethtool code when
cfg80211_get_station returned an error.

Fixes: f44a3ae9a281 ("batman-adv: refactor wifi interface detection")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Reviewed-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_v_elp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index b90c9903e246..96e7333764f0 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -109,8 +109,10 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 			 */
 			return 0;
 		}
-		if (!ret)
-			return sinfo.expected_throughput / 100;
+		if (ret)
+			goto default_throughput;
+
+		return sinfo.expected_throughput / 100;
 	}
 
 	/* if not a wifi interface, check if this device provides data via
-- 
2.11.0
