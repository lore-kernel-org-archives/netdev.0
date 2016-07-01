From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 7/9] net: hns: remove redundant hns_mac_dev_to_enet_if()
Date: Fri, 1 Jul 2016 17:34:11 +0800
Message-ID: <1467365653-83331-8-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11004 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbcGAJQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:16:16 -0400
In-Reply-To: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

The sequence of hns_mac_dev_to_enet_if() is the same as
hns_get_enet_interface(), and hns_get_enet_interface() is called
by initialization to get the mac mode. And the mode is not changed
anywhere. Thus add hns_mac_dev_to_enet_if() function to get the mac
mode is obviously redundant.

Reported-by: Jinchuan Tian <tianjinchuan1@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index c526558..d2effcc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -56,20 +56,6 @@ static const enum mac_mode g_mac_mode_1000[] = {
 	[PHY_INTERFACE_MODE_RTBI]   = MAC_MODE_RTBI_1000
 };
 
-static enum mac_mode hns_mac_dev_to_enet_if(const struct hns_mac_cb *mac_cb)
-{
-	switch (mac_cb->max_speed) {
-	case MAC_SPEED_100:
-		return g_mac_mode_100[mac_cb->phy_if];
-	case MAC_SPEED_1000:
-		return g_mac_mode_1000[mac_cb->phy_if];
-	case MAC_SPEED_10000:
-		return MAC_MODE_XGMII_10000;
-	default:
-		return MAC_MODE_MII_100;
-	}
-}
-
 static enum mac_mode hns_get_enet_interface(const struct hns_mac_cb *mac_cb)
 {
 	switch (mac_cb->max_speed) {
@@ -134,7 +120,6 @@ void hns_mac_adjust_link(struct hns_mac_cb *mac_cb, int speed, int duplex)
 
 	mac_cb->speed = speed;
 	mac_cb->half_duplex = !duplex;
-	mac_ctrl_drv->mac_mode = hns_mac_dev_to_enet_if(mac_cb);
 
 	if (mac_ctrl_drv->adjust_link) {
 		ret = mac_ctrl_drv->adjust_link(mac_ctrl_drv,
-- 
1.9.1
