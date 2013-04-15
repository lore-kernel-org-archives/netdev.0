From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: fix error return code in macb_probe()
Date: Mon, 15 Apr 2013 10:04:33 +0200
Message-ID: <1366013073-22934-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	<yongjun_wei@trendmicro.com.cn>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Original-idea-by: <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Hi,

This fix was written originally for at91_ether.c and I found it interesting
to adapt it to macb.
Thanks to Wei Yongjun for finding it.

Best regards,

 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7fd0e3e..6be513d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1602,9 +1602,9 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_free_irq;
 	}
 
-	if (macb_mii_init(bp) != 0) {
+	err = macb_mii_init(bp);
+	if (err)
 		goto err_out_unregister_netdev;
-	}
 
 	platform_set_drvdata(pdev, dev);
 
-- 
1.8.0
