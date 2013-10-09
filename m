From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/3] can: flexcan: fix mx28 detection by rearanging OF match table
Date: Wed,  9 Oct 2013 23:11:57 +0200
Message-ID: <1381353118-25111-3-git-send-email-mkl@pengutronix.de>
References: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52486 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538Ab3JIVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 17:12:05 -0400
In-Reply-To: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implemetation of of_match_device() relies that the of_device_id
table in the driver is sorted from most specific to least specific compatible.

Without this patch the mx28 is detected as the less specific p1010. This leads
to a p1010 specific workaround is activated on the mx28, which is not needed.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index f028c5d..8f5ce74 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -985,9 +985,9 @@ static void unregister_flexcandev(struct net_device *dev)
 }
 
 static const struct of_device_id flexcan_of_match[] = {
-	{ .compatible = "fsl,p1010-flexcan", .data = &fsl_p1010_devtype_data, },
-	{ .compatible = "fsl,imx28-flexcan", .data = &fsl_imx28_devtype_data, },
 	{ .compatible = "fsl,imx6q-flexcan", .data = &fsl_imx6q_devtype_data, },
+	{ .compatible = "fsl,imx28-flexcan", .data = &fsl_imx28_devtype_data, },
+	{ .compatible = "fsl,p1010-flexcan", .data = &fsl_p1010_devtype_data, },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, flexcan_of_match);
-- 
1.8.4.rc3
