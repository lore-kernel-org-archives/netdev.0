From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 09/25] virtio_net: minor cleanup
Date: Sun, 12 Oct 2014 14:47:12 +0300
Message-ID: <1413114332-626-10-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
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
