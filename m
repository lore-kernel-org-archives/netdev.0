From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next] net: hns: add skb_reset_mac_header() after skb being alloc
Date: Mon, 13 Jun 2016 20:41:22 +0800
Message-ID: <1465821682-223053-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <charles.chenxin@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

HNS receives a packet without doing anything, but it should call
skb_reset_mac_header() to initialize the header before using
eth_hdr().

Fixes: 0d6b425a3773c3445b0f51b2f333821beaacb619
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index ad742a6..15200e4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -600,6 +600,7 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 		ring->stats.sw_err_cnt++;
 		return -ENOMEM;
 	}
+	skb_reset_mac_header(skb);
 
 	prefetchw(skb->data);
 	length = le16_to_cpu(desc->rx.pkt_len);
-- 
1.9.1
