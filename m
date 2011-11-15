From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V4 13/14] i2c: imx: add clk_prepare/clk_unprepare
Date: Tue, 15 Nov 2011 14:48:08 +0800
Message-ID: <1321339689-25256-14-git-send-email-richard.zhao@linaro.org>
References: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@arm.linux.org.uk>, <amit.kucheria@canonical.com>,
	<kernel@pengutronix.de>, <ben-linux@fluff.org>, <cjb@laptop.org>,
	<alan@linux.intel.com>, <eric.miao@linaro.org>,
	<richard.zhao@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>,
	<linux-i2c@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-serial@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-va3.bigfish.com ([216.32.180.10]:2849 "EHLO
	VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753136Ab1KOGtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 01:49:15 -0500
In-Reply-To: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's for migrating to generic clk framework API.

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 drivers/i2c/busses/i2c-imx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/i2c/busses/i2c-imx.c b/drivers/i2c/busses/i2c-imx.c
index 58832e5..8d1ab6f 100644
--- a/drivers/i2c/busses/i2c-imx.c
+++ b/drivers/i2c/busses/i2c-imx.c
@@ -196,7 +196,7 @@ static int i2c_imx_start(struct imx_i2c_struct *i2c_imx)
 
 	dev_dbg(&i2c_imx->adapter.dev, "<%s>\n", __func__);
 
-	clk_enable(i2c_imx->clk);
+	clk_prepare_enable(i2c_imx->clk);
 	writeb(i2c_imx->ifdr, i2c_imx->base + IMX_I2C_IFDR);
 	/* Enable I2C controller */
 	writeb(0, i2c_imx->base + IMX_I2C_I2SR);
@@ -245,7 +245,7 @@ static void i2c_imx_stop(struct imx_i2c_struct *i2c_imx)
 
 	/* Disable I2C controller */
 	writeb(0, i2c_imx->base + IMX_I2C_I2CR);
-	clk_disable(i2c_imx->clk);
+	clk_disable_unprepare(i2c_imx->clk);
 }
 
 static void __init i2c_imx_set_clk(struct imx_i2c_struct *i2c_imx,
-- 
1.7.5.4
