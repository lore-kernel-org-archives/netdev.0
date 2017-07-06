From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH net V2 1/2] net: hns: Fix a wrong op phy C45 code
Date: Thu, 6 Jul 2017 10:21:59 +0800
Message-ID: <1499307720-218834-2-git-send-email-linyunsheng@huawei.com>
References: <1499307720-218834-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:9279 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdGFBvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 21:51:18 -0400
In-Reply-To: <1499307720-218834-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yunsheng Lin <linyunsheng@huawei.com>

As the user manual described, the second step to write to C45 phy
by mdio should be data, but not address. Here we should fix this
issue.

Fixes: 5b904d39406a ("net: add Hisilicon Network Subsystem MDIO support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
Reviewed-by: lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index e5221d9..017e084 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -261,7 +261,7 @@ static int hns_mdio_write(struct mii_bus *bus,
 
 		/* config the data needed writing */
 		cmd_reg_cfg = devad;
-		op = MDIO_C45_WRITE_ADDR;
+		op = MDIO_C45_WRITE_DATA;
 	}
 
 	MDIO_SET_REG_FIELD(mdio_dev, MDIO_WDATA_REG, MDIO_WDATA_DATA_M,
-- 
1.9.1
