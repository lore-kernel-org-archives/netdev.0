From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Net: caifdev is never used in net/caif/caif_dev.c::transmit()
 - remove it.
Date: Sun, 5 Feb 2012 23:50:46 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202052348450.32529@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	Sakari Ailus <sakari.ailus@nokia.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/caif/caif_dev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 82c5706..aa6f716 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -162,7 +162,6 @@ void caif_flow_cb(struct sk_buff *skb)
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 {
 	int err, high = 0, qlen = 0;
-	struct caif_dev_common *caifdev;
 	struct caif_device_entry *caifd =
 	    container_of(layer, struct caif_device_entry, layer);
 	struct sk_buff *skb;
@@ -174,7 +173,6 @@ static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 	skb->dev = caifd->netdev;
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_CAIF);
-	caifdev = netdev_priv(caifd->netdev);
 
 	/* Check if we need to handle xoff */
 	if (likely(caifd->netdev->tx_queue_len == 0))
-- 
1.7.9


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
