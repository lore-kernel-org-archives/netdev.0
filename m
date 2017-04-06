From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 04/19] batman-adv: Fix possible side-effects in _batadv_dbg
Date: Thu,  6 Apr 2017 16:07:26 +0200
Message-ID: <20170406140741.30745-5-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32924 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934924AbdDFOHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:47 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

An argument of a macro should not be evaluated multiple times. Otherwise
embedded operations in these arguments will be executed multiple times.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/log.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/log.h b/net/batman-adv/log.h
index 7a2b9f4da078..65ce97efa6b5 100644
--- a/net/batman-adv/log.h
+++ b/net/batman-adv/log.h
@@ -73,9 +73,10 @@ __printf(2, 3);
 /* possibly ratelimited debug output */
 #define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)		\
 	do {								\
-		if (atomic_read(&(bat_priv)->log_level) & (type) &&	\
+		struct batadv_priv *__batpriv = (bat_priv);		\
+		if (atomic_read(&__batpriv->log_level) & (type) &&	\
 		    (!(ratelimited) || net_ratelimit()))		\
-			batadv_debug_log(bat_priv, fmt, ## arg);	\
+			batadv_debug_log(__batpriv, fmt, ## arg);	\
 	}								\
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
-- 
2.11.0
