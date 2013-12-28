From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 11/20] net: packetengines: slight optimization
 of addr
Date: Sat, 28 Dec 2013 14:17:49 +0800
Message-ID: <52BE6D0D.9050301@huawei.com>
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
 drivers/net/ethernet/packetengines/yellowfin.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index d28593b..b83ac0e 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -1097,12 +1097,12 @@ static int yellowfin_rx(struct net_device *dev)
 			if (status2 & 0x80) dev->stats.rx_dropped++;
 #ifdef YF_PROTOTYPE		/* Support for prototype hardware errata. */
 		} else if ((yp->flags & HasMACAddrBug)  &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				dev->dev_addr, 6) != 0 &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				"\377\377\377\377\377\377", 6) != 0) {
+			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
+						      entry * sizeof(struct yellowfin_desc)),
+							  dev->dev_addr) &&
+			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
+							  entry * sizeof(struct yellowfin_desc)),
+							  "\377\377\377\377\377\377")) {
 			if (bogus_rx++ == 0)
 				netdev_warn(dev, "Bad frame to %pM\n",
 					    buf_addr);
-- 
1.7.1
