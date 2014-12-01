From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 35/50] vhost/net: larger header for virtio 1.0
Date: Mon, 1 Dec 2014 18:05:39 +0200
Message-ID: <1417449619-24896-36-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
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

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Jason Wang <jasowang@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/vhost/net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index c218188..8ff4a6d 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -1030,7 +1030,8 @@ static int vhost_net_set_features(struct vhost_net *n, u64 features)
 	size_t vhost_hlen, sock_hlen, hdr_len;
 	int i;
 
-	hdr_len = (features & (1 << VIRTIO_NET_F_MRG_RXBUF)) ?
+	hdr_len = (features & ((1ULL << VIRTIO_NET_F_MRG_RXBUF) |
+			       (1ULL << VIRTIO_F_VERSION_1))) ?
 			sizeof(struct virtio_net_hdr_mrg_rxbuf) :
 			sizeof(struct virtio_net_hdr);
 	if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
-- 
MST
