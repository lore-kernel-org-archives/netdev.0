From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 05/10] net: hns: add syscon operation for dsaf
Date: Thu, 28 Apr 2016 15:01:37 +0800
Message-ID: <1461826902-51368-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:51058 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbcD1Gvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:51:55 -0400
In-Reply-To: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

This patch provides the read/write function for dsaf to
access the registers through syscon methods.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yuzeng Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index ed0043a..6a03c94 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -10,6 +10,7 @@
 #ifndef _DSAF_REG_H_
 #define _DSAF_REG_H_
 
+#include <linux/regmap.h>
 #define HNS_DEBUG_RING_IRQ_IDX 0
 #define HNS_SERVICE_RING_IRQ_IDX 59
 #define HNSV2_SERVICE_RING_IRQ_IDX 25
@@ -989,6 +990,19 @@ static inline u32 dsaf_read_reg(u8 __iomem *base, u32 reg)
 	return readl(reg_addr + reg);
 }
 
+static inline void dsaf_write_syscon(struct regmap *base, u32 reg, u32 value)
+{
+	regmap_write(base, reg, value);
+}
+
+static inline u32 dsaf_read_syscon(struct regmap *base, u32 reg)
+{
+	unsigned int val;
+
+	regmap_read(base, reg, &val);
+	return val;
+}
+
 #define dsaf_read_dev(a, reg) \
 	dsaf_read_reg((a)->io_base, (reg))
 
-- 
1.9.1
