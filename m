From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: flexcan: disable bus error interrupts for the i.MX6q
Date: Wed, 24 Oct 2012 11:06:15 +0200
Message-ID: <1351069576-20790-2-git-send-email-mkl@pengutronix.de>
References: <1351069576-20790-1-git-send-email-mkl@pengutronix.de>
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Hui Wang <jason77.wang@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1351069576-20790-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>

This patch adds some Flexcan version info and removes the feature flag
FLEXCAN_HAS_BROKEN_ERR_STATE for the i.MX6Q. It also has the line [TR]WRN_INT
properly connected.

Cc: Hui Wang <jason77.wang@gmail.com>
Cc: Shawn Guo <shawn.guo@linaro.org>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
[mkl: convert to incremental patch]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index c78ecfc..a412bf6 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -144,9 +144,22 @@
 
 #define FLEXCAN_MB_CODE_MASK		(0xf0ffffff)
 
-/* FLEXCAN hardware feature flags */
+/*
+ * FLEXCAN hardware feature flags
+ *
+ * Below is some version info we got:
+ *    SOC   Version   IP-Version  Glitch-  [TR]WRN_INT
+ *                                Filter?   connected?
+ *   MX25  FlexCAN2  03.00.00.00     no         no
+ *   MX28  FlexCAN2  03.00.04.00    yes        yes
+ *   MX35  FlexCAN2  03.00.00.00     no         no
+ *   MX53  FlexCAN2  03.00.00.00    yes         no
+ *   MX6s  FlexCAN3  10.00.12.00    yes        yes
+ *
+ * Some SOCs do not have the RX_WARN & TX_WARN interrupt line connected.
+ */
 #define FLEXCAN_HAS_V10_FEATURES	BIT(1) /* For core version >= 10 */
-#define FLEXCAN_HAS_BROKEN_ERR_STATE	BIT(2) /* Broken error state handling */
+#define FLEXCAN_HAS_BROKEN_ERR_STATE	BIT(2) /* [TR]WRN_INT not connected */
 
 /* Structure of the message buffer */
 struct flexcan_mb {
@@ -205,7 +218,7 @@ static struct flexcan_devtype_data fsl_p1010_devtype_data = {
 };
 static struct flexcan_devtype_data fsl_imx28_devtype_data;
 static struct flexcan_devtype_data fsl_imx6q_devtype_data = {
-	.features = FLEXCAN_HAS_V10_FEATURES | FLEXCAN_HAS_BROKEN_ERR_STATE,
+	.features = FLEXCAN_HAS_V10_FEATURES,
 };
 
 static const struct can_bittiming_const flexcan_bittiming_const = {
-- 
1.7.10

