From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net 1/7] net: hns3: Fixes initialization of phy address from firmware
Date: Tue, 19 Sep 2017 17:17:10 +0100
Message-ID: <20170919161716.92680-2-salil.mehta@huawei.com>
References: <20170919161716.92680-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919161716.92680-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>

Default phy address of every port is 0. Therefore, phy address for
each port need to be fetched from firmware and device initialized
with fetched non-default phy address.

Fixes: 6427264ef330 ("net: hns3: Add HNS3 Acceleration Engine &
Compatibility Layer Support")
Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index bb45365..db4e07d 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1066,6 +1066,7 @@ static int hclge_configure(struct hclge_dev *hdev)
 	for (i = 0; i < ETH_ALEN; i++)
 		hdev->hw.mac.mac_addr[i] = cfg.mac_addr[i];
 	hdev->hw.mac.media_type = cfg.media_type;
+	hdev->hw.mac.phy_addr = cfg.phy_addr;
 	hdev->num_desc = cfg.tqp_desc_num;
 	hdev->tm_info.num_pg = 1;
 	hdev->tm_info.num_tc = cfg.tc_num;
-- 
2.7.4
