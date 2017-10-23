From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 1/7] net: hns3: fix a bug when alloc new buffer
Date: Mon, 23 Oct 2017 19:51:01 +0800
Message-ID: <1508759467-18397-2-git-send-email-lipeng321@huawei.com>
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

When alloce new buffer to HW, should unmap the old buffer first.
This old code map the old buffer but not unmap the old buffer,
this patch fixes it.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 8383d67..3ddcd47 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1595,7 +1595,7 @@ static int hns3_alloc_ring_buffers(struct hns3_enet_ring *ring)
 static void hns3_replace_buffer(struct hns3_enet_ring *ring, int i,
 				struct hns3_desc_cb *res_cb)
 {
-	hns3_map_buffer(ring, &ring->desc_cb[i]);
+	hns3_unmap_buffer(ring, &ring->desc_cb[i]);
 	ring->desc_cb[i] = *res_cb;
 	ring->desc[i].addr = cpu_to_le64(ring->desc_cb[i].dma);
 }
-- 
1.9.1
