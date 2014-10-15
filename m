From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH net-next 4/6] virtio-net: return the number of packets sent in free_old_xmit_skbs()
Date: Wed, 15 Oct 2014 15:25:28 +0800
Message-ID: <1413357930-45302-5-git-send-email-jasowang@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jason Wang <jasowang@redhat.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch returns the number of packets sent in free_old_xmit_skbs(), this is
necessary for calling this function in napi.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a4d56b8..ccf98f9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -827,7 +827,7 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
-static void free_old_xmit_skbs(struct send_queue *sq)
+static int free_old_xmit_skbs(struct send_queue *sq)
 {
 	struct sk_buff *skb;
 	unsigned int len;
@@ -848,6 +848,8 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 	stats->tx_bytes += tx_bytes;
 	stats->tx_packets =+ tx_packets;
 	u64_stats_update_end(&stats->tx_syncp);
+
+	return tx_packets;
 }
 
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
-- 
1.7.1
