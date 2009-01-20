From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Fix MAX_PACKET_LEN to support 802.1Q VLANs
Date: Tue, 20 Jan 2009 09:48:58 -0700
Message-ID: <20090120164822.10112.89512.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:29523 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757889AbZATQv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 11:51:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.1Q expanded the maximum ethernet frame size by 4 bytes for the
VLAN tag.  We're not taking this into account in virtio_net, which
means the buffers we provide to the backend in the virtqueue RX ring
aren't big enough to hold a full MTU VLAN packet.  For QEMU/KVM,
this results in the backend exiting with a packet truncation error.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 43f6523..63ef2a8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -24,6 +24,7 @@
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
 #include <linux/scatterlist.h>
+#include <linux/if_vlan.h>
 
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
@@ -33,7 +34,7 @@ module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
 /* FIXME: MTU in config. */
-#define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
+#define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
 
 struct virtnet_info

