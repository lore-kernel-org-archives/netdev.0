From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net 5/7] net: hns3: Fixes the ether address copy with appropriate API
Date: Tue, 19 Sep 2017 17:17:14 +0100
Message-ID: <20170919161716.92680-6-salil.mehta@huawei.com>
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

This patch replaces the ethernet address copy instance with more
appropriate ether_addr_copy() function.

Fixes: 6427264ef330 ("net: hns3: Add HNS3 Acceleration Engine &
Compatibility Layer Support")
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index eafd9c6..8e172af 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1063,8 +1063,7 @@ static int hclge_configure(struct hclge_dev *hdev)
 	hdev->base_tqp_pid = 0;
 	hdev->rss_size_max = 1;
 	hdev->rx_buf_len = cfg.rx_buf_len;
-	for (i = 0; i < ETH_ALEN; i++)
-		hdev->hw.mac.mac_addr[i] = cfg.mac_addr[i];
+	ether_addr_copy(hdev->hw.mac.mac_addr, cfg.mac_addr);
 	hdev->hw.mac.media_type = cfg.media_type;
 	hdev->hw.mac.phy_addr = cfg.phy_addr;
 	hdev->num_desc = cfg.tqp_desc_num;
-- 
2.7.4
