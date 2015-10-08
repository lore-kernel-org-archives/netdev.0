From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next 1/2] net: Fix Hisilicon Network Subsystem compilation warning
Date: Thu, 8 Oct 2015 14:17:24 +0800
Message-ID: <1444285045-23275-2-git-send-email-huangdaode@hisilicon.com>
References: <1444285045-23275-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:52299 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbJHGB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:01:59 -0400
In-Reply-To: <1444285045-23275-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix a compilation warning on arm 32-bit platform

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index 0a0a9e8..ccbb666 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -448,12 +448,12 @@ static ssize_t handles_show(struct device *dev,
 		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
 			    i++, h->eport_id, h->dev->name);
 		for (j = 0; j < h->q_num; j++) {
-			s += sprintf(buf + s, "\tqueue[%d] on 0x%llx\n",
-				     j, (u64)h->qs[i]->io_base);
-#define HANDEL_TX_MSG "\t\ttx_ring on 0x%llx:%u,%u,%u,%u,%u,%llu,%llu\n"
+			s += sprintf(buf + s, "\tqueue[%d] on 0x%p\n",
+				     j, h->qs[i]->io_base);
+#define HANDEL_TX_MSG "\t\ttx_ring on 0x%p:%u,%u,%u,%u,%u,%llu,%llu\n"
 			s += sprintf(buf + s,
 				     HANDEL_TX_MSG,
-				     (u64)h->qs[i]->tx_ring.io_base,
+				     h->qs[i]->tx_ring.io_base,
 				     h->qs[i]->tx_ring.buf_size,
 				     h->qs[i]->tx_ring.desc_num,
 				     h->qs[i]->tx_ring.max_desc_num_per_pkt,
@@ -462,8 +462,8 @@ static ssize_t handles_show(struct device *dev,
 				 h->qs[i]->tx_ring.stats.sw_err_cnt,
 				 h->qs[i]->tx_ring.stats.io_err_cnt);
 			s += sprintf(buf + s,
-				"\t\trx_ring on 0x%llx:%u,%u,%llu,%llu,%llu\n",
-				(u64)h->qs[i]->rx_ring.io_base,
+				"\t\trx_ring on 0x%p:%u,%u,%llu,%llu,%llu\n",
+				h->qs[i]->rx_ring.io_base,
 				h->qs[i]->rx_ring.buf_size,
 				h->qs[i]->rx_ring.desc_num,
 				h->qs[i]->rx_ring.stats.sw_err_cnt,
-- 
1.9.1
