From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/4] hamradio: Adjust four function calls together with a
 variable assignment
Date: Tue, 9 May 2017 16:25:07 +0200
Message-ID: <20f62ffa-b12a-f14c-df7b-96a750153823@users.sourceforge.net>
References: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 15:57:17 +0200

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/hamradio/bpqether.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index eaa0f2e8e561..5e234e0ca256 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -185,7 +185,8 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
 		return NET_RX_DROP;
 
 	if (!pskb_may_pull(skb, sizeof(struct ethhdr)))
@@ -286,7 +287,8 @@ static netdev_tx_t bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	bpq = netdev_priv(dev);
 
 	orig_dev = dev;
-	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
+	dev = bpq_get_ether_dev(dev);
+	if (!dev) {
 		orig_dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -565,12 +567,14 @@ static int bpq_device_event(struct notifier_block *this,
 		break;
 
 	case NETDEV_DOWN:	/* ethernet device closed -> close BPQ interface */
-		if ((dev = bpq_get_ax25_dev(dev)) != NULL)
+		dev = bpq_get_ax25_dev(dev);
+		if (dev)
 			dev_close(dev);
 		break;
 
 	case NETDEV_UNREGISTER:	/* ethernet device removed -> free BPQ interface */
-		if ((dev = bpq_get_ax25_dev(dev)) != NULL)
+		dev = bpq_get_ax25_dev(dev);
+		if (dev)
 			bpq_free_device(dev);
 		break;
 	default:
-- 
2.12.2
