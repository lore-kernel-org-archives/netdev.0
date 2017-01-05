From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: xilinx: emaclite: Remove xemaclite_remove_ndev()
Date: Thu,  5 Jan 2017 10:41:36 +0100
Message-ID: <20170105094136.16989-1-tklauser@distanz.ch>
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:35262 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762466AbdAEJlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 04:41:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xemaclite_remove_ndev() is a simple wrapper around free_netdev()
checking for NULL before the call. All possible paths calling
it are guaranteed to pass a non-NULL argument, so rather call
free_netdev() directly.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 93dc10b10c09..97dcc0bd5a85 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1029,20 +1029,6 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 }
 
 /**
- * xemaclite_remove_ndev - Free the network device
- * @ndev:	Pointer to the network device to be freed
- *
- * This function un maps the IO region of the Emaclite device and frees the net
- * device.
- */
-static void xemaclite_remove_ndev(struct net_device *ndev)
-{
-	if (ndev) {
-		free_netdev(ndev);
-	}
-}
-
-/**
  * get_bool - Get a parameter from the OF device
  * @ofdev:	Pointer to OF device structure
  * @s:		Property to be retrieved
@@ -1172,7 +1158,7 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	return 0;
 
 error:
-	xemaclite_remove_ndev(ndev);
+	free_netdev(ndev);
 	return rc;
 }
 
@@ -1204,7 +1190,7 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 	of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
 
-	xemaclite_remove_ndev(ndev);
+	free_netdev(ndev);
 
 	return 0;
 }
-- 
2.11.0
