From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 4/7] net: hns3: fix a bug of set mac address
Date: Tue, 19 Sep 2017 02:06:25 +0100
Message-ID: <20170919010628.175732-5-salil.mehta@huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <mehta.salil.lnk@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919010628.175732-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lipeng <lipeng321@huawei.com>

HNS3 driver get mac address from NCL_config file and set the mac address
to HW. If the mac address in NCL_config is invalid, driver will set a
random mac address, and use this address.

The current code will set random mac address to HW, but will not set the
valid mac address from NCL_config file to HW. This patch fix the bug.

Signed-off-by: Lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 1c3e29447891..4d68d6ea5143 100644
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
2.11.0
