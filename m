From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: flexcan: use be32_to_cpup to handle the value of dt entry
Date: Wed, 27 Jun 2012 11:27:16 +0200
Message-ID: <1340789236-28266-2-git-send-email-mkl@pengutronix.de>
References: <1340789236-28266-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Hui Wang <jason77.wang@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52395 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2F0J1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 05:27:30 -0400
In-Reply-To: <1340789236-28266-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hui Wang <jason77.wang@gmail.com>

The freescale arm i.MX series platform can support this driver, and
usually the arm cpu works in the little endian mode by default, while
device tree entry value is stored in big endian format, we should use
be32_to_cpup() to handle them, after modification, it can work well
both on the le cpu and be cpu.

Cc: stable <stable@vger.kernel.org> # v3.2+
Cc: Shawn Guo <shawn.guo@linaro.org>
Signed-off-by: Hui Wang <jason77.wang@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 38c0690..81d4741 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -939,12 +939,12 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 		return PTR_ERR(pinctrl);
 
 	if (pdev->dev.of_node) {
-		const u32 *clock_freq_p;
+		const __be32 *clock_freq_p;
 
 		clock_freq_p = of_get_property(pdev->dev.of_node,
 						"clock-frequency", NULL);
 		if (clock_freq_p)
-			clock_freq = *clock_freq_p;
+			clock_freq = be32_to_cpup(clock_freq_p);
 	}
 
 	if (!clock_freq) {
-- 
1.7.10
