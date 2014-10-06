From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 09/15] virtio_net: minor cleanup
Date: Mon, 6 Oct 2014 18:11:12 +0300
Message-ID: <1412608214-31944-10-git-send-email-mst@redhat.com>
References: <1412608214-31944-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1412608214-31944-1-git-send-email-mst@redhat.com>
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

	goto done;
done:
	return;
is ugly, it was put there to make diff review easier.
replace by open-coded return.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 23e4a69..ef04d23 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1403,7 +1403,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
 
 	if (virtio_cread_feature(vi->vdev, VIRTIO_NET_F_STATUS,
 				 struct virtio_net_config, status, &v) < 0)
-		goto done;
+		return;
 
 	if (v & VIRTIO_NET_S_ANNOUNCE) {
 		netdev_notify_peers(vi->dev);
@@ -1414,7 +1414,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
 	v &= VIRTIO_NET_S_LINK_UP;
 
 	if (vi->status == v)
-		goto done;
+		return;
 
 	vi->status = v;
 
@@ -1425,8 +1425,6 @@ static void virtnet_config_changed_work(struct work_struct *work)
 		netif_carrier_off(vi->dev);
 		netif_tx_stop_all_queues(vi->dev);
 	}
-done:
-	return;
 }
 
 static void virtnet_config_changed(struct virtio_device *vdev)
-- 
MST
