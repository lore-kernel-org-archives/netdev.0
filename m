From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH V2 net 4/4] net: hns: remove useless head=ring->next_to_clean
Date: Fri, 11 Mar 2016 18:20:22 +0800
Message-ID: <1457691622-124657-5-git-send-email-lisheng011@huawei.com>
References: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63255 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbcCKKK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 05:10:28 -0500
In-Reply-To: <1457691622-124657-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The variable head in hns_nic_tx_fini_pro has read a value,
but the value is not used. The patch will solve it.
The bug-fixed comment is for the function pointer
ring_data->fini_process,that is called in function
hns_nic_common_poll.The comment should not be there, so remove it.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
change log:
PATCH v2:
 - This patchset fixes the comments provided by Andy Shevchenko <Andy Shevchenko>

PATCH v1:
 - first submit
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3f77ff7..5456531 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -901,10 +901,7 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
-	int head = ring->next_to_clean;
-
-	/* for hardware bug fixed */
-	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 
 	if (head != ring->next_to_clean) {
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-- 
1.9.1
