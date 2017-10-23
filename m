From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 6/7] net: hns3: remove redundant memset when alloc buffer
Date: Mon, 23 Oct 2017 19:51:06 +0800
Message-ID: <1508759467-18397-7-git-send-email-lipeng321@huawei.com>
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

HW will use packet length to write packets to buffer or read
packets from buffer. There is a redundant memset when alloc buffer,
the memset have no sense and will increase time-consuming.
This patch removes it.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 14de0f7..06af3c8 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1444,8 +1444,6 @@ static int hns3_alloc_buffer(struct hns3_enet_ring *ring,
 	cb->length = hnae_page_size(ring);
 	cb->type = DESC_TYPE_PAGE;
 
-	memset(cb->buf, 0, cb->length);
-
 	return 0;
 }
 
-- 
1.9.1
