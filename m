From: weiyj_lk@163.com
Subject: [PATCH -next] net: mvpp2: Fix error return code in mvpp2_probe()
Date: Sun, 20 Jul 2014 22:02:43 +0800
Message-ID: <1405864963-14217-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:46684 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbaGTODD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 10:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -ENODEV from the no ports enabled error handling
case instead of 0.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/marvell/mvpp2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index f4de2a9..1a9f848 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6308,6 +6308,7 @@ static int mvpp2_probe(struct platform_device *pdev)
 	port_count = of_get_available_child_count(dn);
 	if (port_count == 0) {
 		dev_err(&pdev->dev, "no ports enabled\n");
+		err = -ENODEV;
 		goto err_gop_clk;
 	}
 
