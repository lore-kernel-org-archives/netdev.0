From: Andy Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 2/2] net: fec: use a more proper compatible string for i.MX6UL type device
Date: Wed, 22 Jun 2016 18:52:36 +0800
Message-ID: <1466592756-11239-3-git-send-email-fugang.duan@nxp.com>
References: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0089.outbound.protection.outlook.com ([207.46.100.89]:19690
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751244AbcFVMax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 08:30:53 -0400
In-Reply-To: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i.MX6UL is a member in i.MX series family, the SOC FEC inherits from
i.MX6SX but removes some IP features, lets define a new type for fec
device.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8afef20..4040003 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -113,6 +113,12 @@ static struct platform_device_id fec_devtype[] = {
 				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE |
 				FEC_QUIRK_HAS_RACC | FEC_QUIRK_HAS_COALESCE,
 	}, {
+		.name = "imx6ul-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
+				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_BUG_CAPTURE |
+				FEC_QUIRK_HAS_RACC | FEC_QUIRK_HAS_COALESCE,
+	}, {
 		/* sentinel */
 	}
 };
@@ -125,6 +131,7 @@ enum imx_fec_type {
 	IMX6Q_FEC,
 	MVF600_FEC,
 	IMX6SX_FEC,
+	IMX6UL_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
@@ -134,6 +141,7 @@ static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
 	{ .compatible = "fsl,mvf600-fec", .data = &fec_devtype[MVF600_FEC], },
 	{ .compatible = "fsl,imx6sx-fec", .data = &fec_devtype[IMX6SX_FEC], },
+	{ .compatible = "fsl,imx6ul-fec", .data = &fec_devtype[IMX6UL_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
-- 
1.9.1
