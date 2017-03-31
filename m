From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 04/18] net: hns: Remove redundant memset during buffer release
Date: Fri, 31 Mar 2017 12:20:18 +0100
Message-ID: <20170331112032.4692-5-salil.mehta@huawei.com>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        Weiwei Deng <dengweiwei@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331112032.4692-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

Because all members of desc_cb is assigned when xmit one package, so it
can delete in hnae_free_buffer, as follows:
        - "dma, priv, length, type" are assigned in fill_v2_desc.
        - "page_offset, reuse_flag, buf" are not used in tx direction.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Weiwei Deng <dengweiwei@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index b6ed818..78af663 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -61,7 +61,6 @@ static void hnae_free_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
 		dev_kfree_skb_any((struct sk_buff *)cb->priv);
 	else if (unlikely(is_rx_ring(ring)))
 		put_page((struct page *)cb->priv);
-	memset(cb, 0, sizeof(*cb));
 }
 
 static int hnae_map_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
-- 
2.7.4
