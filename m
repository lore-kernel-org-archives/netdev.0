From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 08/11] net/can/mpc52xx_can: improve properties and their
	description
Date: Mon, 16 Nov 2009 23:57:51 +0100
Message-ID: <1258412274-14686-9-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
---
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +++++----
 drivers/net/can/mscan/mpc52xx_can.c                |    3 +--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
index b151fb1..cabc780 100644
--- a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
@@ -181,9 +181,10 @@ External interrupts:
 fsl,mpc5200-mscan nodes
 -----------------------
 In addition to the required compatible-, reg- and interrupt-properites, you can
-also specify which clock shall be used for the bus:
+also specify which clock source shall be used for the controller:
 
-- fsl,mscan-clk-src	- a string describing the clock source. Valid values
-			  are "ip" for IP_CLK and "sys" for SYS_XTAL.
-			  "sys" is the default in case the property is not
+- fsl,mscan-clock-source- a string describing the clock source. Valid values
+			  are:	"ip" for ip bus clock
+				"ref" for reference clock (XTAL)
+			  "ref" is default in case this property is not
 			  present.
diff --git a/drivers/net/can/mscan/mpc52xx_can.c b/drivers/net/can/mscan/mpc52xx_can.c
index a915959..1de6f63 100644
--- a/drivers/net/can/mscan/mpc52xx_can.c
+++ b/drivers/net/can/mscan/mpc52xx_can.c
@@ -130,7 +130,7 @@ static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
 	 * choice as it has less jitter. For this reason, it is selected
 	 * by default.
 	 */
-	clk_src = of_get_property(np, "fsl,mscan-clk-src", NULL);
+	clk_src = of_get_property(np, "fsl,mscan-clock-source", NULL);
 	if (clk_src && strcmp(clk_src, "ip") == 0)
 		clock_src = MSCAN_CLKSRC_BUS;
 	else
@@ -227,7 +227,6 @@ static int mpc5xxx_can_resume(struct of_device *ofdev)
 
 static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
 	{.compatible = "fsl,mpc5200-mscan"},
-	{.compatible = "fsl,mpc5200b-mscan"},
 	{},
 };
 
-- 
1.6.3.3
