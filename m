From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] forcedeth: remove unnecessary carrier status check
Date: Wed,  3 May 2017 00:43:42 -0400
Message-ID: <1493786622-16654-1-git-send-email-yanjun.zhu@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29675 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdECEn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:43:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since netif_carrier_on() will do nothing if device's
carrier is already on, so it's unnecessary to do
carrier status check.

It's the same for netif_carrier_off().

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 978d329..aa912f4 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4248,11 +4248,9 @@ static int nv_get_link_ksettings(struct net_device *dev,
 		/* We do not track link speed / duplex setting if the
 		 * interface is disabled. Force a link check */
 		if (nv_update_linkspeed(dev)) {
-			if (!netif_carrier_ok(dev))
-				netif_carrier_on(dev);
+			netif_carrier_on(dev);
 		} else {
-			if (netif_carrier_ok(dev))
-				netif_carrier_off(dev);
+			netif_carrier_off(dev);
 		}
 	}
 
-- 
2.7.4
