From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 3/7] net: hns: bug fix for return values
Date: Thu, 24 Mar 2016 19:08:02 +0800
Message-ID: <1458817686-159708-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41787 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757125AbcCXKtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 06:49:31 -0400
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The return values in the first two functions mdiobus_write()
are ignored. The patch will fix it.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 9c3ba65..0e7da3f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1013,8 +1013,8 @@ int hns_phy_led_set(struct net_device *netdev, int value)
 	struct phy_device *phy_dev = priv->phy;
 
 	retval = phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_LED);
-	retval = phy_write(phy_dev, HNS_LED_FC_REG, value);
-	retval = phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
+	retval |= phy_write(phy_dev, HNS_LED_FC_REG, value);
+	retval |= phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
 	if (retval) {
 		netdev_err(netdev, "mdiobus_write fail !\n");
 		return retval;
-- 
1.9.1
