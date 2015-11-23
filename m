From: Saurabh Sengar <saurabh.truth@gmail.com>
Subject: [PATCH] net: fec: no need to test for the return type of of_property_read_u32
Date: Mon, 23 Nov 2015 19:21:48 +0530
Message-ID: <1448286708-4698-1-git-send-email-saurabh.truth@gmail.com>
Cc: Saurabh Sengar <saurabh.truth@gmail.com>
To: davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33325 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbbKWNwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 08:52:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in case of error no need to set num_tx and num_rx = 1, because in case of error
these variables will remain unchanged by of_property_read_u32 ie 1 only

Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2a3220..d2328fc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3277,7 +3277,6 @@ static void
 fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
 {
 	struct device_node *np = pdev->dev.of_node;
-	int err;
 
 	*num_tx = *num_rx = 1;
 
@@ -3285,13 +3284,9 @@ fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
 		return;
 
 	/* parse the num of tx and rx queues */
-	err = of_property_read_u32(np, "fsl,num-tx-queues", num_tx);
-	if (err)
-		*num_tx = 1;
+	of_property_read_u32(np, "fsl,num-tx-queues", num_tx);
 
-	err = of_property_read_u32(np, "fsl,num-rx-queues", num_rx);
-	if (err)
-		*num_rx = 1;
+	of_property_read_u32(np, "fsl,num-rx-queues", num_rx);
 
 	if (*num_tx < 1 || *num_tx > FEC_ENET_MAX_TX_QS) {
 		dev_warn(&pdev->dev, "Invalid num_tx(=%d), fall back to 1\n",
-- 
1.9.1
