From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ehea: Remove unnecessary memset of stats in netdev private data
Date: Tue, 29 Nov 2016 14:35:07 +0100
Message-ID: <20161129133507.5008-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Douglas Miller <dougmill@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:50600 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754011AbcK2NfM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 08:35:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for netdev private data is allocated using kzalloc/vzalloc in
alloc_netdev_mqs, thus there is no need to zero the stats portion of it
again in the driver's probe function.

In any case, the size for the memset is wrong as the stats member is of
type rtnl_link_stats64, not net_device_stats.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index fa66fa6f8bee..702446a93697 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3044,7 +3044,6 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	init_waitqueue_head(&port->swqe_avail_wq);
 	init_waitqueue_head(&port->restart_wq);
 
-	memset(&port->stats, 0, sizeof(struct net_device_stats));
 	ret = register_netdev(dev);
 	if (ret) {
 		pr_err("register_netdev failed. ret=%d\n", ret);
-- 
2.11.0.rc3.5.g7cdf2ab.dirty
