From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 05/17] net: hns: bug fix about restart auto-negotiation
Date: Wed, 9 Nov 2016 18:13:49 +0000
Message-ID: <20161109181401.913728-6-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

When set auto-negotiation off and duplex half, if run "ethtool -r ethX"
on port with phy, then the port will be failed to work. It should
forbid to start auto-negotiation when auto-negotiate is off. This
patch add the limited condition.

Reported-by: Jinchuang Tian <tianjinchuang1@huawei.com>
Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Reviewed-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 87d5c94..3ac2183 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1178,7 +1178,8 @@ static int hns_nic_nway_reset(struct net_device *netdev)
 	struct phy_device *phy = netdev->phydev;
 
 	if (netif_running(netdev)) {
-		if (phy)
+		/* if autoneg is disabled, don't restart auto-negotiation */
+		if (phy && phy->autoneg == AUTONEG_ENABLE)
 			ret = genphy_restart_aneg(phy);
 	}
 
-- 
1.7.9.5
