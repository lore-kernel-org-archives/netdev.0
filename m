From: Wei Yongjun <weiyj_lk@163.com>
Subject: [PATCH -next] net: axienet: Fix return value check in axienet_probe()
Date: Tue, 19 Jul 2016 11:23:24 +0000
Message-ID: <1468927404-32270-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, srikanth.thokala@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:53491 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbcGSLYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 07:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function of_parse_phandle() returns NULL
pointer not ERR_PTR(). The IS_ERR() test in the return value
check should be replaced with NULL test.

Fixes: 46aa27df8853 ('net: axienet: Use devm_* calls')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9c82993..36ee7ab 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1541,9 +1541,9 @@ static int axienet_probe(struct platform_device *pdev)
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
-	if (IS_ERR(np)) {
+	if (!np) {
 		dev_err(&pdev->dev, "could not find DMA node\n");
-		ret = PTR_ERR(np);
+		ret = -ENODEV;
 		goto free_netdev;
 	}
 	ret = of_address_to_resource(np, 0, &dmares);
