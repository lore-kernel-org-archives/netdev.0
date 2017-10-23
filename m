From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 2/7] net: hns3: fix the bug when map buffer fail
Date: Mon, 23 Oct 2017 19:51:02 +0800
Message-ID: <1508759467-18397-3-git-send-email-lipeng321@huawei.com>
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

If one buffer had been recieved to stack, driver will alloc a new buffer,
map the buffer to device and replace the old buffer. When map fail, should
only free the new alloced buffer, but not free all buffers in the ring.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 3ddcd47..58aa2dd 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1555,7 +1555,7 @@ static int hns3_reserve_buffer_map(struct hns3_enet_ring *ring,
 	return 0;
 
 out_with_buf:
-	hns3_free_buffers(ring);
+	hns3_free_buffer(ring, cb);
 out:
 	return ret;
 }
-- 
1.9.1
