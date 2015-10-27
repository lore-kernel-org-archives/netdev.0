From: yankejian <yankejian@huawei.com>
Subject: [PATCH] net: hns: fixes the bug tested XGE by ethtool -p
Date: Tue, 27 Oct 2015 17:17:40 +0800
Message-ID: <1445937460-231548-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <linuxarm@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<lisheng011@huawei.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
	<liguozhu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Peng <lipeng321@huawei.com>

delete action of ETHTOOL_ID_ON/ETHTOOL_ID_OFF in XGE ethtool -p,
so Hardware control the LED state instead of software.

Signed-off-by: Li Peng <lipeng321@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index d611388..523e9b8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -64,17 +64,10 @@ int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 	switch (status) {
 	case HNAE_LED_ACTIVE:
 		mac_cb->cpld_led_value = dsaf_read_b(mac_cb->cpld_vaddr);
-		return 2;
-	case HNAE_LED_ON:
 		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
 			     CPLD_LED_ON_VALUE);
 		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
-		break;
-	case HNAE_LED_OFF:
-		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
-			     CPLD_LED_DEFAULT_VALUE);
-		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
-		break;
+		return 2;
 	case HNAE_LED_INACTIVE:
 		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
 			     CPLD_LED_DEFAULT_VALUE);
-- 
1.9.1
