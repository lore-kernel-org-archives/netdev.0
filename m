From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 07/10] vsock/virtio: add a missing __le annotation
Date: Tue, 6 Dec 2016 17:40:57 +0200
Message-ID: <1481038106-24899-8-git-send-email-mst@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1481038106-24899-1-git-send-email-mst@redhat.com>
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

guest cid is read from config space, therefore it's in little endian
format and is treated as such, annotate it accordingly.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/vmw_vsock/virtio_transport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transport.c
index 936d7ee..90096b9 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -336,7 +336,7 @@ static void virtio_vsock_reset_sock(struct sock *sk)
 static void virtio_vsock_update_guest_cid(struct virtio_vsock *vsock)
 {
 	struct virtio_device *vdev = vsock->vdev;
-	u64 guest_cid;
+	__le64 guest_cid;
 
 	vdev->config->get(vdev, offsetof(struct virtio_vsock_config, guest_cid),
 			  &guest_cid, sizeof(guest_cid));
-- 
MST
