From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 4/4] net: hns: remove useless head=ring->next_to_clean
Date: Tue, 8 Mar 2016 11:52:27 +0800
Message-ID: <1457409147-77086-5-git-send-email-lisheng011@huawei.com>
References: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:43100 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbcCHDme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:42:34 -0500
In-Reply-To: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The variable head in hns_nic_tx_fini_pro has read a value,
but the value is not used. The patch will solve it.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3f77ff7..7b4ec2f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -901,10 +901,8 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
-	int head = ring->next_to_clean;
 
-	/* for hardware bug fixed */
-	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 
 	if (head != ring->next_to_clean) {
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-- 
1.9.1
