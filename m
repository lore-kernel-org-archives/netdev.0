From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 2/4] net: hns: change port-id property to reg property in dsaf port node
Date: Thu, 28 Apr 2016 15:09:02 +0800
Message-ID: <1461827344-52230-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <will.deacon@arm.com>,
	<catalin.marinas@arm.com>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <xuwei5@hisilicon.com>,
	<linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:5399 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbcD1Gwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:52:30 -0400
In-Reply-To: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indexes should generally be avoided. So we use reg rather than port-id to
index ports.

Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 210ba89..611581f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -834,15 +834,15 @@ int hns_mac_init(struct dsaf_device *dsaf_dev)
 	struct fwnode_handle *child;
 
 	device_for_each_child_node(dsaf_dev->dev, child) {
-		ret = fwnode_property_read_u32(child, "port-id", &port_id);
+		ret = fwnode_property_read_u32(child, "reg", &port_id);
 		if (ret) {
 			dev_err(dsaf_dev->dev,
-				"get port-id fail, ret=%d!\n", ret);
+				"get reg fail, ret=%d!\n", ret);
 			return ret;
 		}
 		if (port_id >= max_port_num) {
 			dev_err(dsaf_dev->dev,
-				"port-id(%u) out of range!\n", port_id);
+				"reg(%u) out of range!\n", port_id);
 			return -EINVAL;
 		}
 		mac_cb = devm_kzalloc(dsaf_dev->dev, sizeof(*mac_cb),
-- 
1.9.1
