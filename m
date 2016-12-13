From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: correctly enable multiqueue
Date: Tue, 13 Dec 2016 14:23:05 +0800
Message-ID: <1481610185-12183-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, Neil Horman <nhorman@tuxdriver.com>,
	"Michael S . Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
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

Commit 4490001029012539937ff02778fe6180613fa949 ("virtio-net: enable
multiqueue by default") blindly set the affinity instead of queues
during probe which can cause a mismatch of #queues between guest and
host. This patch fixes it by setting queues.

Reported-by: Theodore Ts'o <tytso@mit.edu>
Tested-by: Theodore Ts'o <tytso@mit.edu>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Fixes: 49000102901 ("virtio-net: enable multiqueue by default")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b425fa1..fe9f772 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1930,7 +1930,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_unregister_netdev;
 	}
 
-	virtnet_set_affinity(vi);
+	rtnl_lock();
+	virtnet_set_queues(vi, vi->curr_queue_pairs);
+	rtnl_unlock();
 
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
-- 
2.7.4
