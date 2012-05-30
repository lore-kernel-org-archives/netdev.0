From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] can: cc770: Fix likely misuse of | for &
Date: Wed, 30 May 2012 13:25:55 -0700
Message-ID: <6c251b03dc626215cf696e894ac1cdda530f38d9.1338408931.git.joe@perches.com>
References: <cover.1338408931.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1338408931.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using | with a constant is always true.
Likely this should have be &.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/cc770/cc770_platform.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index 53115ee..688371c 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -154,7 +154,7 @@ static int __devinit cc770_get_platform_data(struct platform_device *pdev,
 	struct cc770_platform_data *pdata = pdev->dev.platform_data;
 
 	priv->can.clock.freq = pdata->osc_freq;
-	if (priv->cpu_interface | CPUIF_DSC)
+	if (priv->cpu_interface & CPUIF_DSC)
 		priv->can.clock.freq /= 2;
 	priv->clkout = pdata->cor;
 	priv->bus_config = pdata->bcr;
-- 
1.7.8.111.gad25c.dirty
