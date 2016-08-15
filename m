From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: hns: mdio->irq is an array, so no need to check if it is null
Date: Mon, 15 Aug 2016 13:55:17 +0100
Message-ID: <1471265717-10784-1-git-send-email-colin.king@canonical.com>
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

The null check on mdio->irq is redundant since mdio->irq is an array
of PHY_MAX_ADDR ints and hence can never be null. Remove the redundant
check.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 5c8afe1..a834774 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -684,8 +684,7 @@ hns_mac_register_phydev(struct mii_bus *mdio, struct hns_mac_cb *mac_cb,
 	if (!phy || IS_ERR(phy))
 		return -EIO;
 
-	if (mdio->irq)
-		phy->irq = mdio->irq[addr];
+	phy->irq = mdio->irq[addr];
 
 	/* All data is now stored in the phy struct;
 	 * register it
-- 
2.8.1
