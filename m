From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 5/6] net: hns: fixed service-ges setting MAC-addr bug
Date: Fri, 4 Mar 2016 11:05:41 +0800
Message-ID: <1457060742-165202-6-git-send-email-huangdaode@hisilicon.com>
References: <1457060742-165202-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457060742-165202-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lisheng <lisheng011@huawei.com>

Service gmacs can not set mac add, this patch will fix the bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 2591a51..eb86178 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -414,18 +414,17 @@ static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
 
-	if (drv->mac_id >= DSAF_SERVICE_NW_NUM) {
-		u32 high_val = mac_addr[1] | (mac_addr[0] << 8);
+	u32 high_val = mac_addr[1] | (mac_addr[0] << 8);
 
-		u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
-			| (mac_addr[3] << 16) | (mac_addr[2] << 24);
+	u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
+		| (mac_addr[3] << 16) | (mac_addr[2] << 24);
 
-		u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
-		u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
-			       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
-	}
+	u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
+	u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);
+
+	dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
+	dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+		       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
 }
 
 static int hns_gmac_config_loopback(void *mac_drv, enum hnae_loop loop_mode,
-- 
1.9.1
