From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next 2/2] ibmveth: Free irq on error path
Date: Wed, 20 Oct 2010 14:21:51 +0000
Message-ID: <20101020142151.GA1846@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rcj@linux.vnet.ibm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:44181 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109Ab0JTOWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 10:22:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free irq on error path.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ibmveth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 2ae8336..c454b45 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -641,7 +641,7 @@ static int ibmveth_open(struct net_device *netdev)
 	if (!adapter->bounce_buffer) {
 		netdev_err(netdev, "unable to allocate bounce buffer\n");
 		rc = -ENOMEM;
-		goto err_out;
+		goto err_out_free_irq;
 	}
 	adapter->bounce_buffer_dma =
 	    dma_map_single(&adapter->vdev->dev, adapter->bounce_buffer,
@@ -649,7 +649,7 @@ static int ibmveth_open(struct net_device *netdev)
 	if (dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
 		netdev_err(netdev, "unable to map bounce buffer\n");
 		rc = -ENOMEM;
-		goto err_out;
+		goto err_out_free_irq;
 	}
 
 	netdev_dbg(netdev, "initial replenish cycle\n");
@@ -661,6 +661,8 @@ static int ibmveth_open(struct net_device *netdev)
 
 	return 0;
 
+err_out_free_irq:
+	free_irq(netdev->irq, netdev);
 err_out:
 	ibmveth_cleanup(adapter);
 	napi_disable(&adapter->napi);
-- 
1.7.2.2

