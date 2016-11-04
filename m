From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] virtio-net: drop legacy features in virtio 1 mode
Date: Fri, 4 Nov 2016 12:55:36 +0200
Message-ID: <1478256865-29003-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Virtio 1.0 spec says VIRTIO_F_ANY_LAYOUT and VIRTIO_NET_F_GSO are
legacy-only feature bits. Do not negotiate them in virtio 1 mode.  Note
this is a spec violation so we need to backport it to stable/downstream
kernels.

Cc: stable@vger.kernel.org
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7a00365..b19fb4d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2089,23 +2089,33 @@ static struct virtio_device_id id_table[] = {
 	{ 0 },
 };
 
+#define VIRTNET_FEATURES \
+	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM, \
+	VIRTIO_NET_F_MAC, \
+	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6, \
+	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6, \
+	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO, \
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ, \
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
+	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
+	VIRTIO_NET_F_CTRL_MAC_ADDR, \
+	VIRTIO_NET_F_MTU
+
 static unsigned int features[] = {
-	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
-	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
-	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
-	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
-	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
-	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
-	VIRTIO_NET_F_CTRL_MAC_ADDR,
+	VIRTNET_FEATURES,
+};
+
+static unsigned int features_legacy[] = {
+	VIRTNET_FEATURES,
+	VIRTIO_NET_F_GSO,
 	VIRTIO_F_ANY_LAYOUT,
-	VIRTIO_NET_F_MTU,
 };
 
 static struct virtio_driver virtio_net_driver = {
 	.feature_table = features,
 	.feature_table_size = ARRAY_SIZE(features),
+	.feature_table_legacy = features_legacy,
+	.feature_table_size_legacy = ARRAY_SIZE(features_legacy),
 	.driver.name =	KBUILD_MODNAME,
 	.driver.owner =	THIS_MODULE,
 	.id_table =	id_table,
-- 
MST
