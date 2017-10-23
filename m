From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 5/7] net: hns3: fix the TX/RX ring.queue_index in hns3_ring_get_cfg
Date: Mon, 23 Oct 2017 19:51:05 +0800
Message-ID: <1508759467-18397-6-git-send-email-lipeng321@huawei.com>
References: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The interface hns3_ring_get_cfg only update TX ring queue_index,
but do not update RX ring queue_index. This patch fixes it.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 58aa2dd..14de0f7 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2506,16 +2506,16 @@ static int hns3_ring_get_cfg(struct hnae3_queue *q, struct hns3_nic_priv *priv,
 
 	if (ring_type == HNAE3_RING_TYPE_TX) {
 		ring_data[q->tqp_index].ring = ring;
+		ring_data[q->tqp_index].queue_index = q->tqp_index;
 		ring->io_base = (u8 __iomem *)q->io_base + HNS3_TX_REG_OFFSET;
 	} else {
 		ring_data[q->tqp_index + queue_num].ring = ring;
+		ring_data[q->tqp_index + queue_num].queue_index = q->tqp_index;
 		ring->io_base = q->io_base;
 	}
 
 	hnae_set_bit(ring->flag, HNAE3_RING_TYPE_B, ring_type);
 
-	ring_data[q->tqp_index].queue_index = q->tqp_index;
-
 	ring->tqp = q;
 	ring->desc = NULL;
 	ring->desc_cb = NULL;
-- 
1.9.1
