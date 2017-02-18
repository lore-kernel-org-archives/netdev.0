From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] net: ena: remove superfluous check in ena_remove()
Date: Sat, 18 Feb 2017 12:19:41 +0100
Message-ID: <1487416781-3431-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: saeed@annapurnalabs.com, zorik@annapurnalabs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:64148 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932090AbdBRLUW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 06:20:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check in ena_remove() for the pci driver data not being NULL is not
needed, since it is always set in the probe() function. Remove the
superfluous check.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index d8c920b..35f1943 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3163,12 +3163,6 @@ static void ena_remove(struct pci_dev *pdev)
 	struct ena_com_dev *ena_dev;
 	struct net_device *netdev;
 
-	if (!adapter)
-		/* This device didn't load properly and it's resources
-		 * already released, nothing to do
-		 */
-		return;
-
 	ena_dev = adapter->ena_dev;
 	netdev = adapter->netdev;
 
-- 
2.7.4
