From: <Frank.Li@freescale.com>
Subject: [Patch v4 net-next 02/12] net:fec: add enet AVB feature macro define
 for imx6sx
Date: Sat, 13 Sep 2014 05:00:47 +0800
Message-ID: <1410555657-10744-3-git-send-email-Frank.Li@freescale.com>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
 Fugang Duan <B38611@freescale.com>, linux@arm.linux.org.uk,
 shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: <b38611@freescale.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
 <lznuaa@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

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
