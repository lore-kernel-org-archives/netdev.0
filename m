From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH v4] net: fec: Do a sanity check on the gpio number
Date: Mon, 18 Feb 2013 17:20:31 -0300
Message-ID: <1361218831-17336-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <marex@denx.de>, <s.hauer@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.11] ([216.32.180.11]:36860 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754614Ab3BRUWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 15:22:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check whether the phy-reset GPIO is valid, prior to requesting it.

In the case a board does not provide a phy-reset GPIO, just returns immediately.

With such gpio validation in place, it is also safe to change from pr_debug to 
dev_err in the case the gpio request fails.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Change since v3:
- Do not refer to a commit that is in linux-next
Changes since v2:
- Merge the two patches into a single one, and use dev_err
Changes since v1:
- Added Shawn's ack
 drivers/net/ethernet/freescale/fec.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0fe68c4..1a2071b 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1689,10 +1689,13 @@ static void fec_reset_phy(struct platform_device *pdev)
 		msec = 1;
 
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (!gpio_is_valid(phy_reset))
+		return;
+
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
 				    GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
+		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-- 
1.7.9.5
