From: Aaron Conole <aconole@redhat.com>
Subject: [RFC v3 -net 1/2] virtio: Start feature MTU support
Date: Fri,  1 Apr 2016 15:32:15 -0400
Message-ID: <1459539136-13948-2-git-send-email-aconole@redhat.com>
References: <1459539136-13948-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Paolo Abeni <pabeni@redhat.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Pankaj Gupta <pagupta@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1459539136-13948-1-git-send-email-aconole@redhat.com>
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

This commit adds the feature bit and associated mtu device entry for the
virtio network device. Future commits will make use of these bits to support
negotiated MTU.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
v2,v3:
* No change

 include/uapi/linux/virtio_net.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index ec32293..41a6a01 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -55,6 +55,7 @@
 #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
 					 * Steering */
 #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
+#define VIRTIO_NET_F_MTU 25	/* Device supports Default MTU Negotiation */
 
 #ifndef VIRTIO_NET_NO_LEGACY
 #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
@@ -73,6 +74,8 @@ struct virtio_net_config {
 	 * Legal values are between 1 and 0x8000
 	 */
 	__u16 max_virtqueue_pairs;
+	/* Default maximum transmit unit advice */
+	__u16 mtu;
 } __attribute__((packed));
 
 /*
-- 
2.5.5
