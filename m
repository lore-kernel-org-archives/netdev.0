From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 04/10] net: hns: fixed the bug about GMACs mac setting
Date: Mon, 21 Mar 2016 19:06:35 +0800
Message-ID: <1458558401-190165-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<xieqianqian@huawei.com>, <andrew@lunn.ch>, <ivecera@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sheng Li <lisheng011@huawei.com>

When sending a pause frame out from GMACs, the packets' source MAC address
does not match the GMACs' MAC address. It causes by the condition before
the mac address setting routine for GMACs, the mac address cannot be set
into loacal mac table for service ports. It obviously the condition needs
to be deleted.

Signed-off-by: Sheng Li <lisheng011@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 5881405..a99ee00 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -424,19 +424,17 @@ static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
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
+	u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
+	u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);
 
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
-			       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
-	}
+	dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
+	dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+		       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
 }
 
 static int hns_gmac_config_loopback(void *mac_drv, enum hnae_loop loop_mode,
-- 
1.9.1
