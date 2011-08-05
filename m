From: Robin Holt <holt@sgi.com>
Subject: [RFC 3/4] [flexcan] Add of_match to platform_device definition.
Date: Thu,  4 Aug 2011 21:06:18 -0500
Message-ID: <1312509979-13226-4-git-send-email-holt@sgi.com>
References: <1312509979-13226-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:47526 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754906Ab1HECGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 22:06:22 -0400
In-Reply-To: <1312509979-13226-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the of_device stuff got moved under the
platform_device->driver and all we should need to do is define an of_match
to get a flexcan_probe call out.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Cc: socketcan-core@lists.berlios.de
Cc: netdev@vger.kernel.org
---
 drivers/net/can/flexcan.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 3417d0b..fbb61c6 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1129,8 +1129,19 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static struct of_device_id flexcan_of_match[] = {
+	{
+		.compatible = "fsl,flexcan",
+	},
+	{},
+};
+
 static struct platform_driver flexcan_driver = {
-	.driver.name = DRV_NAME,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = flexcan_of_match,
+	},
 	.probe = flexcan_probe,
 	.remove = __devexit_p(flexcan_remove),
 };
-- 
1.7.2.1

