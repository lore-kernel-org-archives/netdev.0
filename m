From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v2 net-next 06/13] net: hns: use platform_get_irq instead of irq_of_parse_and_map
Date: Mon, 30 May 2016 10:10:15 +0800
Message-ID: <1464574222-69608-7-git-send-email-yankejian@huawei.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:15968 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbcE3B6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 21:58:33 -0400
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As irq_of_parse_and_map is only used by DT case, it is excepted to use
a uniform interface. So it is used platform_get_irq() instead.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 4ef6d23..3ce2409 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -458,7 +458,6 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 	u32 i;
 	u32 ring_num = rcb_common->ring_num;
 	int base_irq_idx = hns_rcb_get_base_irq_idx(rcb_common);
-	struct device_node *np = rcb_common->dsaf_dev->dev->of_node;
 	struct platform_device *pdev =
 		to_platform_device(rcb_common->dsaf_dev->dev);
 	bool is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
@@ -473,10 +472,10 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 		ring_pair_cb->port_id_in_comm =
 			hns_rcb_get_port_in_comm(rcb_common, i);
 		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] =
-		is_ver1 ? irq_of_parse_and_map(np, base_irq_idx + i * 2) :
+		is_ver1 ? platform_get_irq(pdev, base_irq_idx + i * 2) :
 			  platform_get_irq(pdev, base_irq_idx + i * 3 + 1);
 		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] =
-		is_ver1 ? irq_of_parse_and_map(np, base_irq_idx + i * 2 + 1) :
+		is_ver1 ? platform_get_irq(pdev, base_irq_idx + i * 2 + 1) :
 			  platform_get_irq(pdev, base_irq_idx + i * 3);
 		ring_pair_cb->q.phy_base =
 			RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
-- 
1.9.1
