From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 1/2] e1000e: Don't return uninitialized stats
Date: Fri, 21 Apr 2017 14:20:11 -0700
Message-ID: <20170421212012.25950-1-bpoirier@suse.com>
Cc: Stefan Priebe <s.priebe@profihost.ag>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35340 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041465AbdDUVUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 17:20:33 -0400
Received: by mail-it0-f66.google.com with SMTP id e132so270390ite.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 14:20:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some statistics passed to ethtool are garbage because e1000e_get_stats64()
doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
memory to userspace and confuses users.

Do like ixgbe and use dev_get_stats() which first zeroes out
rtnl_link_stats64.

Reported-by: Stefan Priebe <s.priebe@profihost.ag>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 7aff68a4a4df..f117b90cdc2f 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -2063,7 +2063,7 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 
 	pm_runtime_get_sync(netdev->dev.parent);
 
-	e1000e_get_stats64(netdev, &net_stats);
+	dev_get_stats(netdev, &net_stats);
 
 	pm_runtime_put_sync(netdev->dev.parent);
 
-- 
2.12.2
