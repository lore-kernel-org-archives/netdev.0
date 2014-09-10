From: <yes-KgLukfWpBlCctlrPMvKcciBecyulp+rMXqFh9Ls21Oc@public.gmane.org>
Subject: [Patch v3 net-next 02/12] net:fec: add enet AVB feature macro define for imx6sx
Date: Thu, 11 Sep 2014 02:30:03 +0800
Message-ID: <5769.14648195288$1410375266@news.gmane.org>
References: <1410373813-5731-1-git-send-email-yes>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410373813-5731-1-git-send-email-yes>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

Add enet AVB feature macro define for imx6sx.

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
