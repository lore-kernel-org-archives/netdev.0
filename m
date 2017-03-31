From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 11/18] net: hns: Remove redundant mac_get_id()
Date: Fri, 31 Mar 2017 18:48:45 +0100
Message-ID: <20170331174852.13600-12-salil.mehta@huawei.com>
References: <20170331174852.13600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331174852.13600-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

There is a mac_id in mac control block structure, so the callback
function mac_get_id() is useless. Here we remove this function.

Reported-by: Weiwei Deng <dengweiwei@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c  |  8 --------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h   |  2 --
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 13 -------------
 3 files changed, 23 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 723f3ae..035db86 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -466,13 +466,6 @@ static int hns_gmac_config_loopback(void *mac_drv, enum hnae_loop loop_mode,
 	return 0;
 }
 
-static void hns_gmac_get_id(void *mac_drv, u8 *mac_id)
-{
-	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-
-	*mac_id = drv->mac_id;
-}
-
 static void hns_gmac_get_info(void *mac_drv, struct mac_info *mac_info)
 {
 	enum hns_gmac_duplex_mdoe duplex;
@@ -714,7 +707,6 @@ void *hns_gmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
 	mac_drv->config_pad_and_crc = hns_gmac_config_pad_and_crc;
 	mac_drv->config_half_duplex = hns_gmac_set_duplex_type;
 	mac_drv->set_rx_ignore_pause_frames = hns_gmac_set_rx_auto_pause_frames;
-	mac_drv->mac_get_id = hns_gmac_get_id;
 	mac_drv->get_info = hns_gmac_get_info;
 	mac_drv->autoneg_stat = hns_gmac_autoneg_stat;
 	mac_drv->get_pause_enable = hns_gmac_get_pausefrm_cfg;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index e6842c9..24dfba5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -373,8 +373,6 @@ struct mac_driver {
 	void (*set_rx_ignore_pause_frames)(void *mac_drv, u32 enable);
 	/* config rx mode for promiscuous*/
 	void (*set_promiscuous)(void *mac_drv, u8 enable);
-	/* get mac id */
-	void (*mac_get_id)(void *mac_drv, u8 *mac_id);
 	void (*mac_pausefrm_cfg)(void *mac_drv, u32 rx_en, u32 tx_en);
 
 	void (*autoneg_stat)(void *mac_drv, u32 *enable);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index aae830a..37a2fc3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -300,18 +300,6 @@ static void hns_xgmac_set_tx_auto_pause_frames(void *mac_drv, u16 enable)
 }
 
 /**
- *hns_xgmac_get_id - get xgmac port id
- *@mac_drv: mac driver
- *@newval:xgmac max frame length
- */
-static void hns_xgmac_get_id(void *mac_drv, u8 *mac_id)
-{
-	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-
-	*mac_id = drv->mac_id;
-}
-
-/**
  *hns_xgmac_config_max_frame_length - set xgmac max frame length
  *@mac_drv: mac driver
  *@newval:xgmac max frame length
@@ -833,7 +821,6 @@ void *hns_xgmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
 	mac_drv->config_half_duplex = NULL;
 	mac_drv->set_rx_ignore_pause_frames =
 		hns_xgmac_set_rx_ignore_pause_frames;
-	mac_drv->mac_get_id = hns_xgmac_get_id;
 	mac_drv->mac_free = hns_xgmac_free;
 	mac_drv->adjust_link = NULL;
 	mac_drv->set_tx_auto_pause_frames = hns_xgmac_set_tx_auto_pause_frames;
-- 
2.7.4
