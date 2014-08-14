From: weiyj_lk@163.com
Subject: [PATCH] can: c_can: Fix return value check in c_can_plat_probe()
Date: Thu, 14 Aug 2014 08:58:59 +0800
Message-ID: <1407977939-15287-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Chen Gang <gang.chen@asianux.com>,
	George Cherian <george.cherian@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Pavel Machek <pavel@denx.de>, Thor Thayer <tthayer@altera.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Wolfram Sang <wsa@sang-engineering.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function devm_ioremap() returns NULL pointer
not ERR_PTR(). The IS_ERR() test in the return value check should
be replaced with NULL test.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/can/c_can/c_can_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 5dede6e..109cb44 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -280,7 +280,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 
 		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
 						     resource_size(res));
-		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
+		if (!priv->raminit_ctrlreg || priv->instance < 0)
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
 		else
 			priv->raminit = c_can_hw_raminit_ti;

