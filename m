From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: remove unnecessary carrier status check
Date: Wed, 26 Apr 2017 17:49:38 +0800
Message-ID: <1493200178-6413-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:18275 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1956686AbdDZJtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since netif_carrier_on() will do nothing if device's carrier is already
on, so it's unnecessary to do carrier status check.

It's the same for netif_carrier_off().

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/dev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index db6e315..1d02c5a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7104,13 +7104,10 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 	else
 		netif_dormant_off(dev);
 
-	if (netif_carrier_ok(rootdev)) {
-		if (!netif_carrier_ok(dev))
-			netif_carrier_on(dev);
-	} else {
-		if (netif_carrier_ok(dev))
-			netif_carrier_off(dev);
-	}
+	if (netif_carrier_ok(rootdev))
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
-- 
1.8.3.1
