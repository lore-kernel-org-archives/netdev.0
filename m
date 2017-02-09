From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net] net: hns: Fix the device being used for dma mapping during TX
Date: Thu, 9 Feb 2017 09:24:09 +0000
Message-ID: <20170209092409.202832-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

This patch fixes the device being used to DMA map skb->data.
Erroneous device assignment causes the crash when SMMU is enabled.
This happens during TX since buffer gets DMA mapped with device
correspondign to net_device and gets unmapped using the device
related to DSAF.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 672b646..2b52a12 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -305,7 +305,7 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 			struct hns_nic_ring_data *ring_data)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
-	struct device *dev = priv->dev;
+	struct device *dev = ring_to_dev(ring_data->ring);
 	struct hnae_ring *ring = ring_data->ring;
 	struct netdev_queue *dev_queue;
 	struct skb_frag_struct *frag;
-- 
1.7.9.5
