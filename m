From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/15] batman-adv: Return EINVAL on invalid gw_bandwidth change
Date: Tue, 25 Aug 2015 13:02:33 +0200
Message-ID: <1440500559-28368-10-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:16984 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755439AbbHYLEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:04:01 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Invalid speed settings by the user are currently acknowledged as correct
but not stored. Instead the return of the store operation of the file
"gw_bandwidth" should indicate that the given value is not acceptable.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index c50931c..6b930a6 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -19,6 +19,7 @@
 #include "main.h"
 
 #include <linux/atomic.h>
+#include <linux/errno.h>
 #include <linux/byteorder/generic.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -160,7 +161,7 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 
 	ret = batadv_parse_gw_bandwidth(net_dev, buff, &down_new, &up_new);
 	if (!ret)
-		goto end;
+		return -EINVAL;
 
 	if (!down_new)
 		down_new = 1;
@@ -184,7 +185,6 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 	atomic_set(&bat_priv->gw.bandwidth_up, up_new);
 	batadv_gw_tvlv_container_update(bat_priv);
 
-end:
 	return count;
 }
 
-- 
2.5.0
