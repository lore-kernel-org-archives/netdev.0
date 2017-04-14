From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] netvsc: fix RCU warning in get_stats
Date: Fri, 14 Apr 2017 14:42:57 -0700
Message-ID: <20170414214258.3367-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35602 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbdDNVnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 17:43:01 -0400
Received: by mail-pf0-f170.google.com with SMTP id i5so44783863pfc.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 14:43:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics functionis called with RTNL held during probe
but with RCU held during access from /proc and elsewhere.
This is safe so update the lockdep annotation.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f24c2891dd0c..76489a06ef3b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -897,7 +897,7 @@ static void netvsc_get_stats64(struct net_device *net,
 			       struct rtnl_link_stats64 *t)
 {
 	struct net_device_context *ndev_ctx = netdev_priv(net);
-	struct netvsc_device *nvdev = rcu_dereference(ndev_ctx->nvdev);
+	struct netvsc_device *nvdev = rcu_dereference_rtnl(ndev_ctx->nvdev);
 	int i;
 
 	if (!nvdev)
-- 
2.11.0
