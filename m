From: YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH net] tg3: don't clear stats while tg3_close
Date: Wed, 3 May 2017 15:51:32 +0800
Message-ID: <20170503075132.2648-1-yuehaibing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <weiyongjun1@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5913 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751042AbdECHx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 03:53:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now tg3 NIC's stats will be cleared after ifdown/ifup. bond_get_stats traverse
its salves to get statistics,cumulative the increment.If a tg3 NIC is added to
bonding as a slave,ifdown/ifup will cause bonding's stats become tremendous value
(ex.1638.3 PiB) because of negative increment.

Fixes: 92feeabf3f67 ("tg3: Save stats across chip resets")
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 30d1eb9..29beba1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11722,10 +11722,6 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_stop(tp);
 
-	/* Clear stats across close / open calls */
-	memset(&tp->net_stats_prev, 0, sizeof(tp->net_stats_prev));
-	memset(&tp->estats_prev, 0, sizeof(tp->estats_prev));
-
 	if (pci_device_is_present(tp->pdev)) {
 		tg3_power_down_prepare(tp);
 
-- 
2.5.0
