From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 22/42] virtio_net: stricter short buffer length checks
Date: Tue, 25 Nov 2014 18:42:58 +0200
Message-ID: <1416933600-21398-23-git-send-email-mst@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416933600-21398-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Our buffer length check is not strict enough for mergeable
buffers: buffer can still be shorter that header + address
by 2 bytes.

Fix that up.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 516f2cb..098f443 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -437,7 +437,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	struct sk_buff *skb;
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 
-	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
+	if (unlikely(len < vi->hdr_len + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs) {
-- 
MST
