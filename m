From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net 4/7] net: hns3: Fixes the initialization of MAC address in hardware
Date: Tue, 19 Sep 2017 17:17:13 +0100
Message-ID: <20170919161716.92680-5-salil.mehta@huawei.com>
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

This patch fixes the initialization of MAC address, fetched from HNS3
firmware i.e. when it is not randomly generated, to the HNS3 hardware.

Fixes: ca60906d2795 ("net: hns3: Add support of HNS3 Ethernet Driver for
hip08 SoC")
Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 1c3e294..4d68d6e 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2705,10 +2705,11 @@ static void hns3_init_mac_addr(struct net_device *netdev)
 		eth_hw_addr_random(netdev);
 		dev_warn(priv->dev, "using random MAC address %pM\n",
 			 netdev->dev_addr);
-		/* Also copy this new MAC address into hdev */
-		if (h->ae_algo->ops->set_mac_addr)
-			h->ae_algo->ops->set_mac_addr(h, netdev->dev_addr);
 	}
+
+	if (h->ae_algo->ops->set_mac_addr)
+		h->ae_algo->ops->set_mac_addr(h, netdev->dev_addr);
+
 }
 
 static void hns3_nic_set_priv_ops(struct net_device *netdev)
-- 
2.7.4
