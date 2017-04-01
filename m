From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V4 net-next 05/18] net: hns: bug fix of ethtool show the speed
Date: Sat, 1 Apr 2017 12:03:35 +0100
Message-ID: <20170401110348.15908-6-salil.mehta@huawei.com>
References: <20170401110348.15908-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170401110348.15908-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

When run ethtool ethX on hns driver, the speed will show
as "Unknown". The base.speed is not correct assigned,
this patch fix this bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3ac2183..3404eac 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -146,7 +146,7 @@ static int hns_nic_get_link_ksettings(struct net_device *net_dev,
 
 	/* When there is no phy, autoneg is off. */
 	cmd->base.autoneg = false;
-	cmd->base.cmd = speed;
+	cmd->base.speed = speed;
 	cmd->base.duplex = duplex;
 
 	if (net_dev->phydev)
-- 
2.7.4
