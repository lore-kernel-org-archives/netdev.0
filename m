From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning to debug message
Date: Wed, 21 Sep 2011 19:10:30 +0800
Message-ID: <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<patches@linaro.org>, Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:39177 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab1IULBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:01:53 -0400
In-Reply-To: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC can work without a phy reset on some platforms, which means not
very platform necessarily have a phy-reset gpio encoded in device tree.
So it makes more sense to have the phy-reset-gpio request failure as
a debug message rather than a warning.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 158b82e..a057abf 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1422,7 +1422,7 @@ static int __devinit fec_reset_phy(struct platform_device *pdev)
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
 	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
+		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
 		return err;
 	}
 	msleep(1);
-- 
1.7.4.1
