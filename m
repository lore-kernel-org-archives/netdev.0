From: weiyj_lk@163.com
Subject: [PATCH] amd-xgbe: Fix error return code in xgbe_probe()
Date: Wed, 23 Jul 2014 08:59:40 +0800
Message-ID: <1406077180-28852-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:34480 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbaGWA76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 20:59:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the setting real tx queue
count error handling case instead of 0.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index c83584a..5a1891f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -339,7 +339,8 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Calculate the number of Tx and Rx rings to be created */
 	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
 				     pdata->hw_feat.tx_ch_cnt);
-	if (netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count)) {
+	ret = netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count);
+	if (ret) {
 		dev_err(dev, "error setting real tx queue count\n");
 		goto err_io;
 	}
