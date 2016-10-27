From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 17/17] batman-adv: Avoid precedence issues in macros
Date: Thu, 27 Oct 2016 21:01:50 +0200
Message-ID: <20161027190150.7880-18-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38349 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964978AbcJ0TCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:02:01 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It must be avoided that arguments to a macro are evaluated ungrouped (which
enforces normal operator precendence). Otherwise the result of the macro
is not well defined.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/log.h    | 12 ++++++------
 net/batman-adv/main.h   |  4 ++--
 net/batman-adv/packet.h |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/log.h b/net/batman-adv/log.h
index e0e1a88..ab47acf 100644
--- a/net/batman-adv/log.h
+++ b/net/batman-adv/log.h
@@ -71,12 +71,12 @@ int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ...)
 __printf(2, 3);
 
 /* possibly ratelimited debug output */
-#define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)	\
-	do {							\
-		if (atomic_read(&bat_priv->log_level) & type && \
-		    (!ratelimited || net_ratelimit()))		\
-			batadv_debug_log(bat_priv, fmt, ## arg);\
-	}							\
+#define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)		\
+	do {								\
+		if (atomic_read(&(bat_priv)->log_level) & (type) &&	\
+		    (!(ratelimited) || net_ratelimit()))		\
+			batadv_debug_log(bat_priv, fmt, ## arg);	\
+	}								\
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
 __printf(4, 5)
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 6a2328d..daddca9 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -199,8 +199,8 @@ struct packet_type;
 struct seq_file;
 struct sk_buff;
 
-#define BATADV_PRINT_VID(vid) ((vid & BATADV_VLAN_HAS_TAG) ? \
-			       (int)(vid & VLAN_VID_MASK) : -1)
+#define BATADV_PRINT_VID(vid) (((vid) & BATADV_VLAN_HAS_TAG) ? \
+			       (int)((vid) & VLAN_VID_MASK) : -1)
 
 extern struct list_head batadv_hardif_list;
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index d2e9bbd..7a36bcf 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -21,7 +21,7 @@
 #include <asm/byteorder.h>
 #include <linux/types.h>
 
-#define batadv_tp_is_error(n) ((u8)n > 127 ? 1 : 0)
+#define batadv_tp_is_error(n) ((u8)(n) > 127 ? 1 : 0)
 
 /**
  * enum batadv_packettype - types for batman-adv encapsulated packets
-- 
2.10.1
