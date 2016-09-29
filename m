From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 8/8] net: hns: delete redundant broadcast packet filter process
Date: Thu, 29 Sep 2016 18:09:16 +0100
Message-ID: <20160929170916.631972-9-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Daode Huang <huangdaode@hisilicon.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:53872 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934568AbcI2RLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:45 -0400
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

The broadcast packets is filtered in the hardware now, so this process
is no need in the driver, just delete it.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 5494e0e..a7abe11 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -574,7 +574,6 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 	struct sk_buff *skb;
 	struct hnae_desc *desc;
 	struct hnae_desc_cb *desc_cb;
-	struct ethhdr *eh;
 	unsigned char *va;
 	int bnum, length, i;
 	int pull_len;
@@ -600,7 +599,6 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 		ring->stats.sw_err_cnt++;
 		return -ENOMEM;
 	}
-	skb_reset_mac_header(skb);
 
 	prefetchw(skb->data);
 	length = le16_to_cpu(desc->rx.pkt_len);
@@ -682,14 +680,6 @@ out_bnum_err:
 		return -EFAULT;
 	}
 
-	/* filter out multicast pkt with the same src mac as this port */
-	eh = eth_hdr(skb);
-	if (unlikely(is_multicast_ether_addr(eh->h_dest) &&
-		     ether_addr_equal(ndev->dev_addr, eh->h_source))) {
-		dev_kfree_skb_any(skb);
-		return -EFAULT;
-	}
-
 	ring->stats.rx_pkts++;
 	ring->stats.rx_bytes += skb->len;
 
-- 
1.7.9.5
