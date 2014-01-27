From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: ipv4: Use PTR_ERR_OR_ZERO
Date: Mon, 27 Jan 2014 12:13:57 +0530
Message-ID: <1390805037-20540-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org, patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:52258 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbaA0Gsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:48:37 -0500
Received: by mail-pb0-f53.google.com with SMTP id md12so5500902pbc.40
        for <netdev@vger.kernel.org>; Sun, 26 Jan 2014 22:48:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTR_RET is deprecated. Use PTR_ERR_OR_ZERO instead. While at it
also include missing err.h header.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 net/ipv4/ip_tunnel.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c0e3cb72ad70..bd28f386bd02 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -40,6 +40,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/rculist.h>
+#include <linux/err.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -930,7 +931,7 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 	}
 	rtnl_unlock();
 
-	return PTR_RET(itn->fb_tunnel_dev);
+	return PTR_ERR_OR_ZERO(itn->fb_tunnel_dev);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init_net);
 
-- 
1.7.9.5
