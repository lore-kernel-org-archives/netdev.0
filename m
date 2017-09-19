From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/3] virtio-net: remove unnecessary parameter of virtnet_xdp_xmit()
Date: Tue, 19 Sep 2017 17:42:41 +0800
Message-ID: <1505814163-7315-1-git-send-email-jasowang@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 511f833..a0ef4b0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -373,7 +373,6 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 }
 
 static bool virtnet_xdp_xmit(struct virtnet_info *vi,
-			     struct receive_queue *rq,
 			     struct xdp_buff *xdp)
 {
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
@@ -542,7 +541,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 			delta = orig_data - xdp.data;
 			break;
 		case XDP_TX:
-			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
+			if (unlikely(!virtnet_xdp_xmit(vi, &xdp)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
 			rcu_read_unlock();
 			goto xdp_xmit;
@@ -677,7 +676,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			}
 			break;
 		case XDP_TX:
-			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
+			if (unlikely(!virtnet_xdp_xmit(vi, &xdp)))
 				trace_xdp_exception(vi->dev, xdp_prog, act);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
-- 
2.7.4
