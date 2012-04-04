From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] virtio-net: remove useless disable on freeze
Date: Wed, 4 Apr 2012 12:19:55 +0300
Message-ID: <20120404091954.GA3776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

disable_cb is just an optimization: it
can not guarantee that there are no callbacks.

I didn't yet figure out whether a callback
in freeze will trigger a bug, but disable_cb
won't address it in any case. So let's remove
the useless calls as a first step.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 019da01..971931e5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1182,11 +1182,6 @@ static int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
-	virtqueue_disable_cb(vi->rvq);
-	virtqueue_disable_cb(vi->svq);
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
-		virtqueue_disable_cb(vi->cvq);
-
 	netif_device_detach(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
-- 
1.7.9.111.gf3fb0
