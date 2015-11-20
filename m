From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V4 net-next 5/5] net:hns: Add the init code to disable Hip06 "Hardware VLAN assist"
Date: Sat, 21 Nov 2015 03:49:12 +0800
Message-ID: <1448048952-146714-6-git-send-email-salil.mehta@huawei.com>
References: <1448048952-146714-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
	<liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448048952-146714-1-git-send-email-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the initializzation code to disable the hardware
vlan support for VLAN Tag stripping by default for now.

Proper support of "hardware VLAN assitance" feature would
soon come in the next coming patches.

Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---

PATCH V4:
- No change over the earlier patches

PATCH V2/V3:
- No change over the initial floated patch

PATCH V1:
- Initial code to disable the hardware VLAN assist for now
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |    7 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    1 +
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index b6bf292..544f323 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -176,6 +176,11 @@ static void hns_ppe_cnt_clr_ce(struct hns_ppe_cb *ppe_cb)
 			 PPE_CNT_CLR_CE_B, 1);
 }
 
+static void hns_ppe_set_vlan_strip(struct hns_ppe_cb *ppe_cb, int en)
+{
+	dsaf_write_dev(ppe_cb, PPEV2_VLAN_STRIP_EN_REG, en);
+}
+
 /**
  * hns_ppe_checksum_hw - set ppe checksum caculate
  * @ppe_device: ppe device
@@ -345,6 +350,8 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	hns_ppe_cnt_clr_ce(ppe_cb);
 
 	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		hns_ppe_set_vlan_strip(ppe_cb, 0);
+
 		hns_ppe_set_rss_key(ppe_cb, rss_key);
 
 		for (i = 0; i < HNS_PPEV2_RSS_IND_TBL_SIZE; i++)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 98c163e..6c18ca9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -318,6 +318,7 @@
 #define PPE_CFG_PARSE_TAG_REG			0x94
 #define PPE_CFG_PRO_CHECK_EN_REG		0x98
 #define PPEV2_CFG_TSO_EN_REG                    0xA0
+#define PPEV2_VLAN_STRIP_EN_REG                 0xAC
 #define PPE_INTEN_REG				0x100
 #define PPE_RINT_REG				0x104
 #define PPE_INTSTS_REG				0x108
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
