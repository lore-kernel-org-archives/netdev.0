From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next] net: hns: Fix for __udivdi3 compiler error
Date: Fri, 4 Aug 2017 17:24:59 +0800
Message-ID: <1501838699-95356-1-git-send-email-linyunsheng@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the __udivdi3 undefined error reported by
test robot.

Fixes: b8c17f708831 ("net: hns: Add self-adaptive interrupt coalesce support in hns driver")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 832f277..3652063 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -847,7 +847,8 @@ static void hns_update_rx_rate(struct hnae_ring *ring)
 
 	total_bytes = ring->stats.rx_bytes - ring->coal_last_rx_bytes;
 	time_passed_ms = jiffies_to_msecs(jiffies - ring->coal_last_jiffies);
-	ring->coal_rx_rate = (total_bytes / time_passed_ms) >> 10;
+	do_div(total_bytes, time_passed_ms);
+	ring->coal_rx_rate = total_bytes >> 10;
 
 	ring->coal_last_rx_bytes = ring->stats.rx_bytes;
 	ring->coal_last_jiffies = jiffies;
-- 
1.9.1
