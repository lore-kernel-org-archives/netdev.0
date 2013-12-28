From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 15/20] net: seeq: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:18:04 +0800
Message-ID: <52BE6D1C.5090101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/seeq/sgiseeq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index c765718..ced5b13 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -356,7 +356,7 @@ static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp
 		if (pkt_status & SEEQ_RSTAT_FIG) {
 			/* Packet is OK. */
 			/* We don't want to receive our own packets */
-			if (memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN)) {
+			if (!ether_addr_equal(rd->skb->data + 6, dev->dev_addr)) {
 				if (len > rx_copybreak) {
 					skb = rd->skb;
 					newskb = netdev_alloc_skb(dev, PKT_BUF_SZ);
-- 
1.8.0
