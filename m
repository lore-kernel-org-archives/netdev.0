From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 14/16] batman-adv: Provide bla group in the mesh_info netlink msg
Date: Tue, 16 Aug 2016 10:32:42 +0200
Message-ID: <1471336364-16334-15-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58618 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbcHPIdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:35 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The bridge loop avoidange is the main information for the debugging of of
bridge loop detection problems. It is therefore necessary when comparing
the bla claim tables.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/netlink.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index b33675c..464de9d 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -19,6 +19,7 @@
 #include "main.h"
 
 #include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/genetlink.h>
@@ -42,6 +43,7 @@
 #include "gateway_client.h"
 #include "hard-interface.h"
 #include "originator.h"
+#include "packet.h"
 #include "soft-interface.h"
 #include "tp_meter.h"
 #include "translation-table.h"
@@ -141,6 +143,12 @@ batadv_netlink_mesh_info_put(struct sk_buff *msg, struct net_device *soft_iface)
 		       (u8)atomic_read(&bat_priv->tt.vn)))
 		goto out;
 
+#ifdef CONFIG_BATMAN_ADV_BLA
+	if (nla_put_u16(msg, BATADV_ATTR_BLA_CRC,
+			ntohs(bat_priv->bla.claim_dest.group)))
+		goto out;
+#endif
+
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (primary_if && primary_if->if_status == BATADV_IF_ACTIVE) {
 		hard_iface = primary_if->net_dev;
-- 
2.8.1
