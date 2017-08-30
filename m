From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next] net: hns3: Fixes the wrong IS_ERR check on the returned phydev value
Date: Wed, 30 Aug 2017 12:06:03 +0100
Message-ID: <20170830110603.12372-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the wrong check being done for the phy device being
returned by the mdiobus_get_phy() function. This function never returns
the error pointers.

Fixes: 256727da7395 ("net: hns3: Add MDIO support to HNS3 Ethernet
Driver for hip08 SoC")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
index a2add8b..f32d719 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
@@ -150,7 +150,7 @@ int hclge_mac_mdio_config(struct hclge_dev *hdev)
 	}
 
 	phydev = mdiobus_get_phy(mdio_bus, mac->phy_addr);
-	if (!phydev || IS_ERR(phydev)) {
+	if (!phydev) {
 		dev_err(mdio_bus->parent, "Failed to get phy device\n");
 		mdiobus_unregister(mdio_bus);
 		return -EIO;
-- 
2.7.4
