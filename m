From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 27/50] virtio_net: disable mac write for virtio 1.0
Date: Mon, 1 Dec 2014 18:05:00 +0200
Message-ID: <1417449619-24896-28-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, rusty@au1.ibm.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417449619-24896-1-git-send-email-mst@redhat.com>
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

The spec states that mac in config space is only driver-writable in the
legacy case.  Fence writing it in virtnet_set_mac_address() in the
virtio 1.0 case.

Suggested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a0e64cf..b8bd719 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1030,7 +1030,8 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 				 "Failed to set mac address by vq command.\n");
 			return -EINVAL;
 		}
-	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
+	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
+		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
 		unsigned int i;
 
 		/* Naturally, this has an atomicity problem. */
-- 
MST
