From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 1/3] can: m_can: Make hclk optional
Date: Wed, 19 Jul 2017 18:09:24 -0500
Message-ID: <20170719230926.10872-2-fcooper@ti.com>
References: <20170719230926.10872-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170719230926.10872-1-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hclk is the MCAN's interface clock. However, for OMAP based devices such as
DRA7 SoC family the interface clock is handled by hwmod. Therefore, this
interface clock is managed by hwmod driver via pm_runtime_get and
pm_runtime_put calls. Therefore, this interface clock isn't defined in DT
and thus the driver shouldn't fail if this clock isn't found.

Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
---
 drivers/net/can/m_can/m_can.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index f4947a7..7fe9145 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1568,8 +1568,13 @@ static int m_can_plat_probe(struct platform_device *pdev)
 	hclk = devm_clk_get(&pdev->dev, "hclk");
 	cclk = devm_clk_get(&pdev->dev, "cclk");
 
-	if (IS_ERR(hclk) || IS_ERR(cclk)) {
-		dev_err(&pdev->dev, "no clock found\n");
+	if (IS_ERR(hclk)) {
+		dev_warn(&pdev->dev, "can't find hclk\n");
+		hclk = 0;
+	}
+
+	if (IS_ERR(cclk)) {
+		dev_err(&pdev->dev, "cclk could not be found\n");
 		ret = -ENODEV;
 		goto failed_ret;
 	}
-- 
2.10.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
