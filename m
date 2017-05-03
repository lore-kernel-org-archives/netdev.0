From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 04/15] netvsc: don't reacquire rtnl on device removal
Date: Wed,  3 May 2017 16:01:06 -0700
Message-ID: <20170503230117.20070-5-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33912 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752065AbdECXBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:24 -0400
Received: by mail-pf0-f176.google.com with SMTP id e64so1765257pfd.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:24 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since rtnl_lock is already held in netvsc_remove, it is easier
to just call unregister_netdevice which expects RTNL.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..3fef45421634 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1630,10 +1630,9 @@ static int netvsc_remove(struct hv_device *dev)
 	 */
 	rtnl_lock();
 	rndis_filter_device_remove(dev, ndev_ctx->nvdev);
+	unregister_netdevice(net);
 	rtnl_unlock();
 
-	unregister_netdev(net);
-
 	hv_set_drvdata(dev, NULL);
 
 	free_netdev(net);
-- 
2.11.0
