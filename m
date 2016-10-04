From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] net: hns: Add missing \n to end of dev_err messages, tidy up text
Date: Tue,  4 Oct 2016 13:57:01 +0100
Message-ID: <20161004125701.13032-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Kejian Yan <yankejian@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        lipeng <lipeng321@huawei.com>, Lisheng <lisheng011@huawei.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trival fix, dev_err messages are missing a \n, so add it. Also
fix grammer, spelling mistake and add white spaces to various
error messages.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index a834774..751c126 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -126,7 +126,7 @@ void hns_mac_adjust_link(struct hns_mac_cb *mac_cb, int speed, int duplex)
 			(enum mac_speed)speed, duplex);
 		if (ret) {
 			dev_err(mac_cb->dev,
-				"adjust_link failed,%s mac%d ret = %#x!\n",
+				"adjust_link failed, %s mac%d ret = %#x!\n",
 				mac_cb->dsaf_dev->ae_dev.name,
 				mac_cb->mac_id, ret);
 			return;
@@ -149,7 +149,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 	if (mac_cb->dsaf_dev->dsaf_mode <= DSAF_MODE_ENABLE) {
 		if (mac_cb->mac_id != DSAF_MAX_PORT_NUM) {
 			dev_err(mac_cb->dev,
-				"input invalid,%s mac%d vmid%d !\n",
+				"input invalid, %s mac%d vmid%d !\n",
 				mac_cb->dsaf_dev->ae_dev.name,
 				mac_cb->mac_id, vmid);
 			return -EINVAL;
@@ -157,19 +157,19 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 	} else if (mac_cb->dsaf_dev->dsaf_mode < DSAF_MODE_MAX) {
 		if (mac_cb->mac_id >= DSAF_MAX_PORT_NUM) {
 			dev_err(mac_cb->dev,
-				"input invalid,%s mac%d vmid%d!\n",
+				"input invalid, %s mac%d vmid%d!\n",
 				mac_cb->dsaf_dev->ae_dev.name,
 				mac_cb->mac_id, vmid);
 			return -EINVAL;
 		}
 	} else {
-		dev_err(mac_cb->dev, "dsaf mode invalid,%s mac%d!\n",
+		dev_err(mac_cb->dev, "dsaf mode invalid, %s mac%d!\n",
 			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id);
 		return -EINVAL;
 	}
 
 	if (vmid >= mac_cb->dsaf_dev->rcb_common[0]->max_vfn) {
-		dev_err(mac_cb->dev, "input invalid,%s mac%d vmid%d !\n",
+		dev_err(mac_cb->dev, "input invalid, %s mac%d vmid%d !\n",
 			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id, vmid);
 		return -EINVAL;
 	}
@@ -196,7 +196,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 		tmp_port = vmid;
 		break;
 	default:
-		dev_err(mac_cb->dev, "dsaf mode invalid,%s mac%d!\n",
+		dev_err(mac_cb->dev, "dsaf mode invalid, %s mac%d!\n",
 			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id);
 		return -EINVAL;
 	}
@@ -275,7 +275,7 @@ int hns_mac_set_multi(struct hns_mac_cb *mac_cb,
 			ret = hns_dsaf_add_mac_mc_port(dsaf_dev, &mac_entry);
 		if (ret) {
 			dev_err(dsaf_dev->dev,
-				"set mac mc port failed,%s mac%d ret = %#x!\n",
+				"set mac mc port failed, %s mac%d ret = %#x!\n",
 				mac_cb->dsaf_dev->ae_dev.name,
 				mac_cb->mac_id, ret);
 			return ret;
@@ -305,7 +305,7 @@ int hns_mac_del_mac(struct hns_mac_cb *mac_cb, u32 vfn, char *mac)
 		old_mac = &mac_cb->addr_entry_idx[vfn];
 	} else {
 		dev_err(mac_cb->dev,
-			"vf queue is too large,%s mac%d queue = %#x!\n",
+			"vf queue is too large, %s mac%d queue = %#x!\n",
 			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id, vfn);
 		return -EINVAL;
 	}
@@ -547,7 +547,7 @@ int hns_mac_set_autoneg(struct hns_mac_cb *mac_cb, u8 enable)
 	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
 
 	if (mac_cb->phy_if == PHY_INTERFACE_MODE_XGMII && enable) {
-		dev_err(mac_cb->dev, "enable autoneg is not allowed!");
+		dev_err(mac_cb->dev, "enabling autoneg is not allowed!\n");
 		return -ENOTSUPP;
 	}
 
@@ -571,7 +571,7 @@ int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en)
 
 	if (mac_cb->mac_type == HNAE_PORT_DEBUG) {
 		if (is_ver1 && (tx_en || rx_en)) {
-			dev_err(mac_cb->dev, "macv1 cann't enable tx/rx_pause!");
+			dev_err(mac_cb->dev, "macv1 can't enable tx/rx_pause!\n");
 			return -EINVAL;
 		}
 	}
@@ -941,7 +941,7 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 	ret = hns_mac_get_mode(mac_cb->phy_if);
 	if (ret < 0) {
 		dev_err(dsaf_dev->dev,
-			"hns_mac_get_mode failed,mac%d ret = %#x!\n",
+			"hns_mac_get_mode failed, mac%d ret = %#x!\n",
 			mac_cb->mac_id, ret);
 		return ret;
 	}
-- 
2.9.3
