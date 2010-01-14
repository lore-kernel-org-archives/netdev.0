From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next-2.6] can: mscan-mpc5xxx: fix broken support for the
	MPC5200
Date: Thu, 14 Jan 2010 12:05:48 +0100
Message-ID: <4B4EFA8C.4010209@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>

Due to an invalid "#ifdef CONFIG_PPC_MPC5200", the real clock setup
function was not called for the MPC5200.

Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index f73487f..03e7c48 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -43,7 +43,7 @@ struct mpc5xxx_can_data {
 			 int *mscan_clksrc);
 };
 
-#ifdef CONFIG_PPC_MPC5200
+#ifdef CONFIG_PPC_MPC52xx
 static struct of_device_id __devinitdata mpc52xx_cdm_ids[] = {
 	{ .compatible = "fsl,mpc5200-cdm", },
 	{}
@@ -84,7 +84,7 @@ static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
 	/* Determine SYS_XTAL_IN frequency from the clock domain settings */
 	np_cdm = of_find_matching_node(NULL, mpc52xx_cdm_ids);
 	if (!np_cdm) {
-		dev_err(&of->dev, "can't get clock node!\n");
+		dev_err(&ofdev->dev, "can't get clock node!\n");
 		return 0;
 	}
 	cdm = of_iomap(np_cdm, 0);
@@ -101,14 +101,14 @@ static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
 
 	return freq;
 }
-#else /* !CONFIG_PPC_MPC5200 */
+#else /* !CONFIG_PPC_MPC52xx */
 static u32 __devinit mpc52xx_can_get_clock(struct of_device *ofdev,
 					   const char *clock_name,
 					   int *mscan_clksrc)
 {
 	return 0;
 }
-#endif /* CONFIG_PPC_MPC5200 */
+#endif /* CONFIG_PPC_MPC52xx */
 
 #ifdef CONFIG_PPC_MPC512x
 struct mpc512x_clockctl {
-- 
1.6.2.5
