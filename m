From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH repost] virtio-net: remove useless disable on freeze
Date: Wed, 30 May 2012 17:21:29 +0300
Message-ID: <20120530142128.GA31299@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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
In particular it doesn't have any effect when
event index is on.

Instead, detach, napi disable and reset on freeze ensure we don't run
concurrently with a callback.

Remove the useless calls so we get same behaviour
with and without event index.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Reposting a patch that seems to have fallen through cracks.

 drivers/net/virtio_net.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9ce6995..5214b1e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1231,11 +1231,6 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	vi->config_enable = false;
 	mutex_unlock(&vi->config_lock);
 
-	virtqueue_disable_cb(vi->rvq);
-	virtqueue_disable_cb(vi->svq);
-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
-		virtqueue_disable_cb(vi->cvq);
-
 	netif_device_detach(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
-- 
MST
