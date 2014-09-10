From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch v3 net-next 02/12] net:fec: add enet AVB feature macro define for imx6sx
Date: Thu, 11 Sep 2014 02:30:35 +0800
Message-ID: <1410373845-5801-3-git-send-email-Frank.Li@freescale.com>
References: <1410373845-5801-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux@arm.linux.org.uk>,
	Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0148.outbound.protection.outlook.com ([157.56.111.148]:18080
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753239AbaIJSym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 14:54:42 -0400
In-Reply-To: <1410373845-5801-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

Add enet AVB feature macro define for imx6sx.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index c21ecff1..ee9f04f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -104,6 +104,16 @@ static void set_multicast_list(struct net_device *ndev);
  * ENET_TDAR[TDAR].
  */
 #define FEC_QUIRK_ERR006358            (1 << 7)
+/* ENET IP hw AVB
+ *
+ * i.MX6SX ENET IP add Audio Video Bridging (AVB) feature support.
+ * - Two class indicators on receive with configurable priority
+ * - Two class indicators and line speed timer on transmit allowing
+ *   implementation class credit based shapers externally
+ * - Additional DMA registers provisioned to allow managing up to 3
+ *   independent rings
+ */
+#define FEC_QUIRK_HAS_AVB		(1 << 8)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -128,6 +138,12 @@ static struct platform_device_id fec_devtype[] = {
 		.name = "mvf600-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC,
 	}, {
+		.name = "imx6sx-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
+				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358 |
+				FEC_QUIRK_HAS_AVB,
+	}, {
 		/* sentinel */
 	}
 };
-- 
1.9.1
