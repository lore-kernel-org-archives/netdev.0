From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 02/19] net: hns: Modify GMAC init TX threshold value
Date: Thu, 30 Mar 2017 16:30:49 +0100
Message-ID: <20170330153106.14344-3-salil.mehta@huawei.com>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        JinchuanTian <tianjinchuan1@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

This patch reduces GMAC TX threshold value to avoid gmac
hang-up with speed 100M/duplex half.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: JinchuanTian <tianjinchuan1@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 6 ++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 3382441..a8dbe00 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -325,6 +325,12 @@ static void hns_gmac_init(void *mac_drv)
 	hns_gmac_tx_loop_pkt_dis(mac_drv);
 	if (drv->mac_cb->mac_type == HNAE_PORT_DEBUG)
 		hns_gmac_set_uc_match(mac_drv, 0);
+
+	/* reduce gmac tx water line to avoid gmac hang-up
+	 * in speed 100M and duplex half.
+	 */
+	dsaf_set_dev_field(drv, GMAC_TX_WATER_LINE_REG, GMAC_TX_WATER_LINE_MASK,
+			   GMAC_TX_WATER_LINE_SHIFT, 8);
 }
 
 void hns_gmac_update_stats(void *mac_drv)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 8fa18fc..4b8af68 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -466,6 +466,7 @@
 
 #define GMAC_DUPLEX_TYPE_REG			0x0008UL
 #define GMAC_FD_FC_TYPE_REG			0x000CUL
+#define GMAC_TX_WATER_LINE_REG			0x0010UL
 #define GMAC_FC_TX_TIMER_REG			0x001CUL
 #define GMAC_FD_FC_ADDR_LOW_REG			0x0020UL
 #define GMAC_FD_FC_ADDR_HIGH_REG		0x0024UL
@@ -912,6 +913,9 @@
 
 #define GMAC_DUPLEX_TYPE_B 0
 
+#define GMAC_TX_WATER_LINE_MASK		((1UL << 8) - 1)
+#define GMAC_TX_WATER_LINE_SHIFT	0
+
 #define GMAC_FC_TX_TIMER_S 0
 #define GMAC_FC_TX_TIMER_M 0xffff
 
-- 
2.7.4
