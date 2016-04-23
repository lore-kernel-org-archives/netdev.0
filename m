From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 05/13] net: hns: add syscon operation for dsaf
Date: Sat, 23 Apr 2016 17:05:09 +0800
Message-ID: <1461402317-136499-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch provides the read/write function for dsaf to
access the registers through syscon methods.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
