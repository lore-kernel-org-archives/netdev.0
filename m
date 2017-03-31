From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 14/18] net: hns: Optimise the code in hns_mdio_wait_ready()
Date: Fri, 31 Mar 2017 12:20:28 +0100
Message-ID: <20170331112032.4692-15-salil.mehta@huawei.com>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4872 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S933283AbdCaLWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:22:20 -0400
In-Reply-To: <20170331112032.4692-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

This patch fixes the code to clear pclint warning/info.

Reported-by: Ping Zhang <zhangping5@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index fad1c5b..e5221d9 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -175,18 +175,20 @@ static int mdio_sc_cfg_reg_write(struct hns_mdio_device *mdio_dev,
 static int hns_mdio_wait_ready(struct mii_bus *bus)
 {
 	struct hns_mdio_device *mdio_dev = bus->priv;
+	u32 cmd_reg_value;
 	int i;
-	u32 cmd_reg_value = 1;
 
 	/* waitting for MDIO_COMMAND_REG 's mdio_start==0 */
 	/* after that can do read or write*/
-	for (i = 0; cmd_reg_value; i++) {
+	for (i = 0; i < MDIO_TIMEOUT; i++) {
 		cmd_reg_value = MDIO_GET_REG_BIT(mdio_dev,
 						 MDIO_COMMAND_REG,
 						 MDIO_CMD_START_B);
-		if (i == MDIO_TIMEOUT)
-			return -ETIMEDOUT;
+		if (!cmd_reg_value)
+			break;
 	}
+	if ((i == MDIO_TIMEOUT) && cmd_reg_value)
+		return -ETIMEDOUT;
 
 	return 0;
 }
-- 
2.7.4
