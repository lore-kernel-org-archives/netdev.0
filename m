From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 3/4] net: hns: bug fix for return values
Date: Tue, 8 Mar 2016 11:52:26 +0800
Message-ID: <1457409147-77086-4-git-send-email-lisheng011@huawei.com>
References: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<xieqianqian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>, <haifeng.wei@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:43127 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcCHDmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:42:40 -0500
In-Reply-To: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The return values in the first two functions mdiobus_write()
are ignored. The patch will fix it.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3df2284..cc5c545 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1000,8 +1000,8 @@ int hns_phy_led_set(struct net_device *netdev, int value)
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
