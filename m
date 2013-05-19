From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH] net: fec: use a more proper compatible string for MVF type device
Date: Sun, 19 May 2013 22:38:46 +0800
Message-ID: <1368974326-24069-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Jingchang Lu <b35083@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:2553 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752561Ab3ESOin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 10:38:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MVF is a family while MVF600 is a particular SoC in the family.  We
generally prefer to use SoC rather than family name in compatible string
to define a particular type of fec device.  And this is how fec_dt_ids
works for all those IMX fec variants.  Let's change mvf to mvf600 to
have it work in the same way.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 658fbc1..ce7b638 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -109,7 +109,7 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM,
 	}, {
-		.name = "mvf-fec",
+		.name = "mvf600-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC,
 	}, {
 		/* sentinel */
@@ -122,7 +122,7 @@ enum imx_fec_type {
 	IMX27_FEC,	/* runs on i.mx27/35/51 */
 	IMX28_FEC,
 	IMX6Q_FEC,
-	MVF_FEC,
+	MVF600_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
@@ -130,7 +130,7 @@ static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx27-fec", .data = &fec_devtype[IMX27_FEC], },
 	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },
 	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
-	{ .compatible = "fsl,mvf-fec", .data = &fec_devtype[MVF_FEC], },
+	{ .compatible = "fsl,mvf600-fec", .data = &fec_devtype[MVF600_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
-- 
1.7.9.5
