From: Wei Yongjun <weiyj_lk@163.com>
Subject: [PATCH -next] net: ethernet: nb8800: fix error handling of nb8800_probe()
Date: Tue, 19 Jul 2016 11:33:10 +0000
Message-ID: <1468927990-3041-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: f.fainelli@gmail.com, davem@davemloft.net, mans@mansr.com,
	tremyfr@gmail.com, arnd@arndb.de, sf84@laposte.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:34080 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbcGSLd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 07:33:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In ops->reset() error handling case, clk_disable_unprepare() is missed
before return from this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/aurora/nb8800.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 2dcb8c7..0d4ea92 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1419,7 +1419,7 @@ static int nb8800_probe(struct platform_device *pdev)
 	if (ops && ops->reset) {
 		ret = ops->reset(dev);
 		if (ret)
-			goto err_free_dev;
+			goto err_disable_clk;
 	}
 
 	bus = devm_mdiobus_alloc(&pdev->dev);
