From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH] xen-netfront: Remove the meaningless code
Date: Sat, 27 Jun 2015 07:17:26 +0800
Message-ID: <1435360646-7831-1-git-send-email-liang.z.li@intel.com>
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, andrew.bennieston@citrix.com,
	wei.liu2@citrix.com, davem@davemloft.net,
	Liang Li <liang.z.li@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25927 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbbFZL2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 07:28:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function netif_set_real_num_tx_queues() will return -EINVAL if
the second parameter < 1, so call this function with the second
parameter set to 0 is meaningless.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/net/xen-netfront.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 56d8afd..1807cd1 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1245,10 +1245,6 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	np                   = netdev_priv(netdev);
 	np->xbdev            = dev;
 
-	/* No need to use rtnl_lock() before the call below as it
-	 * happens before register_netdev().
-	 */
-	netif_set_real_num_tx_queues(netdev, 0);
 	np->queues = NULL;
 
 	err = -ENOMEM;
@@ -1900,9 +1896,6 @@ abort_transaction_no_dev_fatal:
 	xennet_disconnect_backend(info);
 	kfree(info->queues);
 	info->queues = NULL;
-	rtnl_lock();
-	netif_set_real_num_tx_queues(info->netdev, 0);
-	rtnl_unlock();
  out:
 	return err;
 }
-- 
1.9.1
