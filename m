From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 08/15] net: emaclite: Convert to use devm_ioremap_resource
Date: Mon, 10 Jun 2013 17:05:06 +0530
Message-ID: <1370864113-17895-9-git-send-email-tushar.behera@linaro.org>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
Cc: thierry.reding@gmail.com, patches@linaro.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
introduced devm_ioremap_resource() and deprecated the use of
devm_request_and_ioremap().

Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
CC: netdev@vger.kernel.org
CC: "David S. Miller" <davem@davemloft.net>
CC: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 1cd131b..fd4dbda 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1159,9 +1159,11 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	ndev->irq = res->start;
 
 	res = platform_get_resource(ofdev, IORESOURCE_MEM, 0);
-	lp->base_addr = devm_request_and_ioremap(&ofdev->dev, res);
-	if (!lp->base_addr)
+	lp->base_addr = devm_ioremap_resource(&ofdev->dev, res);
+	if (IS_ERR(lp->base_addr)) {
+		rc = PTR_ERR(lp->base_addr);
 		goto error;
+	}
 
 	ndev->mem_start = res->start;
 	ndev->mem_end = res->end;
-- 
1.7.9.5
