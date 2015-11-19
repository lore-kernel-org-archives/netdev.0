From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 5/5] net:hns: Add the init code to disable Hip06 "Hardware VLAN assist"
Date: Fri, 20 Nov 2015 04:58:26 +0800
Message-ID: <1447966706-16219-6-git-send-email-salil.mehta@huawei.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the initializzation code to disable the hardware
vlan support for VLAN Tag stripping by default for now.

Proper support of "hardware VLAN assitance" feature would
soon come in the next coming patches.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
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
