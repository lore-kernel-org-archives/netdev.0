From: weiyj_lk@163.com
Subject: [PATCH -next] dwc_eth_qos: fix missing clk_disable_unprepare() on error in dwceqos_probe()
Date: Tue, 12 Jul 2016 11:43:37 +0000
Message-ID: <1468323817-6159-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:38744 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006AbcGLLny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 07:43:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix missing clk_disable_unprepare() call before return
from dwceqos_probe() in the error handling case of invalid
fixed-link.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index c34111b..fc1ea80 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2877,7 +2877,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 		ret = of_phy_register_fixed_link(lp->pdev->dev.of_node);
 		if (ret < 0) {
 			dev_err(&pdev->dev, "invalid fixed-link");
-			goto err_out_unregister_netdev;
+			goto err_out_unregister_clk_notifier;
 		}
 
 		lp->phy_node = of_node_get(lp->pdev->dev.of_node);
