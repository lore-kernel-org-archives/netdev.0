From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 19/20] batman-adv: Keep batadv netdev when hardif disappears
Date: Mon, 22 Aug 2016 15:56:19 +0200
Message-ID: <20160822135620.15337-20-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38994 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755484AbcHVN56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:58 -0400
In-Reply-To: <20160822135620.15337-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Switch-like virtual interfaces like bridge or openvswitch don't destroy
itself when all their attached netdevices dissappear. Instead they only
remove the link to the unregistered device and keep working until they get
removed manually.

This has the benefit that all configurations for this interfaces are kept
and daemons reacting to rtnl events can just add new slave interfaces
without going through the complete configuration of the switch-like
netdevice.

Handling unregister events of client devices similar in batman-adv allows
users to drop their current workaround of dummy netdevices attached to
batman-adv soft-interfaces.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/hard-interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 9284c73..08ce361 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -725,7 +725,7 @@ static void batadv_hardif_remove_interface(struct batadv_hard_iface *hard_iface)
 	/* first deactivate interface */
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
 		batadv_hardif_disable_interface(hard_iface,
-						BATADV_IF_CLEANUP_AUTO);
+						BATADV_IF_CLEANUP_KEEP);
 
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
 		return;
-- 
2.9.3
