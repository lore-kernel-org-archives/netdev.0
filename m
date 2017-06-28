From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: unbreak cusmed packet for small buffer XDP
Date: Wed, 28 Jun 2017 09:54:03 +0800
Message-ID: <1498614843-8163-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We should allow csumed packet for small buffer, otherwise XDP_PASS
won't work correctly.

Fixes commit bb91accf2733 ("virtio-net: XDP support for small buffers")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
The patch is needed for -stable.
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 143d8a9..499fcc9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -413,7 +413,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 		void *orig_data;
 		u32 act;
 
-		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
+		if (unlikely(hdr->hdr.gso_type))
 			goto err_xdp;
 
 		xdp.data_hard_start = buf + VIRTNET_RX_PAD + vi->hdr_len;
-- 
2.7.4
