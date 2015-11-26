From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V5 net-next 5/5] net:hns: Add the init code to disable Hip06  "Hardware VLAN assist"
Date: Thu, 26 Nov 2015 07:14:10 +0000
Message-ID: <1448522050-5576-6-git-send-email-salil.mehta@huawei.com>
References: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38165 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbKZHQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:16:34 -0500
In-Reply-To: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the initializzation code to disable the hardware
vlan support for VLAN Tag stripping by default for now.

Proper support of "hardware VLAN assitance" feature would
soon come in the next coming patches.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
PATCH V5:
- Minor merge/reject change resolved to application of previous patch

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
index b5e4c44..f302ef9 100644
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
@@ -336,6 +341,8 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	hns_ppe_cnt_clr_ce(ppe_cb);
 
 	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		hns_ppe_set_vlan_strip(ppe_cb, 0);
+
 		/* set default RSS key in h/w */
 		hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
 
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
