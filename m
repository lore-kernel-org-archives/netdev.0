From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 20/21] hamradio: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:11:32 +0800
Message-ID: <52B7C604.8070908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Joerg Reuter <jreuter@yaina.de>, <linux-hams@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Joerg Reuter <jreuter@yaina.de>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/hamradio/bpqether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index f91bf0d..61eae6e 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -208,7 +208,7 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	eth = eth_hdr(skb);
 
 	if (!(bpq->acpt_addr[0] & 0x01) &&
-	    memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN))
+	    !ether_addr_equal_unaligned(eth->h_source, bpq->acpt_addr))
 		goto drop_unlock;
 
 	if (skb_cow(skb, sizeof(struct ethhdr)))
-- 
1.8.0
