From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V2 13/14] i2c: imx: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 09:10:28 +0800
Message-ID: <1320973829-4388-14-git-send-email-richard.zhao@linaro.org>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.kucheria@canonical.com, linux@arm.linux.org.uk, kernel@pengutronix.de,
 eric.miao@linaro.org, ben-linux@fluff.org, cjb@laptop.org,
 Richard Zhao <richard.zhao@linaro.org>, alan@linux.intel.com
To: <linux-arm-kernel@lists.infradead.org>, <linux-i2c@vger.kernel.org>,
 <linux-mmc@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-serial@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

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
