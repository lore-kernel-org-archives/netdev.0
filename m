From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 6/8] batman-adv: Update wifi flags on upper link change
Date: Sat, 19 Nov 2016 14:35:26 +0100
Message-ID: <20161119133528.1379-7-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49978 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbcKSNfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:34 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@open-mesh.com>

Things like VLANs don't have their link set when they are created. Thus
the wifi flags have to be evaluated later to fix their contents for the
link interface.

Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/hard-interface.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index ca743a5..61a431a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -1006,6 +1006,11 @@ static int batadv_hard_if_event(struct notifier_block *this,
 		if (hard_iface == primary_if)
 			batadv_primary_if_update_addr(bat_priv, NULL);
 		break;
+	case NETDEV_CHANGEUPPER:
+		hard_iface->wifi_flags = batadv_wifi_flags_evaluate(net_dev);
+		if (batadv_is_wifi_hardif(hard_iface))
+			hard_iface->num_bcasts = BATADV_NUM_BCASTS_WIRELESS;
+		break;
 	default:
 		break;
 	}
-- 
2.10.2
