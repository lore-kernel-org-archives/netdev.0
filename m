From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 2/2] virtio_net: enable probing for NEEDS_RESET support
Date: Tue, 29 Aug 2017 16:07:59 -0400
Message-ID: <20170829200759.13975-3-willemdebruijn.kernel@gmail.com>
References: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:38143 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdH2UIE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:08:04 -0400
Received: by mail-qt0-f193.google.com with SMTP id d15so3681248qta.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:08:04 -0700 (PDT)
In-Reply-To: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Implement a mechanism to signal that a virtio device implements the
VIRTIO_CONFIG_S_NEEDS_RESET command.

Testing for VIRTIO_CONFIG_S_NEEDS_RESET support by issuing the request
and verifying the reset state would require an expensive state change.

To avoid that, add a status bit to the feature register used during
feature negotiation between host and guest.

Set the bit for virtio-net, which supports the feature.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c           | 2 ++
 include/uapi/linux/virtio_config.h | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5e349226f7c1..15483a982106 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2801,12 +2801,14 @@ static struct virtio_device_id id_table[] = {
 
 static unsigned int features[] = {
 	VIRTNET_FEATURES,
+	VIRTIO_F_CAN_RESET,
 };
 
 static unsigned int features_legacy[] = {
 	VIRTNET_FEATURES,
 	VIRTIO_NET_F_GSO,
 	VIRTIO_F_ANY_LAYOUT,
+	VIRTIO_F_CAN_RESET,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/uapi/linux/virtio_config.h b/include/uapi/linux/virtio_config.h
index 308e2096291f..726be44a04d3 100644
--- a/include/uapi/linux/virtio_config.h
+++ b/include/uapi/linux/virtio_config.h
@@ -56,6 +56,9 @@
  * suppressed them? */
 #define VIRTIO_F_NOTIFY_ON_EMPTY	24
 
+/* Driver supports the VIRTIO_CONFIG_S_NEEDS_RESET command */
+#define VIRTIO_F_CAN_RESET		25
+
 /* Can the device handle any descriptor layout? */
 #define VIRTIO_F_ANY_LAYOUT		27
 #endif /* VIRTIO_CONFIG_NO_LEGACY */
-- 
2.14.1.342.g6490525c54-goog
