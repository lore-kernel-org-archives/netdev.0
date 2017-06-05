From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/3] netvsc: fix rcu dereference warning from ethtool
Date: Mon,  5 Jun 2017 14:10:08 -0700
Message-ID: <20170605211010.9571-2-sthemmin@microsoft.com>
References: <20170605211010.9571-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36327 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdFEVKV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:10:21 -0400
Received: by mail-pg0-f46.google.com with SMTP id a70so18471558pge.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 14:10:21 -0700 (PDT)
In-Reply-To: <20170605211010.9571-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool info command calls the netvsc get_sset_count with RTNL
but not with RCU. Which causes warning:

drivers/net/hyperv/netvsc_drv.c:1010 suspicious rcu_dereference_check() usage!

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..d93e4da25fd2 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1028,7 +1028,7 @@ static const struct {
 static int netvsc_get_sset_count(struct net_device *dev, int string_set)
 {
 	struct net_device_context *ndc = netdev_priv(dev);
-	struct netvsc_device *nvdev = rcu_dereference(ndc->nvdev);
+	struct netvsc_device *nvdev = rtnl_dereference(ndc->nvdev);
 
 	if (!nvdev)
 		return -ENODEV;
-- 
2.11.0
