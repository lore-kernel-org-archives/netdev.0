From: Robin Holt <holt@sgi.com>
Subject: [RFC 3/5] [flexcan] Add of_match to platform_device definition.
Date: Sat,  6 Aug 2011 09:34:28 -0500
Message-ID: <1312641270-6018-4-git-send-email-holt@sgi.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:54452 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752191Ab1HFOee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Aug 2011 10:34:34 -0400
In-Reply-To: <1312641270-6018-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The OpenFirmware devices are not matched without specifying
an of_match array.  Introduce that array as that is used for
matching on the Freescale P1010 processor.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wolfgang Grandegger <wg@grandegger.com>
To: U Bhaskar-B22300 <B22300@freescale.com>
Cc: socketcan-core@lists.berlios.de
Cc: netdev@vger.kernel.org

---
I kept the of_match for "fsl,flexcan-v1.0" for the time being.  I will
happily drop it for final submission once I have a boot loader worked
up that matches on either string.
---
 drivers/net/can/flexcan.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ecdd4e6..d4ac81b 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1028,8 +1028,22 @@ static int __devexit flexcan_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static struct of_device_id flexcan_of_match[] = {
+	{
+		.compatible = "fsl,flexcan-v1.0",
+	},
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

