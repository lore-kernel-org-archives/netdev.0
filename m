From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: alloc big buffers also when guest can receive
	UFO
Date: Wed, 12 Feb 2014 13:43:28 +0800
Message-ID: <1392183808-16789-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>
To: rusty@rustcorp.com.au, mst@redhat.com, virtio-dev@lists.oasis-open.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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

We should alloc big buffers also when guest can receive UFO
pakcets. Otherwise the big packets will be truncated when mergeable rx
buffer is disabled.

Fixes 5c5167515d80f78f6bb538492c423adcae31ad65
(virtio-net: Allow UFO feature to be set and advertised.)

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d75f8ed..5632a99 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1711,7 +1711,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
-	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN) ||
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_UFO))
 		vi->big_packets = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
-- 
1.8.3.2
